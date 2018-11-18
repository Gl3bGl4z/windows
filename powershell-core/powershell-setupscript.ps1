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
$ver = "1.9.6"
if((Get-WMIObject win32_operatingsystem).name -notlike "*Windows 10*")
{	
	Write-Warning "Operating system is not Windows 10..."
	Read-Host "Press ENTER to exit."
	Exit
}$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2"
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
	Write-Host
	Write-Host " CPU Model: " -foregroundcolor yellow -NoNewLine
	Write-Host $colItems.Name -foregroundcolor white	
	Write-Host " System: " -foregroundcolor yellow -NoNewLine
	Write-Host $productname.ProductName $currentversion.ReleaseId -foregroundcolor white
	Write-Host " PC Name: " -foregroundcolor yellow -NoNewLine
	Write-Host $env:COMPUTERNAME -foregroundcolor white
	Write-Host " Username: " -foregroundcolor yellow -NoNewLine
	Write-Host $env:USERNAME -foregroundcolor white
	Write-Host " Domain: " -foregroundcolor yellow -NoNewLine
	Write-Host $env:USERDNSDOMAIN -foregroundcolor white
	Write-Host
}header
Write-host "Please wait loading modules..." -foregroundcolor green
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -confirm:$false
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name PendingReboot -confirm:$false
Clear-Host
header
New-Item -Path $env:TEMP -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1
Set-Location "$($env:TEMP)\winstall-core"
if(!(Test-Path -Path "$($env:TEMP)\winstall-core\chocolist.txt" ))
{	
	(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/bin/chocolist.txt') | Out-File "$($env:TEMP)\winstall-core\chocolist.txt" -force
}while($initialsetting -ne "1" -and $initialsetting -ne "2" -and $initialsetting -ne "3" -and $initialsetting -ne "4")
{	Clear-Host
	header
	if(([string]::IsNullOrEmpty($initialsetting)) -ne $true)
	{	
		if($initialsetting -ne "1" -and $initialsetting -ne "2" -and $initialsetting -ne "3" -and $initialsetting -ne "4")
		{
			Write-Warning "Invalid option"
		}
	}
	Write-Host "  ----------------------------------------"
	Write-Host " 1 - Basic SELECTIVE"
	Write-Host " 2 - Basic ALL"
	Write-Host " 3 - Full SELECTIVE"
	Write-Host " 4 - Full ALL"
	Write-Host
	$initialsetting = Read-Host -Prompt "Input option"
}if($initialsetting -eq "2" -or $initialsetting -eq "4")
{	$confirmationrename = "y"
	$confirmationdomainjoin = "y"
	$confirmationonedrive = "y"
	$confirmationstartmenu = "y"
	$confirmationpowersch = "y"
	$confirmationappremoval = "y"
	$confirmationchocoinstall = "y"
}if($initialsetting -eq "4")
{	
	$confirmationonedrive = "y"
	$confirmationwallpaperq = "y"
	$confirmationshowfileex = "y"
	$confirmationshowhiddenfiles = "y"
	$confirmationrdp = "y"
	$confirmationwol = "y"
	$confirmationhostsadb = "y"
}while($confirmationrename -ne "n" -and $confirmationrename -ne "y")
{	
	if($initialsetting -eq "2")
	{
		$confirmationrename = "y"
	}
	$confirmationrename = Read-Host "Rename this PC? [y/n]"
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
			$fqdn = Read-Host "Enter the FQDN for the domain"	
			if($fqdn -notlike "*.*")
			{
				Write-Error "Invalid FQDN"
			}
			$dn = $fqdn.Substring($fqdn.IndexOf(".") + 1)
			Write-Host "Test ping FQDN..."
			if (Test-Connection -ComputerName $fqdn -Quiet)
			{
				Write-Host "FQDN ping successful" -foregroundcolor green
				Add-Computer -DomainName $fqdn
			}
			else
			{
				Write-Host "FQDN ping unsuccessful" -foregroundcolor red
				
				while($confirmationmanconfig -ne "n" -and $confirmationmanconfig -ne "y")
				{
					$confirmationmanconfig = Read-Host "Manually configure DNS? Answering no will skip domain join. [y/n]"
				}
				if($confirmationmanconfig -eq "y")
				{
					$confirmationdomainjoin2 = "n"
					[ipaddress]$serverip = Read-Host "Enter the IP address of the DNS server for manual configuration"
					$adap = Get-NetAdapter
					$adapter = $adap.ifIndex | Select-Object -last 1
					Set-DnsClientServerAddress -InterfaceIndex $adapter -ServerAddresses ($serverip,"1.1.1.1")
					Add-Computer -DomainName $dn
					
				}
				else
				{
					$confirmationdomainjoin2 = "n"
					Write-Host "Skipping domain join..." -foregroundcolor yellow
				}
			}
			
		}
		catch
		{	
			$confirmationdomainjoin2 = ""
			$confirmationdomainjoin2 = Read-Host "Domain join failed or DNS IP address invalid. Retry domain join? Answering no will skip domain join. [y/n]"
		}
	}
}while($confirmationpowersch -ne "n" -and $confirmationpowersch -ne "y")
{	$confirmationpowersch = Read-Host "Set PowerScheme to maximum performance? [y/n]"
}while($confirmationstartmenu -ne "n" -and $confirmationstartmenu -ne "y")
{	$confirmationstartmenu = Read-Host "Unpin all startmenu and taskbar icons? [y/n]"
	while($confirmationappremoval -ne "n" -and $confirmationappremoval -ne "y")
	{	
		$confirmationappremoval = Read-Host "Remove all Windows Store apps except the Calculator, Photos, and the Windows Store? [y/n]"
	}
}while($confirmationchocoinstall -ne "n" -and $confirmationchocoinstall -ne "y")
{	$confirmationchocoinstall = Read-Host "Install Chocolatey and choose packages? [y/n]"
}if($initialsetting -eq "3")
{	
	while($confirmationonedrive -ne "n" -and $confirmationonedrive -ne "y")
	{
		$confirmationonedrive = Read-Host "Remove all traces of OneDrive? [y/n]"
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
	while($confirmationrdp -ne "n" -and $confirmationrdp -ne "y")
	{	
		$confirmationrdp = Read-Host "Enable Allow Remote Desktop Connections? [y/n]"
	}
	while($confirmationwol -ne "n" -and $confirmationwol -ne "y")
	{	
		$confirmationwol = Read-Host "Enable Allow Wake On LAN? [y/n]"
	}
	while($confirmationhostsadb -ne "n" -and $confirmationhostsadb -ne "y")
	{	
		$confirmationhostsadb = Read-Host "Download MVPS hosts for system wide ad blocking? [y/n]"
	}
}if($confirmationchocoinstall -eq "y")
{	Write-Host
	Write-Host "A .txt file containing the Chocolatey packages to be installed will now open"
	Write-Host "edit, save and close the file separating each package name with a semicolon"
	Write-Host
	Read-Host "Press ENTER to open the chocolist.txt file"
	notepad.exe "$($env:TEMP)\winstall-core\chocolist.txt"
	Read-Host "Press ENTER to continue after the chocolist.txt file has been saved"
}$chocolist = [IO.File]::ReadAllText("$($env:TEMP)\winstall-core\chocolist.txt")
Write-Host
Write-Host "Rename PC: [$($confirmationrename)]"
Write-Host "Domain Join: [$($confirmationdomainjoin)]"
Write-Host "Maximum PowerScheme: [$($confirmationpowersch)]"
Write-Host "Unpin All Icons: [$($confirmationstartmenu)]"
Write-Host "App Removal: [$($confirmationappremoval)]"
Write-Host "Choco install: [$($confirmationchocoinstall)]"
if($initialsetting -eq "3" -or $initialsetting -eq "4")
{Write-Host "OneDrive Removal: [$($confirmationonedrive)]"	
	Write-Host "Wallpaper Max Quality: [$($confirmationwallpaperq)]"
	Write-Host "Show File Extensions: [$($confirmationshowfileex)]"
	Write-Host "Show Hidden Files: [$($confirmationshowhiddenfiles)]"
	Write-Host "Allow Remote Desktop: [$($confirmationrdp)]"
	Write-Host "Allow Wake On LAN: [$($confirmationwol)]"
	Write-Host "MVPS hosts File: [$($confirmationhostsadb)]"
}Write-Host
Write-Host "Windows 10 Setup Script will now run"
Write-Host "explorer.exe will taskkill while running and restart when finished..."
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
Write-host "Disabling automatic app reinstall services..." -foregroundcolor yellow
cmd /c net stop InstallService
cmd /c sc config InstallService start= disabled
cmd /c net stop DiagTrack
cmd /c sc config DiagTrack start= disabled
if($confirmationpcdiscover -eq "y")
{	cmd /c net start FDResPub
	cmd /c sc config FDResPub start= auto
}###########################################################################
# Change Windows PowerScheme to maximum performance
##########################################################################
if($confirmationpowersch -eq "y")
{	$psguid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
	$currScheme = POWERCFG -GETACTIVESCHEME
	$cscheme = $currScheme.Split()
	if ($cscheme[3] -eq $psguid) {
		write-Host -ForegroundColor yellow "Already set to the correct PowerScheme settings skipping..."
	} else {
		Write-Warning "Lower PowerScheme detected, changing PowerScheme to maximum performance..."
		PowerCfg -SetActive $psguid
		write-Host -ForegroundColor Green "PowerScheme Successfully Applied"
	}
}###########################################################################
# Chocolatey install
##########################################################################
if($confirmationchocoinstall -eq "y")
{	
	Write-Host "Installing Chocolatey, and all .NET Framework versions and all VCRedist Visual C++ versions..." -foregroundcolor yellow
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalconfirmation
	choco feature disable -n=checksumFiles
	$chocotobeinstalled = "$($chocolist);vcredist-all".replace(' ', ';').replace(';;', ';')
	choco install $chocotobeinstalled
}###########################################################################
# Registry changes
##########################################################################
Write-Host
Write-Host " Basic Settings" -foregroundcolor yellow
Write-Host " ----------------------------------------" -foregroundcolor cyan
Write-Host
############
Write-Host "Disabling the Task View icon on the taskbar..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -value 0
############
Write-Host "Disabling the toast ads and spam notifications above the system tray..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
############
Write-Host "Disabling Lock Screen ads..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
############
Write-Host "Disabling subscribed ads..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
############
Write-Host "Restricting Windows Update P2P optimization to local network..." -foregroundcolor yellow
If ([System.Environment]::OSVersion.Version.Build -eq 10240) {
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
} ElseIf ([System.Environment]::OSVersion.Version.Build -le 14393) {
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 1
} Else {
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
}############
Write-Host "Disabling Windows Update P2P optimization..." -foregroundcolor yellow
If ([System.Environment]::OSVersion.Version.Build -eq 10240) {
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0
} Else {
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 100
}############
Write-Host "Disabling Xbox features..." -foregroundcolor yellow
Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
############
Write-Host "Disabling search for app in store for unknown extensions..." -foregroundcolor yellow
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
############
Write-Host "Hiding People icon..." -foregroundcolor yellow
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
}Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
############
Write-Host "Stopping and disabling WAP Push Service..." -foregroundcolor yellow
Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
Set-Service "dmwappushservice" -StartupType Disabled
############
Write-Host "Stopping and disabling Diagnostics Tracking Service..." -foregroundcolor yellow
Stop-Service "DiagTrack" -WarningAction SilentlyContinue
Set-Service "DiagTrack" -StartupType Disabled
############
Write-Host "Disabling Send Crash Reporting to Microsoft..." -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
############
Write-Host "Disabling Cortana..." -foregroundcolor yellow
If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
	New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
}Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
	New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
}Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
	New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
}Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
############
Write-Host "Disabling Website Access to Language List..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
############
Write-Host "Disabling Advertising ID..." -foregroundcolor yellow
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
############
Write-Host "Disabling Tailored Experiences..." -foregroundcolor yellow
If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent")) {
	New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
