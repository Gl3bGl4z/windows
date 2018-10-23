###########################################################################
# 
# Windows 10 Setup Script
#
##########################################################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}
else
{
	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}
##############




Write-Host "#############################"
Write-Host "#                           #"
Write-Host "#  Windows 10 Setup Script  #"
Write-Host "#                           #"
Write-Host "#############################"
Write-Host


New-Item -Path $env:TEMP -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1

Set-Location "$($env:TEMP)\winstall-core"

if(!(Test-Path -Path "$($env:TEMP)\winstall-core\chocolist.txt" ))
{
	Write-Host "chocolist.txt not found"
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/chocolist.txt') | out-file "$($env:TEMP)\winstall-core\chocolist.txt" -force
}


while($confirmationrename -ne "n" -and $confirmationrename -ne "y")
{
	$confirmationrename = Read-Host "Rename this PC? [y/n]"
	if($confirmationrename -eq "y")
	{
		while($pcname -eq "")
		{
			$pcname = Read-Host "Type the new name for this PC"
		}
	}
}





while($confirmationdomainjoin -ne "n" -and $confirmationdomainjoin -ne "y")
{
	$confirmationdomainjoin = Read-Host "Join PC to domain? [y/n]"
}

if ($confirmationdomainjoin -eq "y")
{
	while($confirmationdomainjoin2 -ne "n")
	{
		try
		{
			Add-Computer
		}
		catch
		{
			$confirmationdomainjoin2 = Read-Host "Domain join failed. Retry domain join? Answering no will skip domain join. [y/n]"
		}
	}
}


while($confirmationonedrive -ne "n" -and $confirmationonedrive -ne "y")
{
	$confirmationonedrive = Read-Host "Remove all traces of OneDrive? [y/n]"
}

while($confirmationstartmenu -ne "n" -and $confirmationstartmenu -ne "y")
{
	$confirmationstartmenu = Read-Host "Remove all startmenu, desktop, taskbar icons? Essential shortcuts will be created. (Chrome, Explorer) [y/n]"
}


while($confirmationchocoinstall -ne "n" -and $confirmationchocoinstall -ne "y")
{
	$confirmationchocoinstall = Read-Host "Install Chocolatey and choose packages? [y/n]"
}
if($confirmationchocoinstall -eq "y")
{
	Write-Host 
	Write-Host "A .txt file containing the Chocolatey packages to be installed will now open"
	Write-Host "edit, save and close the file separating each package name with a semicolon"
	Write-Host 
	Read-Host "Press ENTER to open the chocolist.txt file"
	notepad.exe "$($env:TEMP)\winstall-core\chocolist.txt"
	Read-Host "Press ENTER to continue after the chocolist.txt file has been saved"	
}
$chocolist = [IO.File]::ReadAllText("$($env:TEMP)\winstall-core\chocolist.txt")


Write-Host
Write-Host "Rename PC: [$($confirmationrename)]"
Write-Host "Domain Join: [$($confirmationdomainjoin)]"
Write-Host "OneDrive Removal: [$($confirmationonedrive)]"
Write-Host "Icon Removal: [$($confirmationstartmenu)]"
Write-Host "Choco install: [$($confirmationchocoinstall)]"
Write-Host
Write-Host "Windows 10 Setup Script will now run"
Write-Host "explorer.exe will taskkill while running and restart when finished"
Write-Host

while($confirmationfull -ne "n" -and $confirmationfull -ne "y")
{
	$confirmationfull = Read-Host "Continue? [y/n]"
}
if ($confirmationfull -ne "y")
{
	Clear-Host
	exit
}


if ($confirmationrename -eq "y")
{
	Rename-Computer -NewName $pcname
}


###########################################################################
# Disable Windows Store automatic install service
##########################################################################

cmd /c net stop InstallService
cmd /c sc config InstallService start= disabled

###########################################################################
# Kill explorer.exe
##########################################################################

Invoke-Expression "taskkill /f /im explorer.exe"

###########################################################################
# Remove all Windows store apps expect WindowsStore, Calculator and Photos
##########################################################################

Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} | where-object {$_.name -notlike "*.NET*"} | where-object {$_.name -notlike "*.VCLibs*"} | Remove-AppxPackage -erroraction 'silentlycontinue'
Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.packagename -notlike "*Microsoft.Windows.Photos*"} | where-object {$_.name -notlike "*.NET*"} | where-object {$_.name -notlike "*.VCLibs*"} | Remove-AppxProvisionedPackage -online -erroraction 'silentlycontinue'


###########################################################################
# Choco install
##########################################################################



if ($confirmationchocoinstall -eq "y")
{
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalconfirmation
	choco install "$($chocolist);vcredist-all;dotnet4.0;dotnet4.5;dotnet4.5.2;dotnet4.6;dotnet4.6.1;dotnet4.6.2;dotnet4.7;dotnet4.7.1 --ignore-checksums"
}




###########################################################################
# Taskbar pinapp function
##########################################################################

