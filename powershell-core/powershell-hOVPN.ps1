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
} ##############
$ver = "1.2.0"
$killProcess = Get-Process "openvpn-gui" -ErrorAction SilentlyContinue
if ($killProcess) {
	Write-Host "Killing Processes..." -ForegroundColor red
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --command disconnect_all
	Start-Sleep -s 2
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --command exit
	Stop-Process -Name "mstsc"
	Start-Sleep -s 3
} else
{ if ($env:Path -notlike "*;C:\ProgramData\powershell-bin*")
	{ [Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path",[EnvironmentVariableTarget]::Machine) + ";C:\ProgramData\powershell-bin",[EnvironmentVariableTarget]::Machine)
	} New-Item -Path $env:ProgramData -Name "powershell-bin" -ItemType "directory" -Force > $null 2>&1
	if (!(Test-Path -Path "C:\Program Files\OpenVPN\config\client.ovpn"))
	{ Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco feature enable -n=allowGlobalConfirmation
		choco feature disable -n=checksumFiles
		choco install openvpn megatools
		Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenVPN" -Recurse $null 2>&1
		Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\TAP-Windows" -Recurse $null 2>&1
		Remove-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\GPG4Win" -Recurse $null 2>&1
		$user = Read-Host "Username"
		$pass = Read-Host "Password"
		Clear-Host
		megaget --path "C:\Program Files\OpenVPN\config" -u $user -p $pass "/Root/MEGAsync/VPN/Home/client.ovpn"
	} Remove-Item "C:\Users\Public\Desktop\OpenVPN GUI.lnk" > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TAP-Windows" -Recurse > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OpenVPN" -Recurse > $null 2>&1
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/vpn.bat') | Out-File "C:\ProgramData\powershell-bin\vpn.bat" -Force -Encoding default
	Write-Host "Starting Processes..." -ForegroundColor green
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --connect client.ovpn
	. 'C:\Windows\System32\mstsc.exe' /multimon
	Start-Sleep -s 3
} exit
