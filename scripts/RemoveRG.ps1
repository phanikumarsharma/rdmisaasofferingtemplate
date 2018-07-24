param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string]
  $SubscriptionId,

  [Parameter(Position = 1, Mandatory = $true)]
  [string]
  $vmResourceGroupName
)
$ErrorAction = 'Stop'

$null = Set-AzureRmContext -SubscriptionId $SubscriptionId

@(
  'Microsoft.Compute/virtualMachineScaleSets'
  'Microsoft.Compute/virtualMachines'
  'Microsoft.Storage/storageAccounts'
  'Microsoft.Compute/availabilitySets'
  'Microsoft.ServiceBus/namespaces'
  'Microsoft.Network/connections'
  'Microsoft.Network/virtualNetworkGateways'
  'Microsoft.Network/loadBalancers'
  'Microsoft.Network/networkInterfaces'
  'Microsoft.Network/publicIPAddresses'
  'Microsoft.Network/networkSecurityGroups'
  'Microsoft.Network/virtualNetworks'

  '*' # this will remove everything else in the resource group regarding of resource type
) | % {
  $odataQuery = "`$filter=resourcegroup eq '$vmResourceGroupName'"

  if ($_ -ne '*') {
    $odataQuery += " and resourcetype eq '$_'"
  }

  $resources = Get-AzureRmResource -ODataQuery $odataQuery
  $resources | Where-Object { $_.ResourceGroupName -eq $vmResourceGroupName } | % { 
    Write-Host ('Processing {0}/{1}' -f $_.ResourceType, $_.ResourceName)
    $_ | Remove-AzureRmResource -Verbose -Force
  }
}