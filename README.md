# AKS-RCS

This is a work in progress

The repo contains a Bicep module that deploys 2 AKS Clusters and prerequesite resources. A sample workload (Docker image, pushed to ACR) is then deployed into the Clusters in 2 seperate regions. (uksouth & northeurope)

Each cluster has an Application Gateway and Public IP ingress. There is the addition of a Globally redundant LB (FrontDoor) for directing traffic to either of the 2 App Gateways.

There are 3 RBAC Assignments to manage the clusters and ACR container image. (Currently the Service principal will need to be created manually and given the Contributor role scoped to target RG)

An Azure Function App is also deployed containing 2 PowerShell scripts via the "azure-deploy.yaml" workflow. These scripts are ran on a schedule which is defined in the Function App resouce block.

Get-PreferredLocation.ps1 will querry the "National Grid ESO - Carbon Intensity API" and return values that will influence Cluster configuration via passing returned variable the Update-AKS.ps1 script. The clusters should shutdown/auto-scale based on the return parameter from Get-PrefferdLocation and traffic should be pointed towards the favourable CI region. There should be no interruption to live sessions on the workload.

The deployment is run via Github Actions.

## Notes

AKS (Azure Container Service) -  is only currently offered in three regions and you are also currently unable to scale down to zero pods. The KEDA project builds on top of HPA and adds support for scale to zero. So workloads can be stopped when the carbon intensity is too high.
<https://github.com/Azure/carbon-aware-keda-operator>

Low Carbon Kubernetes Schedule/Heliotropic Scheduler.
<https://ceur-ws.org/Vol-2382/ICT4S2019_paper_28.pdf>
<https://devblogs.microsoft.com/sustainable-software/carbon-aware-kubernetes/>


