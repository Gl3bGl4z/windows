##############################################
#	Title:      Windows Server BackupCheck	 #
#	Creator:	Ad3t0	                     #
#	Date:		11/20/2018             	     #
##############################################
if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\" ))
{	New-Item -Path $env:ProgramData -Name "winstall-core" -ItemType "directory" -Force #>$null 2>&1
}if($eventLogStatus)
{	$eventLogStatus
	$eventLogStatusConfirmed = "True"
	Write-Host "Event log Windows Backup abnormality detected" -foregroundcolor red
	Write-Host
}
if($vssStatus -like "*Failed*" -like "*Stuck*" -like "*Unstable*" )
{
	$vssStatus
	$vssStatusConfirmed = "True"
	Write-Host "Event log VSS Writer abnormality detected" -foregroundcolor red
	Write-Host
}
if($vssStatusConfirmed -or $eventLogStatusConfirmed)
{
	Write-Warning "Backup errors were detected"
	Write-Host
	Read-Host "Press ENTER to exit"
}
else
{
	Write-Host "No Errors detected" -foregroundcolor green
	Write-Host
	Read-Host "Press ENTER to exit"
}


$empassFile = "$($env:ProgramData)\winstall-core\empasshash"

$User = Read-Host "Enter the SMTP email account"

$empass = Read-Host "Enter SMTP email password"

$empass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File $empassFile

$To = Read-Host "Enter the receiving email address"

$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $empassFile | ConvertTo-SecureString)

Send-MailMessage -From $User -To $To -Subject "subject" -Body "body" -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess