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
$ver = "1.1.7"
$killProcess = Get-Process "openvpn-gui" -ErrorAction SilentlyContinue
if ($killProcess) {
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --command disconnect_all
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --command exit
	Stop-Process -Name "mstsc"
} else
{ if ($env:Path -notlike "*;C:\ProgramData\powershell-bin*")
	{ [Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path",[EnvironmentVariableTarget]::Machine) + ";C:\ProgramData\powershell-bin",[EnvironmentVariableTarget]::Machine)
	} New-Item -Path $env:ProgramData -Name "powershell-bin" -ItemType "directory" -Force > $null 2>&1
	if (!(Test-Path -Path "C:\Program Files\OpenVPN\config\client.ovpn"))
	{ Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco feature enable -n=allowGlobalConfirmation
		choco feature disable -n=checksumFiles
		choco install openvpn megatools
		$user = Read-Host "Username"
		$pass = Read-Host "Password"
		megaget --path "C:\Program Files\OpenVPN\config" -u $user -p $pass "/Root/MEGAsync/VPN/Home/client.ovpn"
	} Remove-Item "C:\Users\Public\Desktop\OpenVPN GUI.lnk" > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TAP-Windows" -Recurse > $null 2>&1
	Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OpenVPN" -Recurse > $null 2>&1
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/vpn.bat') | Out-File "C:\ProgramData\powershell-bin\vpn.bat" -Force -Encoding default
	. 'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --connect client.ovpn
	. 'C:\Windows\System32\mstsc.exe' /multimon
} exit
