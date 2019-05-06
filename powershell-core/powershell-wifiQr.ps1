#############################################
#	Title:      Windows 10 WifiQR Script    #
#	Creator:	Ad3t0	                    #
#	Date:		11/06/2018             	    #
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
$ver = "1.1.3"
$data = netsh wlan show interfaces | Select-String SSID
if (!($data))
{ Write-Host "Not connected to wifi exiting..."
	Start-Sleep -s 5
	exit
} $datePattern = [regex]::new("(?<=SSID                   : ).*\S")
$matches = $datePattern.Matches($data)
$wifiprofile = $matches.Value
$wifiprofile = $wifiprofile.Substring(0,$wifiprofile.IndexOf(' '))
$data2 = netsh wlan show profile $wifiprofile key=clear
$datePattern2 = [regex]::new("(?<=Key Content            : ).*\S")
$matches2 = $datePattern2.Matches($data2)
$wifikey = $matches2.Value.Split(' ')[0]
$wifilink = "WIFI:S:$($wifiprofile);T:WPA;P:$($wifikey);;"
$wifilink = [uri]::EscapeDataString($wifilink)
$defaultbrowser = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "Progid" > $null 2>&1
$URL = "https://chart.googleapis.com/chart?chs=547x547&cht=qr&chld=H|4&choe=UTF-8&chl=$($wifilink)"
if ($defaultbrowser.ProgID -like "Firefox*")
{ Write-Host
	Write-Host "Opening Wifi access QR code in a private Firefox window..." -ForegroundColor yellow
	[System.Diagnostics.Process]::Start("firefox.exe","-private-window $URL") | Out-Null
} else
{ Write-Host
	Write-Host "Opening Wifi access QR code in an incognito Chrome window..." -ForegroundColor yellow
	[System.Diagnostics.Process]::Start("chrome.exe","--incognito $URL") | Out-Null
}
