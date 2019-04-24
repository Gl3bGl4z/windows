#############################################
#	Title:      Belarc Audit			    #
#	Creator:	Ad3t0	                    #
#	Date:		04/16/2019             	    #
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
$ver = "1.0.7"
$empassFile = "$($env:ProgramData)\powershell-bin\empasshash"
Remove-Item $empassFile > $null 2>&1
if (!(Test-Path -Path "$($env:ProgramData)\powershell-bin\"))
{ New-Item -Path $env:ProgramData -Name "powershell-bin" -ItemType "directory" -Force > $null 2>&1
}
$email = Read-Host "Enter SMTP email account"
$empass = Read-Host "Enter SMTP email password"
$empass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File $empassFile
$subject = Read-Host "Enter email subject"
$output = "C:\Program Files (x86)\Belarc\BelarcAdvisor\System\tmp\($($env:COMPUTERNAME)).html"
$belarcloc = "C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
if (Test-Path $belarcloc)
{ Remove-Item $output > $null 2>&1
	.$belarcloc
} else
{ Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature disable -n=checksumFiles
	choco install belarcadvisor
	Remove-Item "C:\Users\Public\Desktop\Belarc Advisor.lnk" > $null 2>&1
} while (!(Test-Path $output)) {
	Start-Sleep 10
} $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $email,(Get-Content $empassFile | ConvertTo-SecureString)
while ($sendSuccess -ne 1) {
	try
	{
		Send-MailMessage -From $email -To $email -Subject $subject -Attachments $output -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
		$sendSuccess = 1
	} catch
	{
		Write-Host "Send failed try to input SMTP again" -ForegroundColor red
		$email = Read-Host "Enter SMTP email account"
		$empass = Read-Host "Enter SMTP email password"
		$empass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File $empassFile
		$sendSuccess = 0
	}
} exit
