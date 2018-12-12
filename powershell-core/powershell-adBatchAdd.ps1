######################################################
#	Title:      Active Directory Batch Add User	     #
#	Creator:	Ad3t0	                             #
#	Date:		12/12/2018             	             #
######################################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if($myWindowsPrincipal.IsInRole($adminRole))
{	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	Clear-Host
}else
{	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}#####
$ver = "1.0.0"
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
$forfs = "OpenFileDialog"
$filen = "FileName"
$objForm = New-Object System.Windows.Forms.$($forfs)
$show = $objForm.ShowDialog()
$modPath = $objForm.$($filen)
while($initialPassConfirm -ne "n" -and $initialPassConfirm -ne "y")
{	
	$initialPass = Read-Host "Enter initial default password for all users"
	Write-Host "Initial default password will be: $($initialPass)"
	$initialPassConfirm = Read-Host "Is this correct? [y/n]"
}Get-Content $modPath | ForEach-Object {$Split = $_.Split(" "); $given=$Split[0]; $sur=$Split[1]; New-ADUser -GivenName $given -Surname $sur -Name ($given + " " + $sur) -UserPrincipalName (($sur + "@" + "$env:userdnsdomain")).ToLower() -SamAccountName ($sur).ToLower() -AccountPassword (ConvertTo-SecureString -AsPlainText $initialPass -Force) -Enabled $true -ChangePasswordAtLogon $true -Verbose}
