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
