##########################################
#	Title:      Windows 10 Setup Script	 #
#	Creator:	Ad3t0	                 #
#	Date:		10/20/2018             	 #
##########################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if($myWindowsPrincipal.IsInRole($adminRole))
{	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}else
{	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}##############
$ver = "1.6.9"
$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" -computername $strComputer
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId"
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName"

function header
{	Write-host " #####################################"
	Write-Host " #                                   #"
	Write-host " #       " -NoNewLine
	Write-host "Windows 10 Setup Script" -foregroundcolor yellow -NoNewLine
	Write-host "     #"
	Write-host " #          " -NoNewLine
	Write-host "Version: " -foregroundcolor yellow -NoNewLine
	Write-host $ver -foregroundcolor cyan -NoNewLine
	Write-host "           #"
	Write-host " #                                   #"
	Write-host " #####################################"
	Write-host
	foreach ($objItem in $colItems) {
		Write-Host
		Write-Host " CPU Model: " -foregroundcolor yellow -NoNewLine
		Write-Host $objItem.Name -foregroundcolor white	
		Write-Host " System: " -foregroundcolor yellow -NoNewLine
		Write-Host $productname.ProductName $currentversion.ReleaseId -foregroundcolor white	
		Write-Host " PC Name: " -foregroundcolor yellow -NoNewLine
		Write-Host $env:COMPUTERNAME -foregroundcolor white
		Write-Host " Username: " -foregroundcolor yellow -NoNewLine
		Write-Host $env:USERNAME -foregroundcolor white
		Write-Host " Domain: " -foregroundcolor yellow -NoNewLine
		Write-Host $env:LOGONSERVER -foregroundcolor white
		Write-Host
	}
}header
Write-host "Please wait loading modules..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -confirm:$false
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name PendingReboot -confirm:$false #>$null 2>&1
Write-host "Modules finished loading"
Clear-Host
header
New-Item -Path $env:TEMP -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1
Set-Location "$($env:TEMP)\winstall-core"
if(!(Test-Path -Path "$($env:TEMP)\winstall-core\chocolist.txt" ))
{	
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/chocolist.txt') | out-file "$($env:TEMP)\winstall-core\chocolist.txt" -force
}while($initialsetting -ne "1" -and $initialsetting -ne "2" -and $initialsetting -ne "3")
{	Clear-Host
	header
	if(([string]::IsNullOrEmpty($initialsetting)) -ne $true)
	{	
		if($initialsetting -ne "1" -and $initialsetting -ne "2" -and $initialsetting -ne "3")
		{
			Write-Warning "Invalid option"
		}
	}
	Write-Host "  ----------------------------------------"
	Write-Host " 1 - Basic SELECTIVE"
	Write-Host " 2 - Basic ALL"
	Write-Host " 3 - Advanced SELECTIVE"
	Write-Host
	$initialsetting = Read-Host -Prompt "Input option"
}if($initialsetting -eq "2")
{	$confirmationrename = "y"
	$confirmationdomainjoin = "y"
	$confirmationonedrive = "y"
	$confirmationstartmenu = "y"
	$confirmationappremoval = "y"
	$confirmationchocoinstall = "y"
}while($confirmationrename -ne "n" -and $confirmationrename -ne "y")
{	$confirmationrename = Read-Host "Rename this PC? [y/n]"
	if($confirmationrename -eq "y")
	{
		while((![string]::IsNullOrEmpty($pcname)) -ne $true)
		{
			$pcname = Read-Host "Type the new name for this PC"
		}
	}
}while($confirmationdomainjoin -ne "n" -and $confirmationdomainjoin -ne "y")
{	$confirmationdomainjoin = Read-Host "Join PC to domain? [y/n]"
}if($confirmationdomainjoin -eq "y")
{	while($confirmationdomainjoin2 -ne "n")
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
}while($confirmationonedrive -ne "n" -and $confirmationonedrive -ne "y")
{	$confirmationonedrive = Read-Host "Remove all traces of OneDrive? [y/n]"
}while($confirmationstartmenu -ne "n" -and $confirmationstartmenu -ne "y")
{	$confirmationstartmenu = Read-Host "Unpin all startmenu and taskbar icons? [y/n]"
	while($confirmationappremoval -ne "n" -and $confirmationappremoval -ne "y")
	{	
		$confirmationappremoval = Read-Host "Remove all Windows Store apps except the Calculator, Photos, and the Windows Store? [y/n]"
	}
}while($confirmationchocoinstall -ne "n" -and $confirmationchocoinstall -ne "y")
{	$confirmationchocoinstall = Read-Host "Install Chocolatey and choose packages? [y/n]"
}if($initialsetting -eq "3")
{	while($confirmationpcdiscover -ne "n" -and $confirmationpcdiscover -ne "y")
	{	
		$confirmationpcdiscover = Read-Host "Make this PC discoverable on the network? [y/n]"
	}
	while($confirmationwallpaperq -ne "n" -and $confirmationwallpaperq -ne "y")
	{	
		$confirmationwallpaperq = Read-Host "Increase desktop wallpaper compression to max quality? [y/n]"
	}
	while($confirmationshowfileex -ne "n" -and $confirmationshowfileex -ne "y")
	{	
		$confirmationshowfileex = Read-Host "Show file extension in File Explorer? [y/n]"
	}	
	while($confirmationshowhiddenfiles -ne "n" -and $confirmationshowhiddenfiles -ne "y")
	{	
		$confirmationshowhiddenfiles = Read-Host "Show hidden files in File Explorer? [y/n]"
	}
}if($confirmationchocoinstall -eq "y")
{	Write-Host
	Write-Host "A .txt file containing the Chocolatey packages to be installed will now open"
	Write-Host "edit, save and close the file separating each package name with a semicolon"
	Write-Host
	Read-Host "Press ENTER to open the chocolist.txt file"
	notepad.exe "$($env:TEMP)\winstall-core\chocolist.txt"
	Read-Host "Press ENTER to continue after the chocolist.txt file has been saved"
	(Get-Content "$($env:TEMP)\winstall-core\chocolist.txt").replace(';;', ';') | Set-Content "$($env:TEMP)\winstall-core\chocolist.txt"
}$chocolist = [IO.File]::ReadAllText("$($env:TEMP)\winstall-core\chocolist.txt")
Write-Host
Write-Host "Rename PC: [$($confirmationrename)]"
Write-Host "Domain Join: [$($confirmationdomainjoin)]"
Write-Host "OneDrive Removal: [$($confirmationonedrive)]"
Write-Host "Unpin All Icons: [$($confirmationstartmenu)]"
Write-Host "App Removal: [$($confirmationappremoval)]"
Write-Host "Choco install: [$($confirmationchocoinstall)]"
if($initialsetting -eq "3")
{	Write-Host "PC Discoverable: [$($confirmationpcdiscover)]"
	Write-Host "Wallpaper Max Quality: [$($confirmationwallpaperq)]"
	Write-Host "Show File Extensions: [$($confirmationshowfileex)]"
	Write-Host "Show Hidden Files: [$($confirmationshowhiddenfiles)]"
}Write-Host
Write-Host "Windows 10 Setup Script will now run"
Write-Host "explorer.exe will taskkill while running and restart when finished"
Write-Host
while($confirmationfull -ne "n" -and $confirmationfull -ne "y")
{	$confirmationfull = Read-Host "Continue? [y/n]"
}if($confirmationfull -ne "y")
{	Clear-Host
	exit
}if($confirmationrename -eq "y")
{	Rename-Computer -NewName $pcname
}###########################################################################
# Kill explorer.exe
##########################################################################
Invoke-Expression "taskkill /f /im explorer.exe"
###########################################################################
# Disable Windows Store automatic install service
##########################################################################
Write-host "Disabling automatic app reinstall services" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -Type DWord -Value 2 -erroraction 'silentlycontinue'
cmd /c net stop InstallService
cmd /c sc config InstallService start= disabled
cmd /c net stop DiagTrack
cmd /c sc config DiagTrack start= disabled
if($confirmationpcdiscover -eq "y")
{	cmd /c net start FDResPub
	cmd /c sc config FDResPub start= auto
}###########################################################################
# Remove all Windows store apps expect WindowsStore, Calculator and Photos
##########################################################################
if($confirmationappremoval -eq "y")
{Write-Host "Removing all Windows store apps expect Windows Store, Calculator and Photos" -foregroundcolor yellow
	Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} | where-object {$_.name -notlike "*.NET*"} | where-object {$_.name -notlike "*.VCLibs*"} | Remove-AppxPackage -erroraction 'silentlycontinue'
	Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.packagename -notlike "*Microsoft.Windows.Photos*"} | where-object {$_.name -notlike "*.NET*"} | where-object {$_.name -notlike "*.VCLibs*"} | Remove-AppxProvisionedPackage -online | Out-Null
}###########################################################################
# Choco install
##########################################################################
if($confirmationchocoinstall -eq "y")
{	
	Write-Host "Installing Chocolatey, and all .NET Framework versions and all VCRedist Visual C++ versions" -foregroundcolor yellow
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalconfirmation
	choco install "$($chocolist);vcredist-all;dotnet4.0;dotnet4.5;dotnet4.5.2;dotnet4.6;dotnet4.6.1;dotnet4.6.2 --ignore-checksums"
}###########################################################################
# Major registry changes
##########################################################################
Write-Host
Write-Host " Basic Settings" -foregroundcolor yellow
Write-Host " ----------------------------------------" -foregroundcolor cyan
Write-Host
Write-Host "Disabling the People icon on the taskbar" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling the Task View icon on the taskbar" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling the toast ads and spam notifications above the system tray" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling GameDVR and GameOverlay" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Bing search in Start Menu" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Allow Search To Use Location" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "AllowSearchToUseLocation" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Cortana ad tracking" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling user tracking ads" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling silently installed apps" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling System Pane Suggestions" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Sync Provider Notifications" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Lock Screen ads" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling subscribed ads" -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Cortana" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Start Menu web search" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1 -erroraction 'silentlycontinue'
Write-Host "Disabling Windows Ink Space" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling Online Tips/Ads" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "AllowOnlineTips" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling all Windows telemetry" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -erroraction 'silentlycontinue'
Write-Host "Disabling 3D Objects folder in File Explorer" -foregroundcolor yellow
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
if($initialsetting -eq "3")
{	Write-Host
	Write-Host " Advanced Settings" -foregroundcolor yellow
	Write-Host " ----------------------------------------" -foregroundcolor cyan
}if($confirmationpcdiscover -eq "y")
{	Write-Host "Increasing wallpaper compression quality to 100" -foregroundcolor yellow
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "JPEGImportQuality" -Type DWord -Value 100 -erroraction 'silentlycontinue'
}if($confirmationshowfileex -eq "y")
{	Write-Host "Enabling show file extensions" -foregroundcolor yellow
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -erroraction 'silentlycontinue'
}if($confirmationshowhiddenfiles -eq "y")
{	Write-Host "Enabling show hidden files" -foregroundcolor yellow
	Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1
}###########################################################################
# Taskbar pinapp function
##########################################################################
Write-Host "Unpinning all default Task Bar icons" -foregroundcolor yellow
if($confirmationstartmenu -eq "y")
{	
	function findTheNeedle ($needle, $haystack, $startIndexInHaystack=0, $needlePartsThatDontMatter=@())
	{
		$haystackLastIndex = ($haystack.Length - 1)
		$needleLastIndex = ($needle.Length - 1)
		$needleCurrentIndex = 0
		$haystackCurrentIndex = $startIndexInHaystack
		while($haystackCurrentIndex -lt $haystackLastIndex)
		{
			if($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
			{
				$startIndex = $haystackCurrentIndex
				while($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
				{
					$needleCurrentIndex += 1
					$haystackCurrentIndex += 1
				}
				if(($needleCurrentIndex - 1) -eq $needleLastIndex)
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
		while($haystackCurrentIndex -gt 0)
		{
			if($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex]  -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
			{
				$startIndex = $haystackCurrentIndex
				while($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
				{
					$needleCurrentIndex -= 1
					$haystackCurrentIndex -= 1
				}
				if(($needleCurrentIndex + 1) -eq 0)
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
		if($needleStart -ne -1)
		{
			$firstIndexAfterNeedle = $needleStart + $app["appThumbprint"].Length
			$lastIndexOfEntry = (findTheNeedle $app["taskbarEntryTrailerBytes"] $haystack $firstIndexAfterNeedle $app["taskbarEntryTrailerBytesThatDontMatter"]) + ($app["taskbarEntryTrailerBytes"].Length - 1)
			if(($lastIndexOfEntry) -ne -1)
			{
				$firstIndexOfEntry = findTheNeedleReverse $app["taskbarEntryHeaderBytes"] $haystack $needleStart $app["taskbarEntryHeaderBytesThatDontMatter"]
				if(($firstIndexOfEntry) -ne -1)
				{
					$atLeastOneAppIsPinned = $true
					if($firstIndexOfEntry -eq 0)
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
	Write-Host "Unpinning all Start Menu apps"	-foregroundcolor yellow
	function Pin-App
	{
		param(
		[string]$appname,
		[switch]$unpin
		)
		try
		{
			if($unpin.IsPresent){
				((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Start" lösen|Unpin from Start'} | %{$_.DoIt()}
				return "App '$appname' unpinned from Start"
			}
			else
			{
				((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Start" anheften|Pin to Start'} | %{$_.DoIt()}
				return "App '$appname' pinned to Start"
			}
		}
		catch
		{
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
	#Pin-App "Calculator" -pin
	#Pin-App "Photos" -pin
	#Pin-App "File Explorer" -pin
	#Pin-App "Control Panel" -pin
	#Pin-App "Task Manager" -pin
	#Pin-App "Notepad" -pin
	#Pin-App "Remote Desktop Connection" -pin
	#Pin-App "Thunderbird" -pin
	#Pin-App "Outlook 2016" -pin
	#Pin-App "Word 2016" -pin
	#Pin-App "Excel 2016" -pin
	#Pin-App "Publisher 2016" -pin
	#Pin-App "PowerPoint 2016" -pin
	#Pin-App "Malwarebytes" -pin
	#Pin-App "BleachBit" -pin
	#Pin-App "WinDirStat" -pin
###########################################################################
# Delete all desktop icons
##########################################################################
	Write-Host "Removing default desktop icons"	
	Remove-Item "C:\Users\*\Desktop\Microsoft Edge.lnk" -force
}###########################################################################
# Turn Off All Windows 10 Telemetry
##########################################################################
Write-Host "Permanently turning off all Windows telemetry and ads" -foregroundcolor yellow
(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hahndorf/Set-Privacy/master/Set-Privacy.ps1') | out-file .\set-privacy.ps1 -force
.\set-privacy.ps1 -Strong -admin
###########################################################################
# Remove OneDrive
##########################################################################
if($confirmationonedrive -eq "y")
{	
	Write-Host "Disabling and removing OneDrive" -foregroundcolor yellow
	taskkill.exe /F /IM "OneDrive.exe"
	Write-Host "Remove OneDrive"
	if(Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
		& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
	}
	if(Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
		& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
	}
	Write-Host "Disable OneDrive via Group Policies"
	sp "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -erroraction 'silentlycontinue'
	Write-Host "Removing OneDrive leftover trash"
	rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
	rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
	rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"
	Write-Host "Removing OneDrive from explorer sidebar"
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
	mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0 -erroraction 'silentlycontinue'
	mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0 -erroraction 'silentlycontinue'
	Remove-PSDrive "HKCR"
	Write-Host "Removing run option for new users"
	reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
}###########################################################################
# Start explorer.exe
##########################################################################
Write-Host "Restarting explorer.exe..." -foregroundcolor yellow
Invoke-Expression "start explorer.exe"
$rebootpending = Test-PendingReboot | Select-Object -Property IsRebootPending | Format-Wide
if($rebootpending = "True")
{	Write-Host
	Write-Host
	Write-Warning "REBOOT REQUIRED"
	Write-Host
	while($confirmationreboot -ne "n" -and $confirmationreboot -ne "y")
	{
		$confirmationreboot = Read-Host "Reboot is pending reboot this PC now? [y/n]"
	}
	if($confirmationreboot -eq "y")
	{	
		Restart-Computer
	}
}else
{	Write-Host
	Write-Host
	Write-Host "No reboot required"
	Write-Host
	Read-Host "Complete, press ENTER to close and finish"
	Write-Host
}Exit