param
(
      [Parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $SubscriptionId,

      [Parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $ResourceGroupName,

      [Parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $UserName,

      [Parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $Password

)

try
{

    $LoadModule=Get-Module -ListAvailable "Azure*"
    if(!$LoadModule){
    Install-PackageProvider NuGet -Force
    Install-Module -Name AzureRM.profile -AllowClobber -Force
    Install-Module -Name AzureRM.resources -AllowClobber -Force
    }
    Import-Module AzureRM.profile
    Import-Module AzureRM.Compute

    $Securepass=ConvertTo-SecureString -String $Password -AsPlainText -Force
    $Azurecred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList($UserName, $Securepass)
    $login=Login-AzureRmAccount -Credential $Azurecred -SubscriptionId $SubscriptionId

    #Select the AzureRM Subscription

    Write-Output "Selecting Azure Subscription.."
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId

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
      $odataQuery = "`$filter=resourcegroup eq '$ResourceGroupName'"

      if ($_ -ne '*') {
        $odataQuery += " and resourcetype eq '$_'"
      }

      $resources = Get-AzureRmResource -ODataQuery $odataQuery
      $resources | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName } | % { 
        Write-Host ('Processing {0}/{1}' -f $_.ResourceType, $_.ResourceName)
        $_ | Remove-AzureRmResource -Verbose -Force
      }
    }
}
catch [Exception]
{
    Write-Output $_.Exception.Message
}