############
Write-Host "Disabling Feedback..." -foregroundcolor yellow
If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
	New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
}Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
############
Write-Host "Disabling automatic Maps updates..." -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
############
Write-Host "Disabling Location Tracking..." -foregroundcolor yellow
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
############
Write-Host "Disabling Background application access..." -foregroundcolor yellow
Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Exclude "Microsoft.Windows.Cortana*","Microsoft.Windows.ShellExperienceHost*" | ForEach-Object {
	Set-ItemProperty -Path $_.PsPath -Name "Disabled" -Type DWord -Value 1
	Set-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -Type DWord -Value 1
}############
Write-Host "Disabling Application suggestions..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
If ([System.Environment]::OSVersion.Version.Build -ge 17134) {
	$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
	Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
	Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
}############
Write-Host "Disabling Bing Search in Start Menu..." -foregroundcolor yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "AllowSearchToUseLocation" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
############
Write-Host "Disabling Windows Ink Space" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Type DWord -Value 0 -erroraction 'silentlycontinue'
############
Write-Host "Disabling Online Tips/Ads" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "AllowOnlineTips" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
############
Write-Host "Disabling all Windows telemetry" -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Type DWord -Value 0
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
############
Write-Host "Disabling Wi-Fi Sense..." -foregroundcolor yellow
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0
############
Write-Host "Disabling SmartScreen Filter..." -foregroundcolor yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Force | Out-Null
}Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 0
############
Write-Host "Disabling 3D Objects folder in File Explorer" -foregroundcolor yellow
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
############
if($initialsetting -eq "3")
{	Write-Host
	Write-Host " Full Advanced Settings" -foregroundcolor yellow
	Write-Host " ----------------------------------------" -foregroundcolor cyan
}if($confirmationwallpaperq -eq "y")
{	Write-Host "Increasing wallpaper compression quality to 100" -foregroundcolor yellow
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "JPEGImportQuality" -Type DWord -Value 100
}if($confirmationshowfileex -eq "y")
{	Write-Host "Enabling show file extensions" -foregroundcolor yellow
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
}if($confirmationshowhiddenfiles -eq "y")
{	Write-Host "Enabling show hidden files" -foregroundcolor yellow
	Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1
}if($confirmationrdp -eq "y")
{	Write-Host "Enabling Allow Remote Desktop Connection" -foregroundcolor yellow
	(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
	(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
	Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true
}if($confirmationrdp -eq "y")
{	Write-Host "Enabling Allow Wake On LAN" -foregroundcolor yellow
	$Adapters = gwmi MSPower_DeviceWakeEnable -namespace 'root\wmi'
	if($Adapters.count -gt 0){
		foreach($Adapter in $Adapters){$Adapter.enable = "$True"}
	}else{$Adapters.enable = "$True"}
	$Adapters = gwmi MSNdis_DeviceWakeOnMagicPacketOnly -namespace 'root\wmi'
	if($Adapters.count -gt 0){
		foreach($Adapter in $Adapters){$Adapter.enablewakeonmagicpacketonly = "$True"}
	}else{$Adapters.enablewakeonmagicpacketonly = "$True"}
}###########################################################################
# Remove all Windows store apps except WindowsStore, Calculator and Photos
##########################################################################
if($confirmationappremoval -eq "y")
{Write-Host "Removing all Windows store apps expect Windows Store, Calculator and Photos..." -foregroundcolor yellow
	Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} | where-object {$_.name -notlike "*.NET*"} | where-object {$_.name -notlike "*.VCLibs*"} | Remove-AppxPackage -erroraction 'silentlycontinue'
	Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.packagename -notlike "*Microsoft.Windows.Photos*"} | where-object {$_.name -notlike "*.NET*"} | where-object {$_.name -notlike "*.VCLibs*"} | Remove-AppxProvisionedPackage -online | Out-Null
}###########################################################################
# Taskbar pin app function
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
			Write-Host
		}
	}
