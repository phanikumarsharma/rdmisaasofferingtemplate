Param(
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $SubscriptionId,
    [Parameter(Mandatory=$True)]
    [String] $UserName,
    [Parameter(Mandatory=$True)]
    [string] $Password,
     [Parameter(Mandatory=$True)]
    [string] $ResourceGroupName
 
)

$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

$LoadModule=Get-Module -ListAvailable "Azure*"
if(!$LoadModule){
Install-PackageProvider NuGet -Force
Install-Module -Name AzureRM.profile -AllowClobber -Force
Install-Module -Name AzureRM.resources -AllowClobber -Force
Install-Module -Name AzureRM.Compute -AllowClobber -Force
}
Import-Module AzureRM.profile
Import-Module AzureRM.resources
Import-Module AzureRM.Compute

        try{
        $Securepass=ConvertTo-SecureString -String $Password -AsPlainText -Force
        $Azurecred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList($UserName, $Securepass)
        $login=Login-AzureRmAccount -Credential $Azurecred -SubscriptionId $SubscriptionId
        Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
                       
        }
        catch{
        Write-Error $_.Exception.Message
        }