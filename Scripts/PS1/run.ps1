-UseWindowsPowershell

[CmdletBinding()]
param (
    [String]
    $URI = "https://api.carbonintensity.org.uk/intensity",
    [String]
    $REGIONURI = "https://api.carbonintensity.org.uk/regional/regionid"
)

$regionList = @(
    [pscustomobject]@{regionID="1";shortName="North Europe"},
    [pscustomobject]@{regionID="12";shortName="UK South"}
)

function getRegionalIntensity() {
    $lowestIntensity = [double]::MaxValue
    $preferredLocation = ""

    $regionList | ForEach-Object {
        $TMP = curl -X GET "$REGIONURI/$($_.regionID)" --no-progress-meter | ConvertFrom-Json
        $forecastIntensity = $TMP.data.data.intensity.forecast

        Write-Host "The forecast carbon intensity for $($_.shortname) is $forecastIntensity"

        if ($forecastIntensity -lt $lowestIntensity) {
            $lowestIntensity = $forecastIntensity
            $preferredLocation = $_.shortName
        }
    }

    Write-Host "$preferredLocation is the preferred location for deployment based on carbon intensity with an intensity number of $lowestIntensity"

    .\Update-AKS.ps1 -PreferredLocation $preferredLocation # Pass the preferred location value
}

getRegionalIntensity

#####################################

param (
    [String]
    $PreferredLocation
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
