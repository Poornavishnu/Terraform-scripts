import os
import sys
import requests
import zipfile
import subprocess

sys.path.append("/opt/python")

# ✅ GitHub Repo URL for Terraform scripts
GITHUB_REPO_URL = "https://codeload.github.com/Poornavishnu/Terraform-scripts/zip/refs/heads/terraform"

# ✅ S3 Backend Configuration (Must match local Terraform)
S3_BACKEND_CONFIG = [
    "-backend-config=bucket=terraform-state-vishnu-123456",
    "-backend-config=key=terraform.tfstate",
    "-backend-config=region=us-east-2",
    "-backend-config=encrypt=true"
]

def download_terraform_files():
    """Downloads and extracts Terraform files from GitHub to /tmp"""
    try:
        response = requests.get(GITHUB_REPO_URL, stream=True)
        if response.status_code == 200:
            zip_path = "/tmp/terraform.zip"
            
            # ✅ Save ZIP file to /tmp/
            with open(zip_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=1024):
                    f.write(chunk)
            print("✅ Terraform repo downloaded successfully!")

            # ✅ Extract ZIP and list extracted contents
            with zipfile.ZipFile(zip_path, "r") as zip_ref:
                zip_ref.extractall("/tmp")
                extracted_files = zip_ref.namelist()
                print(f"📁 Extracted files in Lambda: {extracted_files}")

            return True
        else:
            print(f"❌ Failed to download Terraform repo: HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error downloading Terraform repo: {str(e)}")
        return False

def lambda_handler(event, context):
    try:
        if not download_terraform_files():
            raise Exception("❌ Failed to download Terraform files from GitHub")

        # ✅ Step 2: List files in /tmp/ before changing directory
        print("📂 Files in /tmp/:", os.listdir("/tmp/"))

        # ✅ Step 3: Dynamically detect the extracted folder name
        repo_path = None
        for folder in os.listdir("/tmp/"):
            if folder.startswith("Terraform-scripts"):
                repo_path = os.path.join("/tmp", folder)
                break

        if not repo_path:
            raise Exception("❌ Extracted folder not found in /tmp/")

        print(f"✅ Changing directory to {repo_path}")
        os.chdir(repo_path)
        print("📂 Current working directory:", os.getcwd())

        # ✅ Step 4: Remove old Terraform state and reinitialize
        subprocess.run(["rm", "-rf", ".terraform"], check=True)

        # ✅ Step 5: Run `terraform init` with S3 backend configuration
        init_result = subprocess.run(["terraform", "init"] + S3_BACKEND_CONFIG, capture_output=True, text=True)

        # ✅ Print Terraform Init Output
        print(f"Terraform Init Output:\n{init_result.stdout}")
        if init_result.returncode != 0:
            raise Exception(f"❌ Terraform Init Failed: {init_result.stderr}")

        # ✅ Step 6: Verify Terraform Backend State
        backend_state = subprocess.run(["terraform", "state", "pull"], capture_output=True, text=True)
        print(f"🔍 Terraform Backend State:\n{backend_state.stdout}")

        # ✅ Step 7: Run `terraform plan` and check for drift
        result = subprocess.run(["terraform", "plan", "-detailed-exitcode"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        if result.returncode == 2:
            print("⚠️ Terraform drift detected!")
            return {"status": "Drift detected", "details": result.stdout}
        elif result.returncode == 0:
            print("✅ No drift detected")
            return {"status": "No drift detected", "details": "✅ Everything is up to date."}
        else:
            raise Exception(f"Terraform Plan failed: {result.stderr}")

    except Exception as e:
        print(f"❌ Error in Terraform drift detection: {str(e)}")
        return {"error": str(e)}