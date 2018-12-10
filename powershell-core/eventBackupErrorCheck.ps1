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
$ver = "1.0.2"

$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2"
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
function header
{	Write-host " #####################################"
	Write-Host " #                                   #"
	Write-host " #       " -NoNewLine
	Write-host "Windows Server BackupCheck" -foregroundcolor yellow -NoNewLine
	Write-host "     #"
	Write-host " #          " -NoNewLine
	Write-host "Version: " -foregroundcolor yellow -NoNewLine
	Write-host $ver -foregroundcolor cyan -NoNewLine
	Write-host "           #"
	Write-host " #                                   #"
	Write-host " #####################################"
	Write-host
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


while($inputOption -ne "1" -and $inputOption -ne "2")
{	
	if(([string]::IsNullOrEmpty($inputOption)) -ne $true)
	{	
		if($inputOption -ne "1" -and $inputOption -ne "2")
		{
			Write-Warning "Invalid option"
		}
	}
	Write-Host "  ----------------------------------------"
	Write-Host " 1 - BackupCheck Example Run"
	Write-Host " 2 - BackupCheck Schedule Task"
	Write-Host
	$inputOption = Read-Host -Prompt "Input option"
}

$eventLogStatus = Get-EventLog -LogName "Application" -Message "*backup*" -EntryType Error
$vssStatus = vssadmin list writers


if($inputOption -eq 1)
{
	if($eventLogStatus)
	{
		$eventLogStatus
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
}


if($inputOption -eq 2)
{
	New-Item -Path "HKLM:\Software\" -Name BackupCheck
	$regPath = "HKLM:\Software\BackupCheck\"
	$SMTPServer = Read-Host "SMTP Server"
	$SMTPPort = Read-Host "SMTP Port"
	$smtpUser = Read-Host "SMTP Sending Address"
	
	
	
	$secureHash = Read-Host "SMTP Sending Address Password" -AsSecurestring | ConvertFrom-SecureString
	Set-ItemProperty -Path $regPath -Name "secureHash" -Value $secureHash -Force
	$intHash = Get-ItemProperty $regPath -Name "secureHash"
	$password = $intHash.secureHash | ConvertTo-SecureString
	$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $smtpUser, $smtpPassword
	#$mycredentials = Get-Credential
	
	$To = Read-Host "SMTP Receiving Address"
	$Cc = Read-Host "Secondary SMTP Receiving Address (Optional)"
	
	
	#$password = Get-content "$($env:ALLUSERSPROFILE)\BackupCheck\passhash.txt" | ConvertTo-SecureString

	
	$Subject = "Here's the Email Subject"
	$Body = "This is what I want to say"
	
	
	
	
	#$secpasswd = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
	#$mycreds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)
	
	
	
	
	
	Send-MailMessage -From $smtpUser -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credentials -DeliveryNotificationOption OnSuccess
	#Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $password -DeliveryNotificationOption OnSuccess
	Read-Host "Mail sent press ENTER to exit"
	
	

	New-ItemProperty -Path $regPath -Name "SMTPServer" -Value $SMTPServer
	New-ItemProperty -Path $regPath -Name "SMTPPort" -Value $SMTPPort
	New-ItemProperty -Path $regPath -Name "smtpUser" -Value $smtpUser
	New-ItemProperty -Path $regPath -Name "To" -Value $To
	New-ItemProperty -Path $regPath -Name "Cc" -Value $Cc
	
}



####################################
#Working
###################################
if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\" ))
{	New-Item -Path $env:ProgramData -Name "winstall-core" -ItemType "directory" -Force >$null 2>&1
}

	if($eventLogStatus)
	{
		$eventLogStatus
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


if(!(Test-Path -Path "$($env:ProgramData)\winstall-core\empasshash" ))
{
    $pass = Read-Host "Enter Password"
}

$pass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$($env:ProgramData)\winstall-core\empasshash"

$User = "ambientweatheralerts@gmail.com"

$File = "$($env:ProgramData)\winstall-core\empasshash"

$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)

Send-MailMessage -From $User -to "ambientweatheralerts@gmail.com" -Subject "subject" -Body "body" -SmtpServer "smtp.gmail.com" -port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess

