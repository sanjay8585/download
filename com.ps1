<#
.SYNOPSIS
    Creates a scheduled task named "CybotEndpoint_Monitor" that checks and
    starts the 'CybotEndpoint' service every 5 minutes if it's not running.

.DESCRIPTION
    This script utilizes the 'schtasks' command to establish a recurring
    scheduled task. The task runs under the SYSTEM account and is designed
    to ensure the 'CybotEndpoint' service remains in a running state.

.NOTES
    - This script must be run with Administrative privileges.
    - The 'CybotEndpoint' service must exist on the system for the task to be effective.
    - PowerShell's Execution Policy might need to be adjusted to run this script.
      (e.g., Set-ExecutionPolicy RemoteSigned -Scope Process -Force)
#>

# Ensure the script is running with administrative privileges
# This is crucial for creating scheduled tasks
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run with Administrative privileges."
    Write-Host "Attempting to restart with administrative privileges..."
    Start-Process PowerShell -Verb RunAs -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

Write-Host "Starting script to create CybotEndpoint_Monitor scheduled task..."

# Define the scheduled task parameters
$TaskName = "CybotEndpoint_Monitor"
$ServiceToMonitor = "CybotEndpoint"
$IntervalMinutes = 5

# Construct the action command for the scheduled task.
# This PowerShell command checks if the service is not running and starts it.
# Note: The inner double quotes within the -Command argument need to be escaped
# by backslashes when passed to schtasks.exe. PowerShell's argument parsing
# for external commands handles this well.
$TaskActionCommand = "powershell.exe -Command `"if ((Get-Service '$ServiceToMonitor' -EA SilentlyContinue).Status -ne 'Running') { Start-Service '$ServiceToMonitor' }`""

# Construct the full schtasks /create command
# Using a splatting approach for better readability with multiple arguments
$SchtasksArguments = @(
    "/create"
    "/tn", "`"$TaskName`"" # Task Name
    "/tr", "`"$TaskActionCommand`"" # Task Run (the command to execute)
    "/sc", "minute" # Schedule Type: every minute
    "/mo", "$IntervalMinutes" # Modifier: every 5 minutes
    "/ru", "SYSTEM" # Run as System user
)

Write-Host "Creating scheduled task '$TaskName'..."
Write-Host "Command being executed: schtasks $($SchtasksArguments -join ' ')"

try {
    # Execute the schtasks command
    # Using & for external command execution.
    # Passing arguments as a list to prevent parsing issues with complex strings.
    & schtasks.exe $SchtasksArguments

    # Check the $LASTEXITCODE for the exit code of schtasks.exe
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Scheduled task '$TaskName' created successfully." -ForegroundColor Green
        Write-Host "Task details:"
        schtasks /query /tn "$TaskName" /v /fo list | Select-String -Pattern "Task Name|Run As User|Schedule|Last Run Result"
    } else {
        Write-Error "ERROR: Failed to create scheduled task '$TaskName'. schtasks.exe exited with code $LASTEXITCODE."
        Write-Host "Please check if you have sufficient permissions or if a task with the same name already exists." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "An unexpected error occurred while running schtasks.exe: $($_.Exception.Message)"
}

Write-Host "Script finished."
