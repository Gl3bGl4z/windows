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
$ver = "1.0.1"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco feature disable -n=checksumFiles
choco install belarcadvisor
Remove-Item "C:\Users\Public\Desktop\Belarc Advisor.lnk" >$null 2>&1
."C:\Program Files (x86)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
$Show = $objForm.ShowDialog()
$modpath = $objForm.SelectedPath
$output = "C:\Program Files (x86)\Belarc\BelarcAdvisor\System\tmp\(" + $env:COMPUTERNAME + ").html"
while (!(Test-Path $output)) {
	Start-Sleep 100
}Copy-Item "C:\Program Files (x86)\Belarc\BelarcAdvisor\System\tmp\(" + $env:COMPUTERNAME + ").html" -Destination $modpath