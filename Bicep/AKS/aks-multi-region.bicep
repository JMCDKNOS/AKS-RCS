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
param scriptFile string
param storageAccountName string
param containerName string 

// Networking
resource aksVnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet1
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.1.0.0/16' ]
    }
  }
}
resource aksSubnet1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: subnet1
  parent: aksVnet1
  properties: {
    addressPrefix: '10.1.1.0/24'
  }
}
resource aksVnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet2
  location: location2
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.2.0.0/16' ]
    }
  }
}
resource aksSubnet2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: subnet2
  parent: aksVnet2
  properties: {
    addressPrefix: '10.2.1.0/24'
  }
}
resource appGWVnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: appGWVnetName1
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.2.0.0/16' ]
    }
  }
}
resource appGWSub1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: appGWSubName1
  parent: appGWVnet1
  properties: {
    addressPrefix: '10.2.1.0/24'
  }
}
resource appGWVnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: appGWVnetName2
  location: location2
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.2.0.0/16' ]
    }
  }
}
resource appGWSub2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: appGWSubName2
  parent: appGWVnet2
  properties: {
    addressPrefix: '10.2.1.0/24'
  }
}
// AKS Clusters - horizontal auto-scaling?
resource aksCluster1 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  dependsOn: [
    aksVnet1
  ]
  name: cluster1
  location: location1
  properties: {
    dnsPrefix: 'mydnsprefix'
    kubernetesVersion: '1.27'
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    servicePrincipalProfile: {
      clientId: clientId
      secret: clientSecret
    }
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: aksNodeCount
        vmSize: aksNodeSize
        mode: 'System'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.244.0.0/16'
      serviceCidr: '10.0.0.0/16'
      dockerBridgeCidr: '172.17.0.1/16'
    }
  }
}
resource aksCluster2 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  dependsOn: [
    aksVnet2
  ]
  name: cluster2
  location: location2
  properties: {
    dnsPrefix: 'mydnsprefix'
    kubernetesVersion: '1.27'
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    servicePrincipalProfile: {
      clientId: clientId
      secret: clientSecret
    }
    agentPoolProfiles: [
      {
        name: 'nodepool2'
        count: aksNodeCount
        vmSize: aksNodeSize
        mode: 'System'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.245.0.0/16'
      serviceCidr: '10.0.0.0/16'
      dockerBridgeCidr: '172.18.0.1/16'
    }
  }
}
// Azure Container registry (workload)
resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: acrName
  location: location1
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: true
  }
}
// Role Assignments
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('AKSClusterAdminAssignment')
  properties: {
    principalId: clientId
    principalType: principalType
    roleDefinitionId: roleDefId
  }
}
resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('AppAssignment')
  properties: {
    principalId: clientId
    principalType: principalType
    roleDefinitionId: roleDefId2
  }
}
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('acrPullAssignment')
  properties: {
    principalId: clientId
    principalType: principalType
    roleDefinitionId: roleDefId3

  }
}
// App Gateway - Location1
resource publicIp1 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName1
  location: location1
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
}
resource appGateway1 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: appGatewayName1
  location: location1
  dependsOn: [
    aksVnet1
  ]
  properties: {
    sku: {
      capacity: 2
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'AKS-AppGW1-IpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', appGWVnetName1, appGWSubName1)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'AppGW-FeIP1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIpName1)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'AppGW-FePort1'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: aksClusterFQDN1
            }
            {
              fqdn: aksClusterFQDN2
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings'
        properties: {
          port: 8080
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName1, 'AppGW-FeIP1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName1, 'AppGW-FePort1')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName1, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName1, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName1, 'backendHttpSettings')
          }
        }
      }
    ]
  }
}
// App Gateway - Location2
resource publicIp2 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName2
  location: location2
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
}
resource appGateway2 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: appGatewayName2
  location: location2
  dependsOn: [
    aksVnet2
  ]
  properties: {
    sku: {
      capacity: 2
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'AKS-AppGW-IpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', appGWVnetName2, appGWSubName2)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'AppGW-FeIP2'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIpName2)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'AppGW-FePort2'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: aksClusterFQDN1
            }
            {
              fqdn: aksClusterFQDN2
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings'
        properties: {
          port: 8080
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName2, 'AppGW-FeIP2')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName2, 'AppGW-FePort2')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName2, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName2, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName2, 'backendHttpSettings')
          }
        }
      }
    ]
  }
}
// Azure FrontDoor (Global redundant LB for App Gw's)
// resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
//   name: frontDoorProfileName
//   location: 'global'
//   sku: {
//     name: frontDoorSkuName
//   }
// }
// resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
//   name: frontDoorEndpointName
//   parent: frontDoorProfile
//   location: 'global'
//   properties: {
//     enabledState: 'Enabled'
//   }
// }
// resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
//   name: frontDoorOriginGroupName
//   parent: frontDoorProfile
//   properties: {
//     loadBalancingSettings: {
//       sampleSize: 4
//       successfulSamplesRequired: 3
//     }
//     healthProbeSettings: {
//       probePath: '/'
//       probeRequestType: 'HEAD'
//       probeProtocol: 'Http'
//       probeIntervalInSeconds: 100
//     }
//   }
// }
// resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
//   name: frontDoorOriginName
//   parent: frontDoorOriginGroup
//   properties: {
//     // hostName: app.properties.defaultHostName
//     httpPort: 80
//     httpsPort: 443
//     // originHostHeader: app.properties.defaultHostName
//     priority: 1
//     weight: 1000
//   }
// }
// resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
//   name: frontDoorRouteName
//   parent: frontDoorEndpoint
//   dependsOn: [
//     frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
//   ]
//   properties: {
//     originGroup: {
//       id: frontDoorOriginGroup.id
//     }
//     supportedProtocols: [
//       'Http'
//       'Https'
//     ]
//     patternsToMatch: [
//       '/*'
//     ]
//     forwardingProtocol: 'HttpsOnly'
//     linkToDefaultDomain: 'Enabled'
//     httpsRedirect: 'Enabled'
//   }
// }
// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location1
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storageAccount
  name: 'default'
}
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}
// Function App 
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-AppSericePlan'
  location: location1
  kind: 'FunctionApp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${appName}-FunctionApp'
  location: location1
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
        {
          name: 'SCRIPT_URL'
          value: scriptFile
        }
      ]
    }
  }
}
resource function 'Microsoft.Web/sites/functions@2021-02-01' = {
  parent: functionApp
  name: 'myFunction'
  properties: {
    config: {
      scriptFile: scriptFile
      bindings: [
        {
          name: 'timerTrigger'
          type: 'timerTrigger'
          direction: 'in'
          schedule: '0 */60 * * * *' // Cron expression for every 60 minutes, adjust as needed
        }
      ]
    }
  }
}
// AppInsights 
resource azAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-AppInsights'
  location: location1
  kind: 'web'
  properties:{
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}
