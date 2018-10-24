#############################################
#	Title:      Windows 10 Benchmark Script #
#	Creator:	Ad3t0	                    #
#	Date:		10/24/2018             	    #
#############################################
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
$ver = "1.0"
Write-host "######################################"
Write-host "#       Windows 10 Benchmark Script  #"
Write-host "#       Version: "$ver"	             #"
Write-host "######################################"
Write-host
Write-host
Install-Module -Name Benchmark
Import-Module Benchmark
while($confirmationupdate -ne "n" -and $confirmationupdate -ne "y")
{	
	$confirmationupdate = Read-Host "Run Windows 10 CPU benchmark? [y/n]"
}if($confirmationupdate -eq "y")
{Write-Host "Running benchmark please wait..."
Measure-These -Count 5 -ScriptBlock { sleep 1 }, { sleep 2 }, { sleep 5 } -Title '1 second', '2 seconds', '5 seconds' | Format-Table -AutoSize

}Read-Host "Press ENTER to exit"
Exit