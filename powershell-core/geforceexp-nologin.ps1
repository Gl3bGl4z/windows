#########################################################
#	Title:      Disable Forced Geforce Experience Login #
#	Creator:	Ad3t0	                                #
#	Date:		10/21/2018             	                #
#########################################################
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
}#####
$ver = "1.0"
Write-host "##################################################"
Write-host "#       Disable Forced Geforce Experience Login  #"
Write-host "#       Version: "$ver"	                         #"
Write-host "##################################################"
Write-host
Write-host
while($confirmationgef -ne "n" -and $confirmationgef -ne "y")
{	
	$confirmationgef = Read-Host "Disable the forced Geforce Experience login? [y/n]"
}if($confirmationgef -eq "y")
{	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$url = "https://github.com/Moyster/BaiGfe/raw/master/app.js"
	$output = "$($env:ProgramW6432)\NVIDIA Corporation\NVIDIA GeForce Experience\www\app.js"
	$start_time = Get-Date
	Invoke-WebRequest -Uri $url -OutFile $output
	Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}Read-Host "Press any key to exit"
Exit