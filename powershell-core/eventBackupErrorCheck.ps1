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
$ver = "1.0.7"
$vssStatusConfirmed = $null
$eventLogStatusConfirmed = $null
$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2"
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
$infoMessageBody = ("###############################################`nCPU Model: " + $colItems.Name + "`nSystem: " + $productname.ProductName + $currentversion.ReleaseId + "`nHostname: " + $env:COMPUTERNAME + "`nUsername: " + $env:USERNAME + "`nDomain: " + $env:USERDNSDOMAIN + "`n###############################################")
$empassFile = "$($env:ProgramData)\winstall-core\empasshash"
if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\" ))
{	New-Item -Path $env:ProgramData -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1
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
}if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\companyName" ))
{	$companyName = Read-Host "Enter the company name or a subject for the email" | Out-File "$($env:ProgramData)\winstall-core\companyName"
}else
{$companyName = Get-Content "$($env:ProgramData)\winstall-core\companyName"
}$eventLogStatus = Get-EventLog -LogName "Application" -Message "*shadow*" -EntryType Error
$vssStatus = vssadmin list writers
if($eventLogStatus)
{	$eventLogStatus
	$eventLogStatusConfirmed = "True"
	$eventRep = 0
	$errorMessageBody = $null
	foreach ($event in $eventLogStatus) {
		if($eventRep -lt 5)
		{
			$errorMessageBody = $errorMessageBody + ("###############################################`n" + $eventLogStatus.Source[$eventRep] + "`n" + $eventLogStatus.TimeGenerated[$eventRep] + "`n" + $eventLogStatus.Message[$eventRep] + "`n###############################################")
		}
		$eventRep = $eventRep + 1
	}
	Send-MailMessage -From $user -To $to -Subject ("BackupCheck: " + $companyName) -Body ($infoMessageBody + $errorMessageBody) -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
}if($vssStatus -like "*Failed*" -like "*Stuck*" -like "*Unstable*" )
{	$vssStatus
	$vssStatusConfirmed = "True"
	Send-MailMessage -From $user -To $to -Subject ("BackupCheck: " + $companyName) -Body ($infoMessageBody + $vssStatus) -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
}if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\taskInstalled" ))
{	$taskInstalled = Get-Content "$($env:ProgramData)\winstall-core\taskInstalled"
}if($taskInstalled -ne "1")
{$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/eventBackupErrorCheck.ps1'))}"'
	$trigger =  New-ScheduledTaskTrigger -Daily -At 8pm
	Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "BackupCheck" -Description "Daily Backup Check"
	$taskInstalled = "1" | Out-File "$($env:ProgramData)\winstall-core\taskInstalled"
}