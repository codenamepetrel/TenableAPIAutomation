#PL 11/12/2024
#Operator script to update recasts in Tenable using PowerShell
#You need to save your API access key and secret into the Secret Store Module.  

# Define advanced script features and parameters with validation
[CmdletBinding()]
Param
(
    # Optional parameter for Repository ID, default value is "1"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$RepoID = "1",
    
    # Mandatory parameter for Plugin ID, must be a non-empty numeric string
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+$')]
    [ValidateNotNullOrEmpty()]
    [string]$plugin_id,
    
    # Mandatory parameter for severity value, must be one of the specified values
    [Parameter(Mandatory = $true)]
    [ValidateSet("0", "1", "2", "3", "4")]
    [string]$sev_value,
    
    # Mandatory parameter for host type, restricted to specific values
    [Parameter(Mandatory = $true)]
    [ValidateSet("ip", "all")]
    [string]$hostType,
    
    # Mandatory parameter for host value, must match IPv4 address format
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$')]
    [string]$hostvalue,
    
    # Mandatory parameter for port, must be a non-empty string
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$port,
    
    # Mandatory parameter for protocol, specifies network protocol type
    [Parameter(Mandatory = $true, HelpMessage = "Blank = UDP, 1 = ICMP, 6 = TCP, any = any, 0 = Unknown")]
    [ValidateSet(" ", "1", "6", "any", "0")] 
    [string]$protocol,
    
    # Mandatory parameter for comments, must be a non-empty string
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$comment
)

# BEGIN block executes once before the PROCESS block
BEGIN {
    # Retrieve API access keys securely from the secret store
    $AK = Get-Secret -Name TenableAccessKey -AsPlainText
    $SK = Get-Secret -Name TenableSecretKey -AsPlainText
    
    # Define HTTP headers with API keys for authentication
    $headers = @{ "x-apikey" = "accesskey=$AK; secretkey=$SK;" }
}

# PROCESS block executes for each input passed to the script
PROCESS {

    # Function to get Repository ID based on asset group input
    function Get-RepoID ($assetgroup) {
        switch ($assetgroup) {
            "Tenable" {$return = "1"}
            "Agent" {$return = "2"}
            "TenableRepo" {$return = "1"}
            "Tenable.IO" {$return = "2"}
            "Network" {$return = "1"}
            "IO" {$return = "2"}
            default {
                write-error "Repository`"$Repository`" not found."
                $return = $null
            }
        }
        return $return
    }

    # Define API URL for recast risk rule with required parameters
    $Url = "https://<YOUR TENABLE SC SERVER>/rest/recastRiskRule?pluginID=$plugin_id&repositoryIDs=$repoid"

    # Set expiration date for the recast rule and convert it to epoch time
    $ExpireDate = '04/04/2025'
    $ExpireDate = (get-date -Date $ExpireDate).AddHours(+5)
    $expiration_date = Get-Date $ExpireDate -UFormat %s

    # Log the action being taken
    Write-Host "Adding Risk Recast for Plugin ID" + $plugin_id + " to Repository ID " + $RepoID + " with Severity " + $sev_value + " for Hosts " + $hostvalue

    # Create the JSON body for the API request
    $Body = @{
        "repositories" = @(@{"id" = "$repoid"})
        "plugin" = @{"id" = "$plugin_id"}
        "newSeverity" = @{"id" = "$sev_value"}
        "hostType" = "$hostType"
        "hostValue" = "$hostvalue"
        "port" = "$port"
        "protocol" = "$protocol"
        "expires" = "$expiration_date"
        "comments" = "$comment"
    } | ConvertTo-Json

    # Send POST request to Tenable API to add the risk recast rule
    $Rec = Invoke-WebRequest -Method 'POST' -ContentType "application/json" -Uri $Url -Headers $Headers -Body $Body

    # Output the HTTP status code (200 indicates success)
    $Rec.StatusCode

    # Get current date and time
    $dateTime = Get-Date

    # Convert current time to epoch time (seconds since 1/1/1970)
    $epochTime = [System.DateTimeOffset]::Now.ToUnixTimeSeconds()

    # Convert a specific date and time to epoch time
    $specificDateTime = Get-Date "2023-12-25 12:00:00"
    $specificEpochTime = [System.DateTimeOffset]::new($specificDateTime).ToUnixTimeSeconds()

    # Display epoch time values
    $epochTime
    $specificEpochTime

    # Convert current time to epoch time using alternate method
    [int][double]::Parse((Get-Date (get-date).touniversaltime() -UFormat %s))
}

# END block executes once after the PROCESS block
END {
    # Output a verbose message indicating script completion
    Write-Verbose "Done" -Verbose
}
