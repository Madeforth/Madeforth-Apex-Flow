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
    
    # Update app_strings.dart to make _t public
    app_strings_path = os.path.join(directory, 'core', 'i18n', 'app_strings.dart')
    with open(app_strings_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = content.replace('String _t({', 'String t({')
    content = content.replace('_t(', 't(')
    
    with open(app_strings_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    log("Updated app_strings.dart to make t() public.")

    # Translator instance
    translator = GoogleTranslator(source='en', target='de')
    
    translation_cache = {}
    
    pattern = re.compile(r"([a-zA-Z0-9_\.]*(?:tr|isTurkish|languageCode\s*==\s*'tr'))\s*\?\s*('([^']*)'|\"([^\"]*)\")\s*:\s*('([^']*)'|\"([^\"]*)\")")
    
    total_replaced = 0
    
    for filepath in dart_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        modified_content = content
        replacements = []
        
        strings_var = "strings"
        if "widget.strings.locale" in content:
            strings_var = "widget.strings"
        elif "Localizations.localeOf" in content:
             strings_var = "AppStrings(Localizations.localeOf(context))"
             
        for match in pattern.finditer(content):
            condition = match.group(1)
            tr_quote = match.group(2) or match.group(3)
            en_quote = match.group(5) or match.group(6)
            
            tr_literal = f"'{tr_quote}'" if match.group(2) else f'"{tr_quote}"'
            en_literal = f"'{en_quote}'" if match.group(5) else f'"{en_quote}"'
            text_to_translate = match.group(6) if match.group(6) is not None else match.group(5)
            
            if not text_to_translate.strip():
                de_literal = en_literal
            else:
                if text_to_translate not in translation_cache:
                    try:
                        # Translate
                        translated = translator.translate(text_to_translate)
                        if match.group(5):
                            translated = translated.replace("'", "\\'")
                        else:
                            translated = translated.replace('"', '\\"')
                        translation_cache[text_to_translate] = translated
                        time.sleep(0.1) # Small delay to avoid rate limiting
                    except Exception as e:
                        log(f"Error translating '{text_to_translate}': {e}")
                        translation_cache[text_to_translate] = text_to_translate
                        
                de_str = translation_cache[text_to_translate]
                de_literal = f"'{de_str}'" if match.group(5) else f'"{de_str}"'
            
            original_match = match.group(0)
            
            local_strings_var = strings_var
            if "widget.strings" in condition:
                local_strings_var = "widget.strings"
            elif "strings." in condition:
                local_strings_var = "strings"
                
            replacement = f"{local_strings_var}.t(tr: {tr_literal}, en: {en_literal}, de: {de_literal})"
            replacements.append((original_match, replacement))
            
        if replacements:
            for orig, new_str in replacements:
                modified_content = modified_content.replace(orig, new_str)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(modified_content)
                
            log(f"Replaced {len(replacements)} instances in {os.path.basename(filepath)}")
            total_replaced += len(replacements)
            
    log(f"Total inline strings refactored: {total_replaced}")

if __name__ == '__main__':
    main()
