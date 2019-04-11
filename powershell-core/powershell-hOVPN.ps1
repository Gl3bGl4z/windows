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
$ver = "1.0.2"
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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://github.com/Ad3t0/windows/raw/master/powershell-core/bin/7z.dll"
			$output = "$($env:TEMP)\winstall-core\7z.dll"
			$start_time = Get-Date
			Invoke-WebRequest -Uri $url -OutFile $output
			while (!(Test-Path $output)) {
				Start-Sleep 10 
			}
			
			$url = "https://github.com/Ad3t0/windows/raw/master/powershell-core/bin/7z.exe"
			$output = "$($env:TEMP)\winstall-core\7z.exe"
			$start_time = Get-Date
			Invoke-WebRequest -Uri $url -OutFile $output
			while (!(Test-Path $output)) {
				Start-Sleep 10 
			}
			
			$url = "https://github.com/Ad3t0/windows/raw/master/powershell-core/bin/config.zip"
			$output = "$($env:TEMP)\winstall-core\config.zip"
			$start_time = Get-Date
			Invoke-WebRequest -Uri $url -OutFile $output
			while (!(Test-Path $output)) {
				Start-Sleep 10 
			}
			
			.\7z.exe x config.zip
			Move-Item -Path "$($env:TEMP)\winstall-core\client.ovpn" -Destination "C:\Program Files\OpenVPN\config\client.ovpn"
			cd "C:\Program Files\OpenVPN\bin\"
.\openvpn-gui.exe