###########################################################################
# 
# Windows 10 Updater
#
##########################################################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}
else
{
	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}
##############

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location $dir

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

Copy-Item "$dir\PSWindowsUpdate" -Destination "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\" -Recurse -Force

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}
else
{
	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}
##############

Copy-Item "C:\Users\Win10\Desktop\powershell\bin\PSWindowsUpdate" -Destination "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\PSWindowsUpdate\" -Recurse

Import-Module PSWindowsUpdate

#Read-Host "install"

Get-WUInstall -AcceptAll

Write-Host "Finished looking for updates."

Get-WURebootStatus

Read-Host "Press ENTER to exit."