import os
import re
import glob

def main():
    directory = '/Users/otelgrafik/Desktop/Apex Flow Dosyaları/ApexFlow-main/lib'
    dart_files = glob.glob(directory + '/**/*.dart', recursive=True)
    
    # Matches strings like tr ? 'TR' : 'EN'
    # Or widget.strings.locale.languageCode == 'tr' ? 'TR' : 'EN'
    # We will just look for ? 'something' : 'something' when preceded by tr
    pattern = re.compile(r"tr\s*\?\s*('([^']*)'|\"([^\"]*)\")\s*:\s*('([^']*)'|\"([^\"]*)\")")
    
    matches_found = []
    
    for filepath in dart_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        for match in pattern.finditer(content):
            tr_str = match.group(2) or match.group(3)
            en_str = match.group(5) or match.group(6)
            matches_found.append((filepath, tr_str, en_str, match.group(0)))
            
    print(f"Found {len(matches_found)} occurrences of inline ternaries.")
    for filepath, tr, en, full in matches_found:
        print(f"FILE: {filepath.split('lib/')[-1]}")
        print(f"  TR: {tr}")
        print(f"  EN: {en}")
        print(f"  MATCH: {full}")
        print("-" * 40)

if __name__ == '__main__':
    main()
