############################################################
#	Title:      Windows 10 Add PowerShell to Context Menu  #
#	Creator:	Ad3t0	                                   #
#	Date:		10/21/2018             	                   #
############################################################
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
}#####
$ver = "1.0"
Write-host "####################################################"
Write-host "#       Windows 10 Add PowerShell to Context Menu  #"
Write-host "#       Version: "$ver"	                           #"
Write-host "####################################################"
Write-host
Write-host
while($confirmationgef -ne "n" -and $confirmationgef -ne "y")
{	
	$confirmationgef = Read-Host "Add an Open ""Open Windows PowerShell Here as Administrator"" to the context menu? [y/n]"
}if($confirmationgef -eq "y")
{	$menu = 'Open Windows PowerShell Here as Administrator'
	$command = "$PSHOME\powershell.exe -NoExit -NoProfile -Command ""Set-Location '%V'"""
	'directory', 'directory\background', 'drive' | ForEach-Object {
		New-Item -Path "Registry::HKEY_CLASSES_ROOT\$_\shell" -Name runas\command -Force |
		Set-ItemProperty -Name '(default)' -Value $command -PassThru |
		Set-ItemProperty -Path {$_.PSParentPath} -Name '(default)' -Value $menu -PassThru |
		Set-ItemProperty -Name HasLUAShield -Value ''
	}
}Read-Host "Press any key to exit"
Exit