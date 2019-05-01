#############################################
#	Title:      Google Drivers Update Check #
#	Creator:	Ad3t0	                    #
#	Date:		05/01/2018             	    #
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
$ver = "1.0.0"
$systemmodel = wmic computersystem get model
$systemmodel = $systemmodel.Replace('Model','').Replace('  ','')
$systemmodel = $systemmodel + "Drivers"
$systemmodel = [uri]::EscapeDataString($systemmodel)
$URL = "https://www.google.com/search?q=$($systemmodel)"
$defaultbrowser = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "Progid"
if ($defaultbrowser.ProgID -like "Firefox*")
{ [System.Diagnostics.Process]::Start("firefox.exe"," $URL") | Out-Null
} elseif ($defaultbrowser.ProgID -like "Chrome*")
{ [System.Diagnostics.Process]::Start("chrome.exe"," $URL") | Out-Null
} else
{ start microsoft-edge:$($URL)
}
