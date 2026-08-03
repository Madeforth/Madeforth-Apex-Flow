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
    
    translator = GoogleTranslator(source='en', target='de')
    translation_cache = {}
    
    # Matches: condition ? 'tr_string' : 'en_string'
    # Group 1: condition
    # Group 2: tr_string WITH QUOTES
    # Group 3: en_string WITH QUOTES
    pattern = re.compile(r"(?:[a-zA-Z0-9_\.]*(?:tr|isTurkish|languageCode\s*==\s*'tr'))\s*\?\s*('[^']*'|\"[^\"]*\")\s*:\s*('[^']*'|\"[^\"]*\")")
    
    total_replaced = 0
    
    for filepath in dart_files:
        if 'app_strings.dart' in filepath:
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        modified_content = content
        replacements = []
        
        for match in pattern.finditer(content):
            tr_quote = match.group(1) # e.g. 'Mesafe: $dist'
            en_quote = match.group(2) # e.g. 'Distance: $dist'
            
            # Extract string content to translate (remove the outer quotes)
            text_to_translate = en_quote[1:-1]
            quote_char = en_quote[0]
            
            if not text_to_translate.strip():
                de_quote = en_quote
            else:
                if text_to_translate not in translation_cache:
                    try:
                        translated = translator.translate(text_to_translate)
                        
                        # Fix some common interpolation issues if google translate messed them up
                        translated = translated.replace('$ ', '$')
                        
                        # Escape quotes properly
                        if quote_char == "'":
                            translated = translated.replace("'", "\\'")
                        else:
                            translated = translated.replace('"', '\\"')
                            
                        translation_cache[text_to_translate] = translated
                        time.sleep(0.05)
                    except Exception as e:
                        log(f"Error translating '{text_to_translate}': {e}")
                        translation_cache[text_to_translate] = text_to_translate
                        
                de_str = translation_cache[text_to_translate]
                de_quote = f"{quote_char}{de_str}{quote_char}"
            
            original_match = match.group(0)
            replacement = f"tInline({tr_quote}, {en_quote}, {de_quote})"
            replacements.append((original_match, replacement))
            
        if replacements:
            for orig, new_str in replacements:
                modified_content = modified_content.replace(orig, new_str)
            
            # Ensure app_strings.dart is imported
            if "import 'package:apex_flow/core/i18n/app_strings.dart';" not in modified_content and "import '../../core/i18n/app_strings.dart';" not in modified_content:
                # Add it after the last import
                import_idx = modified_content.rfind("import '")
                if import_idx != -1:
                    end_of_import = modified_content.find(";", import_idx) + 1
                    modified_content = modified_content[:end_of_import] + "\nimport 'package:apex_flow/core/i18n/app_strings.dart';" + modified_content[end_of_import:]
                else:
                    modified_content = "import 'package:apex_flow/core/i18n/app_strings.dart';\n" + modified_content
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(modified_content)
                
            log(f"Replaced {len(replacements)} instances in {os.path.basename(filepath)}")
            total_replaced += len(replacements)
            
    log(f"Total inline strings refactored: {total_replaced}")

if __name__ == '__main__':
    main()
