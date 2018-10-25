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
$ver = "1.1"
Write-host "#########################################"
Write-host "#       Windows 10 Benchmark Script     #"
Write-host "#       Version: "$ver"	                #"
Write-host "#########################################"
Write-host
New-Item -Path $env:TEMP -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1
Set-Location "$($env:TEMP)\winstall-core"
while($confirmationupdate -ne "n" -and $confirmationupdate -ne "y")
{	
	$confirmationupdate = Read-Host "Run Windows 10 CPU benchmark? [y/n]"
	Write-host
}if($confirmationupdate -eq "y")
{Write-Host "Running benchmark please wait..."
	Write-host
	if(!(Test-Path -Path "$($env:TEMP)\winstall-core\bench.exe" ))
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$url = "https://github.com/Ad3t0/windows/raw/master/powershell-core/bin/bench.exe"
		$output = "$($env:TEMP)\winstall-core\bench.exe"
		$start_time = Get-Date
		Invoke-WebRequest -Uri $url -OutFile $output
		#Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
	}
	./bench multithread
}Read-Host "Press ENTER to exit"
Exit