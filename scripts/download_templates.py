import urllib.request
import os
import subprocess

def download_pdf(url, output_path):
    req = urllib.request.Request(
        url, 
        headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'}
    )
    try:
        with urllib.request.urlopen(req) as response, open(output_path, 'wb') as out_file:
            data = response.read()
            out_file.write(data)
            print(f"Successfully downloaded: {output_path} ({len(data)} bytes)")
            # Check if it's actually a PDF by reading magic bytes
            if not data.startswith(b'%PDF'):
                print(f"Warning: {output_path} does not seem to be a valid PDF.")
                return False
            return True
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return False

def convert_to_png(pdf_path, png_path):
    # Use sips to convert pdf to png
    try:
        subprocess.run(['sips', '-s', 'format', 'png', '-s', 'dpiHeight', '300.0', '-s', 'dpiWidth', '300.0', pdf_path, '--out', png_path], check=True)
        print(f"Converted {pdf_path} to {png_path}")
    except Exception as e:
        print(f"Failed to convert {pdf_path}: {e}")

os.makedirs('assets/templates', exist_ok=True)

urls = {
    'tr_ktt.pdf': 'https://karsalotomotiv.com.tr/wp-content/uploads/2019/12/kaza_tespit_tutanagi.pdf',
    'eu_eas.pdf': 'https://darwin-insurance.com/media/2065/european-accident-statement-form.pdf'
}

fallbacks = {
    'tr_ktt.pdf': [
        'https://www.tmtb.org.tr/assets/docs/maddi-hasarli-kaza-tespit-tutanagi.pdf',
        'https://www.tsb.org.tr/tr/Document/KazaTespitTutanagi.pdf'
    ],
    'eu_eas.pdf': [
        'https://www.zurich.ch/-/media/zurich-site/content/services/schaden/european-accident-statement.pdf',
        'https://www.allianz.co.uk/content/dam/onemarketing/azuk/allianz-co-uk/documents/claims/european_accident_statement_form.pdf'
    ]
}

for filename, primary_url in urls.items():
    pdf_path = f"assets/templates/{filename}"
    png_path = f"assets/templates/{filename.replace('.pdf', '.png')}"
    
    success = download_pdf(primary_url, pdf_path)
    if not success:
        for fallback_url in fallbacks[filename]:
            print(f"Trying fallback: {fallback_url}")
            success = download_pdf(fallback_url, pdf_path)
            if success: break
            
    if success:
        convert_to_png(pdf_path, png_path)