if ($confirmationstartmenu -eq "y")
{



	
	function findTheNeedle ($needle, $haystack, $startIndexInHaystack=0, $needlePartsThatDontMatter=@())
	{
		$haystackLastIndex = ($haystack.Length - 1)
		$needleLastIndex = ($needle.Length - 1)
		$needleCurrentIndex = 0
		$haystackCurrentIndex = $startIndexInHaystack
		while ($haystackCurrentIndex -lt $haystackLastIndex)
		{
			if ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
			{
				$startIndex = $haystackCurrentIndex
				while ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
				{
					$needleCurrentIndex += 1
					$haystackCurrentIndex += 1
				}
				if (($needleCurrentIndex - 1) -eq $needleLastIndex)
				{
					return ($startIndex + 1)
				}
				$needleCurrentIndex = 0
				$haystackCurrentIndex = $startIndex
			}
			$haystackCurrentIndex += 1
		}
		return -1
	}

	function findTheNeedleReverse ($needle, $haystack, $startIndexInHaystack=0, $needlePartsThatDontMatter=@())
	{
		$needleLastIndex = ($needle.Length - 1)
		$needleCurrentIndex = $needleLastIndex
		$haystackCurrentIndex = $startIndexInHaystack
		while ($haystackCurrentIndex -gt 0)
		{

			if ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex]  -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
			{
				$startIndex = $haystackCurrentIndex
				while ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
				{
					$needleCurrentIndex -= 1
					$haystackCurrentIndex -= 1
				}
				if (($needleCurrentIndex + 1) -eq 0)
				{
					return ($haystackCurrentIndex + 1)
				}
				$needleCurrentIndex = $needleLastIndex
				$haystackCurrentIndex = $startIndex
			}
			$haystackCurrentIndex -= 1
		}
		return -1
	}
	$taskbarEntryHeaderBytes = @(0,51,6,0,0,20,0,31,128,155,212,52);
	$taskbarEntryHeaderBytesThatDontMatter = @(0,1,2,5,9,10);
	$taskbarEntryTrailerBytes = @(34,0,0,0,30,0,239,190,2,0,85,0,115,0,101,0,114,0,80,0,105,0,110,0,110,0,101,0,100,0,0,0,59,5,0,0);
	$taskbarEntryTrailerBytesThatDontMatter = @(32,33);
	$apps = @(
	@{
		"appName" = "Microsoft Edge"
		"appThumbprint" = @(38,0,0,0,77,0,105,0,99,0,114,0,111,0,115,0,111,0,102,0,116,0,46,0,77,0,105,0,99,0,114,0,111,0,115,0,111,0,102,0,116,0,69,0,100,0,103,0,101);
		"taskbarEntryHeaderBytes" = $taskbarEntryHeaderBytes
		"taskbarEntryHeaderBytesThatDontMatter" = $taskbarEntryHeaderBytesThatDontMatter
		"taskbarEntryTrailerBytes" = $taskbarEntryTrailerBytes
		"taskbarEntryTrailerBytesThatDontMatter" = $taskbarEntryTrailerBytesThatDontMatter
	}
	@{
		"appName" = "Microsoft Windows Store"
		"appThumbprint" = @(37,0,0,0,77,0,105,0,99,0,114,0,111,0,115,0,111,0,102,0,116,0,46,0,87,0,105,0,110,0,100,0,111,0,119,0,115,0,83,0,116,0,111,0,114,0,101);
		"taskbarEntryHeaderBytes" = $taskbarEntryHeaderBytes
		"taskbarEntryHeaderBytesThatDontMatter" = $taskbarEntryHeaderBytesThatDontMatter
		"taskbarEntryTrailerBytes" = $taskbarEntryTrailerBytes
		"taskbarEntryTrailerBytesThatDontMatter" = $taskbarEntryTrailerBytesThatDontMatter
	}
	)
	$atLeastOneAppIsPinned = $false
	foreach ($app in $apps)
	{
		$haystack = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites").Favorites
		$needleStart = findTheNeedle $app["appThumbprint"] $haystack
		if ($needleStart -ne -1)
		{
			$firstIndexAfterNeedle = $needleStart + $app["appThumbprint"].Length
			$lastIndexOfEntry = (findTheNeedle $app["taskbarEntryTrailerBytes"] $haystack $firstIndexAfterNeedle $app["taskbarEntryTrailerBytesThatDontMatter"]) + ($app["taskbarEntryTrailerBytes"].Length - 1)
			if (($lastIndexOfEntry) -ne -1)
			{
				$firstIndexOfEntry = findTheNeedleReverse $app["taskbarEntryHeaderBytes"] $haystack $needleStart $app["taskbarEntryHeaderBytesThatDontMatter"]
				if (($firstIndexOfEntry) -ne -1)
				{
					$atLeastOneAppIsPinned = $true
					if ($firstIndexOfEntry -eq 0) 
					{
						$newArray = $haystack[$lastIndexOfEntry..($haystack.Length)]
					}
					else
					{
						$newArray = $haystack[0..($firstIndexOfEntry - 1)] + $haystack[$lastIndexOfEntry..($haystack.Length)]
					}
					New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Value $newArray -PropertyType Binary -Force | Out-Null
				}
			}
		}
	}
	
	
