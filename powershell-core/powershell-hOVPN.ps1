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
$ver = "1.0.4"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco feature disable -n=checksumFiles
choco install openvpn
Remove-Item "C:\Users\Public\Desktop\OpenVPN GUI.lnk"
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TAP-Windows" -Recurse
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OpenVPN" -Recurse
if(!(Test-Path -Path "$($env:TEMP)\winstall-core\" ))
{New-Item -Path $env:TEMP -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1
}Set-Location "$($env:TEMP)\winstall-core"		
$url = "http://github.com/Ad3t0/windows/raw/master/powershell-core/bin/7z.dll" 
			$path = "$($env:TEMP)\winstall-core\7z.dll" 
			if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) { 
	$targetFile = Join-Path $pwd (Split-Path -leaf $path) 
} 
(New-Object Net.WebClient).DownloadFile($url, $path) 
$path
$url = "http://github.com/Ad3t0/windows/raw/master/powershell-core/bin/7z.exe" 
$path = "$($env:TEMP)\winstall-core\7z.exe" 
if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) { 
	$targetFile = Join-Path $pwd (Split-Path -leaf $path) 
} 
(New-Object Net.WebClient).DownloadFile($url, $path) 
$path
$url = "http://github.com/Ad3t0/windows/raw/master/powershell-core/bin/config.zip" 
$path = "$($env:TEMP)\winstall-core\config.zip" 
if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) { 
	$targetFile = Join-Path $pwd (Split-Path -leaf $path) 
} 
(New-Object Net.WebClient).DownloadFile($url, $path) 
.\7z.exe x config.zip
Move-Item -Path "$($env:TEMP)\winstall-core\client.ovpn" -Destination "C:\Program Files\OpenVPN\config\client.ovpn"
cd "C:\Program Files\OpenVPN\bin\"
.\openvpn-gui.exe