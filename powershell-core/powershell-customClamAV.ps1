#############################################
#	Title:      ClamAV Custom Install       #
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
} $ver = "1.0.0"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = "    ClamAV Custom Settings"
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
Write-Host
if (!(Test-Path "$($env:ProgramFiles)\ClamAV-x64"))
{ Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature disable -n=checksumFiles
	choco install clamav bleachbit
	. "$($env:ProgramData)\chocolatey\lib\clamav\tools\Setup-x64.msi" /quiet
} while ($recycleConfirm -ne "n" -and $recycleConfirm -ne "y")
{ $recycleConfirm = Read-Host "Clean Recycle Bin and temp directories first? [y/n]"
}
Write-Host "Select scan directory"
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
$show = $objForm.ShowDialog()
$modPath = $objForm.SelectedPath
if ($recycleConfirm -eq "y")
{. "$($env:ProgramFiles) (x86)\BleachBit\bleachbit_console.exe" -c deepscan.tmp system.logs system.memory_dump system.muicache system.prefetch system.recycle_bin system.tmp system.updates
} while (!(Test-Path "$($env:ProgramFiles)\ClamAV-x64\conf_examples\clamd.conf.sample")) {
	Start-Sleep 10
} New-Item -Path "$($env:ProgramFiles)\ClamAV-x64" -Name "database" -ItemType "directory" > $null 2>&1
Copy-Item "$($env:ProgramFiles)\ClamAV-x64\conf_examples\clamd.conf.sample" -Destination "$($env:ProgramFiles)\ClamAV-x64\clamd.conf"
Copy-Item "$($env:ProgramFiles)\ClamAV-x64\conf_examples\freshclam.conf.sample" -Destination "$($env:ProgramFiles)\ClamAV-x64\freshclam.conf"
(Get-Content "$($env:ProgramFiles)\ClamAV-x64\freshclam.conf").Replace('Example','') | Set-Content "$($env:ProgramFiles)\ClamAV-x64\freshclam.conf"
(Get-Content "$($env:ProgramFiles)\ClamAV-x64\clamd.conf").Replace('Example','').Replace('#TCPSocket','TCPSocket').Replace('#MaxThreads','MaxThreads').Replace('#DetectPUA','DetectPUA').Replace('#LogFile /tmp/clamd.log','LogFile C:\clamd.log') | Set-Content "$($env:ProgramFiles)\ClamAV-x64\clamd.conf"
. "$($env:ProgramFiles)\ClamAV-x64\freshclam.exe"
. "$($env:ProgramFiles)\ClamAV-x64\clamscan.exe" $modPath -r
Read-Host "DONE"
