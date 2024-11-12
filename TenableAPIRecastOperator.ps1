#Pete Lenhart 11/12/2024
#Operator script to update recasts in Tenable using PowerShell
#You need to save your API access key and secret into the Secret Store Module.  

[CmdletBinding()]
Param
(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoID = "1",
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^\d+$')]
        [ValidateNotNullOrEmpty()]
        [string]$plugin_id,
        [Parameter(Mandatory = $true)]
        [ValidateSet("0", "1", "2", "3", "4")]
        [string]$sev_value,
        [Parameter(Mandatory = $true)]
        [ValidateSet("ip" , "all")]
        [string]$hostType,
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$')]
        [string]$hostvalue,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$port,
        [Parameter(Mandatory = $true, HelpMessage = " Blank = UDP, 1 = ICMP, 6 = TCP, any = any, 0  = Unknown")]
        [ValidateSet(" ", "1", "6", "any", "0")] 
        [string]$protocol,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$comment    
    )
BEGIN {

#INFO#
#GET ACCESS KEY AND SECRET KEY FROM SECRET STORE
$AK = Get-Secret -Name TenableAccessKey -AsPlainText
$SK = Get-Secret -Name TenableSecretKey -AsPlainText
$headers = @{ "x-apikey" = "accesskey=$AK; secretkey=$SK;" }
}

PROCESS{

function Get-RepoID ($assetgroup){
switch ($assetgroup) {
"Tenable" {$return = "1"}
"Agent" {$return = "2"}
"TenableRepo" {$return = "1"}
"Tenable.IO" {$return = "2"}
"Network" {$return = "1"}
"IO" {$return = "2"}
default {write-error "Repository`"$Repository`" not found."; $return = $null}
}
return $return
}
#########################################

###############Get Recast###############
$Url = "https://<YOUR TENABLE SC SERVER>/rest/recastRiskRule?pluginID=$plugin_id&repositoryIDs=$repoid"
$ExpireDate = '04/04/2025'
$ExpireDate = (get-date -Date $ExpireDate).AddHours(+5)
$expiration_date = Get-Date $ExpireDate -UFormat %s
########################

Write-Host "Adding Risk Recast for Plugin ID" + $plugin_id + "to Repository ID" + $RepoID + "to Severity"  + $sev_value + "For Hosts" + $hostvalue
$Body = @{"repositories"=@(@{"id"="$repoid"});"plugin"=@{"id"="$plugin_id"};"newSeverity"=@{"id"="$sev_value"};"hostType"="$hostType";"hostValue"="$hostvalue";"port"="$port";"protocol"="$protocol";"expires"="$expiration_date";"comments"="$comment"} | ConvertTo-Json
$Rec = Invoke-WebRequest -Method 'POST' -ContentType "application/json" -Uri $Url -Headers $Headers -Body $Body
# Should print a 200 if it is successful
$Rec.StatusCode

$dateTime = Get-Date
# Convert to Epoch time (seconds since 1/1/1970)
$epochTime = [System.DateTimeOffset]::Now.ToUnixTimeSeconds()

# Or, convert a specific date and time to Epoch time
$specificDateTime = Get-Date "2023-12-25 12:00:00"
$specificEpochTime = [System.DateTimeOffset]::new($specificDateTime).ToUnixTimeSeconds()

# Display the results
$epochTime
$specificEpochTime
[int][double]::Parse((Get-Date (get-date).touniversaltime() -UFormat %s))
}
END{
Write-Verbose "Done" -Verbose
}
