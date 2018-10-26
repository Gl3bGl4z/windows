##########################################
#	Title:      Windows 10 Update Script #
#	Creator:	Ad3t0	                 #
#	Date:		10/21/2018             	 #
##########################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}else
{	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}##############
$ver = "1.0.5"
Write-host "#####################################"
Write-Host "#                                   #"
Write-host "#       Windows 10 Update Script    #"
Write-host "#       Version: "$ver"	            #"
Write-Host "#                                   #"
Write-host "#####################################"
Write-host
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -confirm:$false
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name PSWindowsUpdate -confirm:$false
Clear-Host
Write-host "#####################################"
Write-Host "#                                   #"
Write-host "#       Windows 10 Update Script    #"
Write-host "#       Version: "$ver"	            #"
Write-Host "#                                   #"
Write-host "#####################################"
Write-host
$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" -computername $strComputer
foreach ($objItem in $colItems) {
    Write-Host
    Write-Host "CPU Model: " -foregroundcolor yellow -NoNewLine
    Write-Host $objItem.Name -foregroundcolor white
    Write-Host
}
while($confirmationupdate -ne "n" -and $confirmationupdate -ne "y")
{	
	$confirmationupdate = Read-Host "Begin installing all available Windows 10 updates? [y/n]"
}if($confirmationupdate -eq "y")
{Write-Host "Searching for updates please wait..."
	Import-Module PSWindowsUpdate
	$HideUpdatesArray=('*Bing*', '*Silverlight*')
	Hide-WindowsUpdate -KBArticleID $HideUpdatesArray -Confirm:$false
	# -Title "*Bing*"
	Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install
	Get-WURebootStatus
}Read-Host "Press ENTER to exit"
Exit