###########################################################################
# Pinapp function
##########################################################################

	function Pin-App {    param(
		[string]$appname,
		[switch]$unpin
		)
		try{
			if ($unpin.IsPresent){
				((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Start" lösen|Unpin from Start'} | %{$_.DoIt()}
				return "App '$appname' unpinned from Start"
			}else{
				((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Start" anheften|Pin to Start'} | %{$_.DoIt()}
				return "App '$appname' pinned to Start"
			}
		}catch{
			#Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
		}
	}


###########################################################################
# Unpin everything from the start menu
##########################################################################

	Get-StartApps | ForEach-Object { Pin-App $_.name -unpin }

###########################################################################
# Pin these apps to the start menu
##########################################################################

	Pin-App "Calculator" -pin
	Pin-App "Photos" -pin
	Pin-App "File Explorer" -pin
	Pin-App "Control Panel" -pin
	Pin-App "Task Manager" -pin
	Pin-App "Notepad" -pin
	Pin-App "Remote Desktop Connection" -pin
	Pin-App "Thunderbird" -pin
	Pin-App "Outlook 2016" -pin
	Pin-App "Word 2016" -pin
	Pin-App "Excel 2016" -pin
	Pin-App "Publisher 2016" -pin
	Pin-App "PowerPoint 2016" -pin
	Pin-App "Malwarebytes" -pin
	Pin-App "BleachBit" -pin
	Pin-App "WinDirStat" -pin

###########################################################################
# Disable Taskview and People icons from the taskbar and game overlay
##########################################################################

	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -value 0 -erroraction 'silentlycontinue'
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -value 0 -erroraction 'silentlycontinue'
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1 -erroraction 'silentlycontinue'
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
	
###########################################################################
# Delete all desktop icons
##########################################################################

	Remove-Item C:\Users\*\Desktop\*lnk -force

}

###########################################################################
# Turn Off All Windows 10 Telemetry
##########################################################################

(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hahndorf/Set-Privacy/master/Set-Privacy.ps1') | out-file "$($env:TEMP)\winstall-core\set-privacy.ps1" -force
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
"$($env:TEMP)\winstall-core\set-privacy.ps1" -Strong -admin

###########################################################################
# Remove OneDrive
##########################################################################

if ($confirmationonedrive -eq "y")
{

	#Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1
	#Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

	echo "73 OneDrive process and explorer"
	taskkill.exe /F /IM "OneDrive.exe"
	
	

	echo "Remove OneDrive"
	if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
		& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
	}
	if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
		& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
	}

	echo "Disable OneDrive via Group Policies"
	#force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
	sp "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -erroraction 'silentlycontinue'

	echo "Removing OneDrive leftovers trash"
	rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
	rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
	rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

	echo "Remove Onedrive from explorer sidebar"
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
	mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0 -erroraction 'silentlycontinue'
	mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0 -erroraction 'silentlycontinue'
	Remove-PSDrive "HKCR"

	echo "Removing run option for new users"
	reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"

}


###########################################################################
# Pin taskbar apps
##########################################################################

#if ($chocolist -like '*firefox*')
#{
#Copy-Item "$($env:TEMP)\icons\Firefox.lnk" -Destination "$($env:APPDATA)\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Firefox.lnk" -Force

#$WshShell = New-Object -comObject WScript.Shell
#$Shortcut = $WshShell.CreateShortcut("$($env:APPDATA)\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Firefox.lnk")
#$Shortcut.TargetPath = "$($env:ProgramFiles)\Mozilla Firefox\firefox.exe"
#$Shortcut.Save()
#}

#if ($chocolist -like '*chrome*')
#{
#Copy-Item "$($env:TEMP)\icons\Google Chrome.lnk" -Destination "$($env:APPDATA)\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk" -Force
#}

#Copy-Item "$($env:TEMP)\icons\File Explorer.lnk" -Destination "$($env:APPDATA)\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk" -Force


###########################################################################
# Start explorer.exe
##########################################################################

Install-Module -Name PendingReboot -Force -Confirm:$false

Invoke-Expression "start explorer.exe"


$rebootpending = Test-PendingReboot | Select-Object -Property IsRebootPending | Format-Wide
if ($rebootpending = "True")
{

	Write-Host
	Write-Host
	Write-Warning "REBOOT REQUIRED"
	Write-Host
	while($confirmationreboot -ne "n" -and $confirmationreboot -ne "y")
	{
		$confirmationreboot = Read-Host "Reboot is pending reboot this PC now? [y/n]"
	}
	if ($confirmationreboot -eq "y")
	{	
		Restart-Computer
	}
}
else
{
	Write-Host
	Write-Host
	Write-Host "No reboot required"
	Read-Host "Complete, press ENTER to close and finish"
	Write-Host
	
}
