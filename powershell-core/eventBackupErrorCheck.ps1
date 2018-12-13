##############################################
#	Title:      Windows Server BackupCheck	 #
#	Creator:	Ad3t0	                     #
#	Date:		11/20/2018             	     #
##############################################
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
$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2"
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
$infoMessageBody = ("###############################################`nCPU Model: " + $colItems.Name + "`nSystem: " + $productname.ProductName + $currentversion.ReleaseId + "`nHostname: " + $env:COMPUTERNAME + "`nUsername: " + $env:USERNAME + "`nDomain: " + $env:USERDNSDOMAIN + "`n###############################################")
$empassFile = "$($env:ProgramData)\winstall-core\empasshash"
if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\" ))
{	New-Item -Path $env:ProgramData -Name "winstall-core" -ItemType "directory" -Force #>$null 2>&1
}if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\user" ))
{	$user = Read-Host "Enter the SMTP email account" | Out-File "$($env:ProgramData)\winstall-core\user"
}else
{$user = Get-Content "$($env:ProgramData)\winstall-core\user"
}if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\empasshash" ))
{	$empass = Read-Host "Enter SMTP email password"
$empass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File $empassFile
}$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $empassFile | ConvertTo-SecureString)
if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\to" ))
{	$to = Read-Host "Enter the receiving email address" | Out-File "$($env:ProgramData)\winstall-core\to"
}else
{$to = Get-Content "$($env:ProgramData)\winstall-core\to"
}$eventLogStatus = Get-EventLog -LogName "Application" -Message "*backup*" -EntryType Error
$vssStatus = vssadmin list writers
if($eventLogStatus)
{	$eventLogStatus
	$eventLogStatusConfirmed = "True"
	Write-Host "Event log Windows Backup abnormality detected" -foregroundcolor red
	Write-Host
	$errorMessageBody = ""
	$eventRep = 0
	foreach ($event in $eventLogStatus) {
		$errorMessageBody = $errorMessageBody + ("###############################################`n" + $eventLogStatus.Source[$eventRep] + "`n" + $eventLogStatus.TimeGenerated[$eventRep] + "`n" + $eventLogStatus.Message[$eventRep] + "`n###############################################")
		$eventRep =+ 1
	}
	Send-MailMessage -From $user -To $to -Subject "Event log Windows Backup abnormality detected" -Body ($infoMessageBody + $errorMessageBody) -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
}if($vssStatus -like "*Failed*" -like "*Stuck*" -like "*Unstable*" )
{	$vssStatus
	$vssStatusConfirmed = "True"
	Write-Host "VSS Writer abnormality detected" -foregroundcolor red
	Write-Host
	Send-MailMessage -From $user -To $to -Subject "VSS Writer abnormality detected" -Body ($infoMessageBody + $vssStatus) -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
}if($vssStatusConfirmed -or $eventLogStatusConfirmed)
{	Write-Warning "Backup errors were detected"
	Write-Host
}else
{	Write-Host "No Errors detected" -foregroundcolor green
	Write-Host
}