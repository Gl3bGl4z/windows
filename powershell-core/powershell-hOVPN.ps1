#############################################
#	Title:      Private OVPN			    #
#	Creator:	Ad3t0	                    #
#	Date:		04/10/2019             	    #
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
} $ver = "1.3.2"
$text = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
 
    VPN Setup Script
'@
$text
$killProcess = Get-Process "openvpn-gui" -ErrorAction SilentlyContinue
if ($killProcess) {
	Stop-Process -Name "mstsc" > $null 2>&1
	Write-Host "Stopping VPN Processes..." -ForegroundColor Yellow
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --command disconnect_all
	Start-Sleep -s 20
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --command exit
} else
{ if ($env:Path -notlike "*;C:\ProgramData\powershell-bin*")
	{ Write-Host "Starting VPN Processes..." -ForegroundColor Yellow
		[Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path",[EnvironmentVariableTarget]::Machine) + ";C:\ProgramData\powershell-bin",[EnvironmentVariableTarget]::Machine)
	} New-Item -Path $env:ProgramData -Name "powershell-bin" -ItemType "directory" -Force > $null 2>&1
	if (!(Test-Path -Path "C:\Program Files\OpenVPN\config\client.ovpn"))
	{ $user = Read-Host "Username"
		$pass = Read-Host "Password"
		Clear-Host
		Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco feature enable -n=allowGlobalConfirmation
		choco feature disable -n=checksumFiles
		choco install openvpn megatools
		megaget --path "C:\Program Files\OpenVPN\config" -u $user -p $pass "/Root/MEGAsync/VPN/Home/client.ovpn"
	}
	if (!(Test-Path -Path "C:\Program Files\AutoHotkey\AutoHotkey.exe"))
	{
		choco install autohotkey
	}
	Remove-Item "C:\Users\Public\Desktop\OpenVPN GUI.lnk" > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OpenVPN" -Recurse > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TAP-Windows" -Recurse > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Gpg4win" -Recurse > $null 2>&1
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OPENVPN-GUI" > $null 2>&1
	Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenVPN" -Recurse > $null 2>&1
	Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\TAP-Windows" -Recurse > $null 2>&1
	Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GPG4Win" -Recurse > $null 2>&1
	Remove-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\GPG4Win" -Recurse > $null 2>&1
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/vpn.bat') | Out-File "C:\ProgramData\powershell-bin\vpn.bat" -Force -Encoding default
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/vpn.ahk') | Out-File "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\vpn.ahk" -Force -Encoding default
	$ahkProcess = Get-Process "AutoHotkey" -ErrorAction SilentlyContinue
	if (!$ahkProcess) {
		. "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\vpn.ahk"
	}
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --connect client.ovpn
	. 'C:\Windows\System32\mstsc.exe' /multimon
}
