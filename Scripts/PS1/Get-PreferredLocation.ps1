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
