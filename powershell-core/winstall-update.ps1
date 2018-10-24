########################
# Windows 10 Updater
########################
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
Write-Host "Searching for updates please wait..."
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Hide-WindowsUpdate -Title "Bing*"
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install
Get-WURebootStatus
Read-Host "Press ENTER to exit"