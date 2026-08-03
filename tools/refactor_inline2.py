import os
import re
import glob
import time
import sys
from deep_translator import GoogleTranslator

def log(msg):
    print(msg)
    sys.stdout.flush()

def main():
    directory = '/Users/otelgrafik/Desktop/Apex Flow Dosyaları/ApexFlow-main/lib'
    dart_files = glob.glob(directory + '/**/*.dart', recursive=True)
    
    # 1. Update app_strings.dart
    app_strings_path = os.path.join(directory, 'core', 'i18n', 'app_strings.dart')
    with open(app_strings_path, 'r', encoding='utf-8') as f:
        app_strings_content = f.read()
        
    if "String tInline" not in app_strings_content:
        # Inject currentLanguageCode if missing
        if "static String currentLanguageCode = 'en';" not in app_strings_content:
            app_strings_content = app_strings_content.replace(
                "static const supportedLocales = [Locale('en'), Locale('tr'), Locale('de')];",
                "static const supportedLocales = [Locale('en'), Locale('tr'), Locale('de')];\n  static String currentLanguageCode = 'en';"
            )
            app_strings_content = app_strings_content.replace(
                "AppStrings(this.locale);",
                "AppStrings(this.locale) {\n    currentLanguageCode = locale.languageCode;\n  }"
            )
            # if it was already updated to have body:
            if "AppStrings(this.locale) {" not in app_strings_content:
                app_strings_content = app_strings_content.replace(
                    "AppStrings(this.locale)",
                    "AppStrings(this.locale) {\n    currentLanguageCode = locale.languageCode;\n  }"
                )
        
        app_strings_content += """

// Global inline translator to replace tr ? 'TR' : 'EN' easily
String tInline(String trStr, String enStr, String deStr) {
  if (AppStrings.currentLanguageCode == 'tr') return trStr;
  if (AppStrings.currentLanguageCode == 'de') return deStr;
  return enStr;
}
"""
        with open(app_strings_path, 'w', encoding='utf-8') as f:
            f.write(app_strings_content)
        log("Updated app_strings.dart with tInline")

    translator = GoogleTranslator(source='en', target='de')
    translation_cache = {}
    
    # Correct Regex that handles escaped quotes!
    # Matches strings like 'foo\'s bar' or "foo\"bar"
    pattern = re.compile(r"(?:[a-zA-Z0-9_\.]*(?:tr|isTurkish|languageCode\s*==\s*'tr'))\s*\?\s*('(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\")\s*:\s*('(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\")")
    
    total_replaced = 0
    
    for filepath in dart_files:
        if 'app_strings.dart' in filepath:
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        modified_content = content
        replacements = []
        
        for match in pattern.finditer(content):
            tr_quote = match.group(1) 
            en_quote = match.group(2) 
            
            # Extract string content to translate (remove the outer quotes, handle escapes)
            text_to_translate = en_quote[1:-1]
            quote_char = en_quote[0]
            
            # Unescape the text for translation
            if quote_char == "'":
                text_to_translate_unescaped = text_to_translate.replace("\\'", "'")
            else:
                text_to_translate_unescaped = text_to_translate.replace('\\"', '"')
            
            if not text_to_translate_unescaped.strip():
                de_quote = en_quote
            else:
                if text_to_translate_unescaped not in translation_cache:
                    try:
                        translated = translator.translate(text_to_translate_unescaped)
                        
                        # Fix common interpolation
                        translated = translated.replace('$ ', '$')
                        
                        translation_cache[text_to_translate_unescaped] = translated
                        time.sleep(0.02)
                    except Exception as e:
                        log(f"Error translating '{text_to_translate_unescaped}': {e}")
                        translation_cache[text_to_translate_unescaped] = text_to_translate_unescaped
                        
                de_str = translation_cache[text_to_translate_unescaped]
                
                # Re-escape the translated string
                if quote_char == "'":
                    de_str_escaped = de_str.replace("'", "\\'")
                else:
                    de_str_escaped = de_str.replace('"', '\\"')
                    
                de_quote = f"{quote_char}{de_str_escaped}{quote_char}"
            
            original_match = match.group(0)
            replacement = f"tInline({tr_quote}, {en_quote}, {de_quote})"
            replacements.append((original_match, replacement))
            
        if replacements:
            for orig, new_str in replacements:
                modified_content = modified_content.replace(orig, new_str)
            
            # Ensure app_strings.dart is imported
            # Check for correct package name import
            if "import 'package:apex_flow/core/i18n/app_strings.dart';" not in modified_content and "import 'package:apexflow/core/i18n/app_strings.dart';" not in modified_content and "import '../../core/i18n/app_strings.dart';" not in modified_content:
                import_idx = modified_content.rfind("import '")
                if import_idx != -1:
                    end_of_import = modified_content.find(";", import_idx) + 1
                    modified_content = modified_content[:end_of_import] + "\nimport 'package:apexflow/core/i18n/app_strings.dart';" + modified_content[end_of_import:]
                else:
                    modified_content = "import 'package:apexflow/core/i18n/app_strings.dart';\n" + modified_content
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(modified_content)
                
            log(f"Replaced {len(replacements)} instances in {os.path.basename(filepath)}")
            total_replaced += len(replacements)
            
    log(f"Total inline strings refactored: {total_replaced}")

if __name__ == '__main__':
    main()
