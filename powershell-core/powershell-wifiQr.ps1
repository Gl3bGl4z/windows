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
}$ver = "1.1.9"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = '       WifiQR Script'
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
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
$URL = "https://chart.googleapis.com/chart?chs=547x547&cht=qr&chld=H|4&choe=UTF-8&chl=$($wifilink)"
Write-Host
Write-Host "SSID: " -ForegroundColor Yellow -NoNewline
Write-Host $wifiprofile
Write-Host "KEY: " -ForegroundColor Yellow -NoNewline
Write-Host $wifikey
Write-Host
start $URL