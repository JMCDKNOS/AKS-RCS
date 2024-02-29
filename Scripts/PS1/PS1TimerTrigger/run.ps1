param($Timer)

Set-StrictMode -Version 3.0

[string]$functionName = $MyInvocation.MyCommand
[DateTime]$startTime = [DateTime]::UtcNow

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Get the current universal time in the default string format
[datetime]$currentUTCtime = (Get-Date).ToUniversalTime()

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

function Get-PreferredLocation {
    [CmdletBinding()]
    param (
        [String]
        $URI = "https://api.carbonintensity.org.uk/intensity",
        [String]
        $REGIONURI = "https://api.carbonintensity.org.uk/regional/regionid"
    )

    [array]$regionList = @(
        [hashtable]@{regionID="1";shortName="North Europe"},
        [hashtable]@{regionID="12";shortName="UK South"}
    )

    [double]$lowestIntensity = [double]::MaxValue
    [string]$PreferredLocation = ""

    $regionList | ForEach-Object {
        $TMP = curl -X GET "$REGIONURI/$($_.regionID)" --no-progress-meter | ConvertFrom-Json
        $forecastIntensity = $TMP.data.data.intensity.forecast

        Write-Host "The forecast carbon intensity for $($_.shortname) is $forecastIntensity"

        if ($forecastIntensity -lt $lowestIntensity) {
            $lowestIntensity = $forecastIntensity
            $PreferredLocation = $_.shortName
        }
    }

    Write-Host "$PreferredLocation is the preferred location for deployment based on carbon intensity with an intensity number of $lowestIntensity"

    Update-AKS -PreferredLocation $PreferredLocation # Pass the preferred location value
}

function Update-AKS{
    param (
        [String] $PreferredLocation
    )

    $aksClusters = @{
        "North Europe" = "AKS-Cluster-01"
        "UK South" = "AKS-Cluster-02"
        # Add more regions and associated AKS cluster names here
    }

    if (-not $aksClusters.ContainsKey($PreferredLocation)) {
        Write-Host "Preferred location '$PreferredLocation' is not valid."
        Exit
    }

    $preferredCluster = $aksClusters[$PreferredLocation]

    # Stop the AKS clusters that are not in the preferred location
    $aksClusters.GetEnumerator() | Where-Object { $_.Key -ne $PreferredLocation } | ForEach-Object {
        $clusterName = $_.Value
        if ($clusterName -ne $preferredCluster) {
            # Stop the AKS cluster
            az aks stop --name $clusterName --resource-group rg-aks-rcs
        }
    }
}

try {
    Write-Host @"


RRRRRRRR     CCCCCC     SSSSS
RRR    RR  CCC    CC  SSS    SS
RRR    RR  CCC        SSS
RRRRRRRR   CCC          SSS
RRR  RR    CCC             SSS
RRR   RR   CCC    CC  SS    SSS
RRR    RR    CCCCCC     SSSSS

"@
    
    Get-PreferredLocation
}
finally {
    [DateTime]$endTime = [DateTime]::UtcNow
    [Timespan]$duration = $endTime.Subtract($startTime)

    Write-Host "${functionName} finished at $($endTime.ToString('u')) (duration $($duration -f 'g'))"
}
