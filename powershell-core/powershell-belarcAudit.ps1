#############################################
#	Title:      Belarc Audit			    #
#	Creator:	Ad3t0	                    #
#	Date:		04/16/2019             	    #
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
} $ver = "1.1.4"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = '       Belarc Audit Upload'
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
$user = Read-Host "Username"
$pass = Read-Host "Password"
$folderOrganize = Read-Host "Enter sub-folder name"
Clear-Host
if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
{ $output = "C:\Program Files (x86)\Belarc\BelarcAdvisor\System\tmp\($($env:COMPUTERNAME)).html"
	$belarcinstall = "C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
} else
{ $output = "C:\Program Files\Belarc\BelarcAdvisor\System\tmp\($($env:COMPUTERNAME)).html"
	$belarcinstall = "C:\Program Files\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
} Remove-Item $output > $null 2>&1
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco feature disable -n=checksumFiles
if (Test-Path $belarcinstall)
{.$belarcinstall
} else {
	choco install belarcadvisor
} choco install megatools
Remove-Item "C:\Users\Public\Desktop\Belarc Advisor.lnk" > $null 2>&1
while (!(Test-Path $output)) {
	Start-Sleep 10
} megamkdir "/Root/MEGAsync/Audit/$($folderOrganize)" -u $user -p $pass
megaput --path "/Root/MEGAsync/Audit/$($folderOrganize)" -u $user -p $pass $output
exit
