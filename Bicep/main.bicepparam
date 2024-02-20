using './main.bicep'

// Parameters
param location1 = 'uksouth'
param location2 = 'northeurope'
// Networking
param vnet1 = 'vNet-01'
param subnet1 = 'Sub-01'
param vnet2 = 'vNet-02'
param subnet2 = 'Sub-02'
// AKS
param cluster1 = 'AKS-Cluster-01'
param cluster2 = 'AKS-Cluster-02'
param aksNodeCount = 1
param aksNodeSize = 'Standard_D2s_v3'
param acrName = 'azaksrcscontainerreg'
param aksClusterFQDN1 = 'aks-cluster1-region1'
param aksClusterFQDN2 = 'aks-cluster1-region2'
// App Gateways
param appGatewayName1 = 'AKS-AppGW1'
param appGWVnetName1 = 'AppGW-vNet1'
param appGWSubName1 = 'AppGW-Sub1'
param appGatewayName2 = 'AKS-AppGW2'
param appGWVnetName2 = 'AppGW-vNet2'
param appGWSubName2 = 'AppGW-vNet1'
param publicIpName1 = 'AppGw-IP1'
param publicIpName2 = 'AppGw-IP2'
param publicIpAllocationMethod = 'Static'
// Front Door
// param frontDoorProfileName = ''
// param frontDoorSkuName = ''
// param frontDoorEndpointName = ''
// param frontDoorOriginGroupName = ''
// param frontDoorOriginName = ''
// param frontDoorRouteName = ''
// RBAC
@secure()
param clientId = 'dfb5963a-600d-43da-b61e-2109e1de97f2'
@secure()
param clientSecret = 'ftn8Q~KxcNwGz1NzFtTP5dvxTchtcm2tOznxHcJj'
param roleDefId = '/providers/Microsoft.Authorization/roleDefinitions/fd036e6b-1266-47a0-b0bb-a05d04831731'
param roleDefId2 = '/providers/Microsoft.Authorization/roleDefinitions/641177b8-a67a-45b9-a033-47bc880bb21e'
param roleDefId3 = '/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
param principalType = 'ServicePrincipal'
// Function App
param appName = 'AKS-RCS'
param scriptFile = 'AKS-RCS/Scripts/PS1/run.ps1'
// param storageAccountName = 'aksrcssa'
// param containerName = 'jamesScriptContainer'
