// Parameters
param location1 string
param location2 string
// Networking
param vnet1 string
param subnet1 string
param vnet2 string
param subnet2 string
// AKS
param cluster1 string
param cluster2 string
param aksNodeCount int
param aksNodeSize string
param acrName string
param aksClusterFQDN1 string
param aksClusterFQDN2 string
// App Gateways
param appGatewayName1 string
param appGWVnetName1 string
param appGWSubName1 string
param appGatewayName2 string
param appGWVnetName2 string
param appGWSubName2 string
param publicIpName1 string
param publicIpName2 string
param publicIpAllocationMethod string
// Front Door
// param frontDoorProfileName string
// param frontDoorSkuName string
// param frontDoorEndpointName string
// param frontDoorOriginGroupName string
// param frontDoorOriginName string
// param frontDoorRouteName string
// RBAC
@secure()
param clientId string
@secure()
param clientSecret string
param roleDefId string
param roleDefId2 string
param roleDefId3 string
param principalType string
// Function App
param appName string
param scriptFileURL string
param storageAccountName string


// Module
module aksmultiregion './aks-multi-region.bicep' = {
  name: 'aks-multi-region'
  params: {
    location1: location1
    location2: location2
    // Networking
    vnet1: vnet1
    subnet1: subnet1
    vnet2: vnet2
    subnet2: subnet2
    // AKS
    cluster1: cluster1
    cluster2: cluster2
    aksNodeCount: aksNodeCount
    aksNodeSize: aksNodeSize
    acrName: acrName
    aksClusterFQDN1: aksClusterFQDN1
    aksClusterFQDN2: aksClusterFQDN2
    // App Gateways
    appGatewayName1: appGatewayName1
    appGWVnetName1: appGWVnetName1
    appGWSubName1: appGWSubName1
    appGatewayName2: appGatewayName2
    appGWVnetName2: appGWVnetName2
    appGWSubName2: appGWSubName2
    publicIpName1: publicIpName1
    publicIpName2: publicIpName2
    publicIpAllocationMethod: publicIpAllocationMethod
    // Front Door
    // frontDoorProfileName: frontDoorProfileName
    // frontDoorSkuName: frontDoorSkuName
    // frontDoorEndpointName: frontDoorEndpointName
    // frontDoorOriginGroupName: frontDoorOriginGroupName
    // frontDoorOriginName: frontDoorOriginName
    // frontDoorRouteName: frontDoorRouteName
    // RBAC
    clientId: clientId
    clientSecret: clientSecret
    roleDefId: roleDefId
    roleDefId2: roleDefId2
    roleDefId3: roleDefId3
    principalType: principalType
    // Function App
    appName: appName
    scriptFileURL: scriptFileURL
    storageAccountName: storageAccountName
  }
}
