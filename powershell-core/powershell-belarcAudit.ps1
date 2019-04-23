#############################################
#	Title:      Belarc Audit			    #
#	Creator:	Ad3t0	                    #
#	Date:		04/16/2019             	    #
#############################################
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
$email = Read-Host "Enter SMTP email account"
if(!(Test-Path -Path "$($env:ProgramData)\powershell-bin\" ))
{	New-Item -Path $env:ProgramData -Name "powershell-bin" -ItemType "directory" -Force >$null 2>&1
}$empassFile = "$($env:ProgramData)\powershell-bin\empasshash"
if(!(Test-Path -Path "$($env:ProgramData)\powershell-bin\empasshash" ))
{	$empass = Read-Host "Enter SMTP email password"
$empass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File $empassFile
}$subject = Read-Host "Enter email subject"
#[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
#$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
#$Show = $objForm.ShowDialog()
#$modpath = $objForm.SelectedPath
$output = "C:\Program Files (x86)\Belarc\BelarcAdvisor\System\tmp\($($env:COMPUTERNAME)).html"
$belarcloc = "C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
if(Test-Path $belarcloc)
{	Remove-Item $output
	. $belarcloc
}else
{	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature disable -n=checksumFiles
	choco install belarcadvisor
	Remove-Item "C:\Users\Public\Desktop\Belarc Advisor.lnk" >$null 2>&1
}while(!(Test-Path $output)) {
	Start-Sleep 10
}$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $email, (Get-Content $empassFile | ConvertTo-SecureString)
Send-MailMessage -From $email -To $email -Subject $subject -Attachments $output -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
#Copy-Item $output -Destination $modpath
Exit