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
$ver = "1.0.3"
Write-Host "Name list format should match:"
Write-Host
Write-Host "Firstname Lastname" -foregroundcolor yellow
Write-Host "John Doe" -foregroundcolor yellow
Write-Host "Jane Doe" -foregroundcolor yellow
Write-Host
Write-Host "A file selection dialog will open next. Choose the file containing the names of users to be added."
Read-Host "Press ENTER to continue"
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$forfs = "OpenFileDialog"
$filen = "FileName"
$objForm = New-Object System.Windows.Forms.$($forfs)
$show = $objForm.ShowDialog()
$modPath = $objForm.$($filen)
Write-Host "Selected file containing users is:"
Write-Host
Write-Host $modPath -foregroundcolor yellow
Write-Host
while($initialPassConfirm -ne "y")
{	
	$initialPass = Read-Host "Enter initial default password for all users"
	Write-Host "Initial default password will be:"
	Write-Host
	Write-Host $initialPass -foregroundcolor yellow
	Write-Host
	$initialPassConfirm = Read-Host "Is this correct? [y/n]"
}
Get-Content $modPath | ForEach-Object {$Split = $_.Split(" "); $given=$Split[0]; $sur=$Split[1]; New-Item -Path ("C:\Shares\Users\" + ($given + "." + $sur).ToLower()) -ItemType "directory"}
Get-Content $modPath | ForEach-Object {$Split = $_.Split(" "); $given=$Split[0]; $sur=$Split[1]; New-ADUser -GivenName $given -Surname $sur -Name ($given + " " + $sur) -UserPrincipalName (($given + "." + $sur + "@" + "$env:USERDNSDOMAIN")).ToLower() -SamAccountName ($given + "." + $sur).ToLower() -AccountPassword (ConvertTo-SecureString -AsPlainText $initialPass -Force) -Enabled $true -ChangePasswordAtLogon $false -HomeDrive "U:" -HomeDirectory ("\\$($env:COMPUTERNAME)\Users\" + ($given + "." + $sur).ToLower())  -Verbose}
New-SMBShare -Name "Users" -Path "C:\Shares\Users\" #-FullAccess "home.home\Domain Users"