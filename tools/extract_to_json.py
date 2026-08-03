import os
import re
import glob
import json

def main():
    directory = '/Users/otelgrafik/Desktop/Apex Flow Dosyaları/ApexFlow-main/lib'
    dart_files = glob.glob(directory + '/**/*.dart', recursive=True)
    
    pattern = re.compile(r"tr\s*\?\s*('([^']*)'|\"([^\"]*)\")\s*:\s*('([^']*)'|\"([^\"]*)\")")
    
    unique_pairs = {}
    
    for filepath in dart_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        for match in pattern.finditer(content):
            tr_str = match.group(2) or match.group(3)
            en_str = match.group(5) or match.group(6)
            if tr_str and en_str:
                if tr_str not in unique_pairs:
                    unique_pairs[tr_str] = en_str
                    
    with open('/Users/otelgrafik/Desktop/Apex Flow Dosyaları/ApexFlow-main/tools/i18n_pairs.json', 'w', encoding='utf-8') as f:
        json.dump(unique_pairs, f, ensure_ascii=False, indent=2)
        
    print(f"Extracted {len(unique_pairs)} unique string pairs.")

if __name__ == '__main__':
    main()
