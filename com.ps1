# --- Step 1: Define the Raw GitHub URL ---
$ScriptUrl = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/create_cybot_task.bat"
$DownloadPath = "C:\Temp\create_cybot_task.bat" # Choose a temporary download location

# --- Step 2: Create the C:\Temp directory if it doesn't exist ---
if (-not (Test-Path C:\Temp)) {
    New-Item -Path C:\Temp -ItemType Directory -Force
    Write-Host "Created C:\Temp directory."
}

# --- Step 3: Download the script ---
Write-Host "Downloading script from $ScriptUrl to $DownloadPath..."
try {
    Invoke-WebRequest -Uri $ScriptUrl -OutFile $DownloadPath -ErrorAction Stop
    Write-Host "Script downloaded successfully."
}
catch {
    Write-Error "Failed to download script: $($_.Exception.Message)"
    exit 1
}

# --- Step 4: Execute the downloaded script ---
Write-Host "Executing the downloaded script..."
try {
    # It's good practice to navigate to the script's directory before executing
    # This helps if the script uses relative paths
    Set-Location (Split-Path $DownloadPath -Parent)
    cmd.exe /c $DownloadPath # Use cmd.exe /c to run the batch file
    Write-Host "Script execution initiated."
}
catch {
    Write-Error "Failed to execute script: $($_.Exception.Message)"
    exit 1
}

# --- Step 5: (Optional) Clean up the downloaded script ---
# You might want to remove the script after successful execution
# Remove-Item $DownloadPath -Force
# Write-Host "Cleaned up downloaded script."