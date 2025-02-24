import json
import boto3
from pdf2image import convert_from_bytes
from pyzbar.pyzbar import decode
from io import BytesIO
from PIL import Image

# Initialize S3 client
s3_client = boto3.client('s3')

def extract_barcode_from_image(image):
    """Extract barcode from a PIL Image"""
    gray = image.convert('L')  # Convert to grayscale using PIL
    barcodes = decode(gray)
    
    for barcode in barcodes:
        barcode_data = barcode.data.decode('utf-8')
        print(f"Found barcode: {barcode_data}")
        return barcode_data
    return None

def process_pdf(pdf_file):
    """Convert PDF to images and extract barcodes"""
    try:
        # Convert PDF to images
        images = convert_from_bytes(pdf_file.getvalue())
        
        # Process each page
        for i, image in enumerate(images):
            print(f"Processing page {i+1}")
            barcode = extract_barcode_from_image(image)
            if barcode:
                return barcode
        
        return None
    except Exception as e:
        print(f"Error processing PDF: {str(e)}")
        raise

def lambda_handler(event, context):
    """Main Lambda handler"""
    try:
        # Get bucket and key from event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        print(f"Processing file: {bucket}/{key}")
        
        response = s3_client.get_object(Bucket=bucket, Key=key)
        pdf_file = BytesIO(response['Body'].read())
        
        # Process the PDF and extract barcode
        barcode = process_pdf(pdf_file)
        
        result = {
            'statusCode': 200,
            'body': json.dumps({
                'bucket': bucket,
                'key': key,
                'barcode': barcode
            })
        }
        
        print(f"Processing complete. Barcode: {barcode}")
        return result
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }