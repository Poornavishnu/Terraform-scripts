import os
import boto3
import subprocess
import json
import requests
import zipfile
import io

def send_sns_alert(message):
    """Send an SNS notification when drift is detected."""
    sns_client = boto3.client("sns")

    # Retrieve SNS ARN dynamically from environment variable
    SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

    if not SNS_TOPIC_ARN:
        raise Exception("SNS_TOPIC_ARN environment variable not set")

    response = sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="🚨 Terraform Drift Detected 🚨",
        Message=message
    )
    return response

def download_terraform_files():
    """Downloads and extracts Terraform files from GitHub to /tmp"""
    GITHUB_REPO_URL = "https://github.com/Poornavishnu/Terraform-scripts/archive/refs/heads/main.zip"
    
    response = requests.get(GITHUB_REPO_URL, stream=True)
    if response.status_code == 200:
        zip_ref = zipfile.ZipFile(io.BytesIO(response.content))
        zip_ref.extractall("/tmp")
        zip_ref.close()
        return True
    return False

def lambda_handler(event, context):
    try:
        # Download Terraform files from GitHub
        if not download_terraform_files():
            raise Exception("❌ Failed to download Terraform files from GitHub")

        # Change directory to the downloaded Terraform repo
        os.chdir("/tmp/Terraform-scripts-main")  # Adjust if repo structure changes

        # Run terraform init
        subprocess.run(["terraform", "init"], check=True)

        # Run terraform plan
        result = subprocess.run(["terraform", "plan", "-detailed-exitcode"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        if result.returncode == 2:
            # Drift detected, send an SNS alert
            send_sns_alert("⚠️ Terraform drift detected! Review the changes and take action.")
            return {"status": "Drift detected", "details": result.stdout}
        elif result.returncode == 0:
            return {"status": "No drift detected", "details": "✅ Everything is up to date."}
        else:
            raise Exception(f"Terraform Plan failed: {result.stderr}")

    except Exception as e:
        send_sns_alert(f"❌ Error in Terraform drift detection: {str(e)}")
        return {"error": str(e)}