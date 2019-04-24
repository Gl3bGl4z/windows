#############################################
#	Title:      MalwareBytes Custom Install #
#	Creator:	Ad3t0	                    #
#	Date:		04/04/2019             	    #
#############################################
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal ($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{ $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	Clear-Host
} else
{ $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
} ##############
$ver = "1.0.0"
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco feature disable -n=checksumFiles
choco install malwarebytes
(Get-Content -Path C:\ProgramData\Malwarebytes\MBAMService\config\PoliciesConfig.json -Raw) -replace '"ShowRealTimeNotification" : true','"ShowRealTimeNotification" : false'
(Get-Content -Path C:\ProgramData\Malwarebytes\MBAMService\config\PoliciesConfig.json -Raw) -replace '"NotifyWhenFullUpdatesAvailable" : true','"NotifyWhenFullUpdatesAvailable" : false'
#(Get-Content -path C:\ProgramData\Malwarebytes\MBAMService\config\PoliciesConfig.json -Raw) -replace '"NotifyWhenFullUpdatesAvailable" : true','"NotifyWhenFullUpdatesAvailable" : false'
