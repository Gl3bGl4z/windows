#############################################
#	Title:      Private OVPN			    #
#	Creator:	Ad3t0	                    #
#	Date:		04/10/2019             	    #
#############################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	clear-host
}else
{	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}##############
$ver = "1.0.7"
if(!(Test-Path -Path "C:\Program Files\OpenVPN\config\client.ovpn" ))
{Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco feature disable -n=checksumFiles
choco install openvpn megatools
Remove-Item "C:\Users\Public\Desktop\OpenVPN GUI.lnk" >$null 2>&1
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TAP-Windows" -Recurse >$null 2>&1
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OpenVPN" -Recurse >$null 2>&1
$user = Read-Host "Username"
$pass = Read-Host "Password"
megaget --path "C:\Program Files\OpenVPN\config" -u $user -p $pass "/Root/MEGAsync/VPN/Home/client.ovpn"
Write-Host "VPN install completed exiting in 10 seconds..." -ForegroundColor Green
.'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --connect client.ovpn
.'C:\Windows\System32\mstsc.exe' /multimon
Start-Sleep -s 10
}else
{.'C:\Program Files\OpenVPN\bin\openvpn-gui.exe' --connect client.ovpn
.'C:\Windows\System32\mstsc.exe' /multimon
}Exit