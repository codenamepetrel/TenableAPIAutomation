#Tenable API Recast Config Script for Powershell Automation
#Pete Lenhart - 11/12/2024

#This is the loader piece of the script.
#This takes a txt file with IP addresses and loops through them.  For each IP, it runs the TenableSC_Recasts_Pete_Reedit.ps1 script.
#Please input the configurations below, then the script with create recasts in tenable with the config you made for each IP.

# Path to the IP list file
$ipListFile = "M:\scripts\myfile.txt"

# Path to the script you want to run for each IP
$scriptPath = "M:\scripts\TenableSC_Recasts_Pete_Reedit.ps1"

# Define static parameters (if they don't change per IP)
$RepoID = "1"
$plugin_id = "12345"
$sev_value = "3"
$hostType = "ip"
$port = "8080"
$protocol = "6"
$comment = "Test comment"

# Loop through each IP in the list
foreach ($hostvalue in Get-Content -Path $ipListFile) {
    # Call ScriptA.ps1 with the current IP as the $hostvalue parameter
    & $scriptPath -hostvalue $hostvalue -RepoID $RepoID -plugin_id $plugin_id -sev_value $sev_value -hostType $hostType -port $port -protocol $protocol -comment $comment
}
