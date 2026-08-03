import glob
import os

def main():
    directory = '/Users/otelgrafik/Desktop/Apex Flow Dosyaları/ApexFlow-main/lib'
    dart_files = glob.glob(directory + '/**/*.dart', recursive=True)
    
    total = 0
    for filepath in dart_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'package:apex_flow/' in content:
            new_content = content.replace('package:apex_flow/', 'package:apexflow/')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            total += 1
            print(f"Fixed imports in {os.path.basename(filepath)}")
            
    print(f"Fixed {total} files")

if __name__ == '__main__':
    main()
