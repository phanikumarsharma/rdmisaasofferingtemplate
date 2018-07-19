Param(
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $SubscriptionId,
    [Parameter(Mandatory=$True)]
    [String] $Username,
    [Parameter(Mandatory=$True)]
    [string] $Password,
    [Parameter(Mandatory=$True)]
    [string] $VMResourceGroupName
 
)


$Securepass=ConvertTo-SecureString -String $Password -AsPlainText -Force
$Azurecred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList($Username, $Securepass)
$login=Login-AzureRmAccount -Credential $Azurecred

Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$ResourceGroup= Get-AzureRmResourceGroup -Name $VMResourceGroupName
if($ResourceGroup)
{
    Remove-AzureRmResourceGroup -Name $ResourceGroup -Force
}
