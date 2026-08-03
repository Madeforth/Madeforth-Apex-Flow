import glob
import re

def main():
    directory = '/Users/otelgrafik/Desktop/Apex Flow Dosyaları/ApexFlow-main/lib'
    dart_files = glob.glob(directory + '/**/*.dart', recursive=True)
    
    pattern1 = re.compile(r"tr:\s*''([^']*)''")
    pattern2 = re.compile(r'tr:\s*""([^"]*)""')
    pattern3 = re.compile(r"en:\s*''([^']*)''")
    pattern4 = re.compile(r'en:\s*""([^"]*)""')

    total_fixed = 0
    
    for filepath in dart_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original = content
        
        content = pattern1.sub(r"tr: '\1'", content)
        content = pattern2.sub(r'tr: "\1"', content)
        content = pattern3.sub(r"en: '\1'", content)
        content = pattern4.sub(r'en: "\1"', content)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            total_fixed += 1
            print(f"Fixed quotes in {filepath}")

    print(f"Fixed files: {total_fixed}")

if __name__ == '__main__':
    main()