###########################################################################
# Unpin everything from the start menu
##########################################################################
	Get-StartApps | ForEach-Object { Pin-App $_.name -unpin }
###########################################################################
# Delete all desktop icons
##########################################################################
	Write-Host "Removing default desktop icons"	
	Remove-Item "C:\Users\*\Desktop\Microsoft Edge.lnk" -force
}###########################################################################
# Turn Off All Windows 10 Telemetry
##########################################################################
Write-Host "Turning off all Windows telemetry and ads" -foregroundcolor yellow
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
	Write-Host "Removing OneDrive leftovers"
	rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
	rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
	rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"
	Write-Host "Removing OneDrive from explorer sidebar"
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
	mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
	mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
	Remove-PSDrive "HKCR"
	Write-Host "Removing OneDrive run option for new users"
	reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
}###########################################################################
# Download MVPS hosts file and backup current hosts file
##########################################################################
if($confirmationonedrive -eq "y")
{	Write-Host "Backing up hosts file to $($env:SystemRoot)\System32\drivers\etc\hosts.bak" -foregroundcolor yellow
	Copy-Item "$($env:SystemRoot)\System32\drivers\etc\hosts" -Destination "$($env:SystemRoot)\System32\drivers\etc\hosts.bak"
	(New-Object Net.WebClient).DownloadString('http://winhelp2002.mvps.org/hosts.txt') | out-file "$($env:SystemRoot)\System32\drivers\etc\hosts" -force
}###########################################################################
# Start explorer.exe
##########################################################################
Write-Host "Restarting explorer.exe..." -foregroundcolor yellow
Invoke-Expression "start explorer.exe"
$rebootpending = Test-PendingReboot | Select-Object -Property IsRebootPending | Format-Wide
if($rebootpending = "True")
{	Write-Host
	Write-Host "Complete" -foregroundcolor green
	Write-Host
	Write-Warning "Reboot Required"
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
	Write-Host "Complete" -foregroundcolor green
	Write-Host
	Write-Host "No Reboot Required" -foregroundcolor yellow
	Read-Host "Press ENTER to exit"
}Exit