######################################################
#	Title:      Active Directory Batch Add User	     #
#	Creator:	Ad3t0	                             #
#	Date:		12/12/2018             	             #
######################################################
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
} $ver = "1.1.1"
$strComputer = "."
$colItems = Get-WmiObject -Class "Win32_Processor" -Namespace "root/CIMV2"
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
$systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=','')
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
function header
{ $text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
	$text2 = ' Active Directory Batch Add User'
	$text3 = "        Version: "
	Write-Host $text1
	Write-Host $text2 -ForegroundColor Yellow
	Write-Host $text3 -ForegroundColor Gray -NoNewline
	Write-Host $ver -ForegroundColor Green
	Write-Host $text
	Write-Host " System Model: " -ForegroundColor yellow -NoNewline
	Write-Host $systemmodel -ForegroundColor white
	Write-Host " Operating System: " -ForegroundColor yellow -NoNewline
	Write-Host $productname.ProductName $currentversion.ReleaseId -ForegroundColor white
	Write-Host " PC Name: " -ForegroundColor yellow -NoNewline
	Write-Host $env:COMPUTERNAME -ForegroundColor white
	Write-Host " Username: " -ForegroundColor yellow -NoNewline
	Write-Host $env:USERNAME -ForegroundColor white
	Write-Host " Domain: " -ForegroundColor yellow -NoNewline
	Write-Host $env:USERDNSDOMAIN -ForegroundColor white
	Write-Host
} header
Write-Host
Write-Host "Name list format should match:"
Write-Host
Write-Host "Firstname Lastname" -ForegroundColor yellow
Write-Host "John Snow" -ForegroundColor yellow
Write-Host "Elon Musk" -ForegroundColor yellow
Write-Host "Jason Bourne" -ForegroundColor yellow
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
Write-Host $modPath -ForegroundColor yellow
Write-Host
while ($initialPassConfirm -ne "y")
{ $initialPass = Read-Host "Enter initial default password for all users"
	Write-Host "Initial default password will be:"
	Write-Host
	Write-Host $initialPass -ForegroundColor yellow
	Write-Host
	$initialPassConfirm = Read-Host "Is this correct? [y/n]"
} Write-Host
Write-Host "Drive letter Z: will be used as the mapped home drive for all users"
Write-Host "Home drive shares will be created under C:\Shares\Users\"
Write-Host "An OU named Employees will be created and all added uses will be put in this OU"
Write-Host "Each user will have drives.bat as their logon script"
Write-Host
Read-Host "The script will now run press ENTER to continue"
Get-Content $modPath | ForEach-Object { $Split = $_.Split(" "); $given = $Split[0]; $sur = $Split[1]; New-Item -Path ("C:\Shares\Users\" + ($given + "." + $sur).ToLower()) -ItemType "directory" }
New-ADOrganizationalUnit -Name "Employees" | Out-Null
$domainName = $env:USERDNSDOMAIN.Split(".")
Get-Content $modPath | ForEach-Object { $Split = $_.Split(" "); $given = $Split[0]; $sur = $Split[1]; New-ADUser -Path ("ou=Employees,dc=" + $domainName[0] + ",dc=" + $domainName[1]) -GivenName $given -Surname $sur -Name ($given + " " + $sur) -UserPrincipalName (($given + "." + $sur + "@" + $env:USERDNSDOMAIN)).ToLower() -SamAccountName ($given + "." + $sur).ToLower() -AccountPassword (ConvertTo-SecureString -AsPlainText $initialPass -Force) -Enabled $true -ChangePasswordAtLogon $false -HomeDrive "Z:" -HomeDirectory ("\\$($env:COMPUTERNAME)\" + ($given + "." + $sur).ToLower() + "$") -ScriptPath "drives.bat" -Verbose }
Get-Content $modPath | ForEach-Object { $Split = $_.Split(" "); $given = $Split[0]; $sur = $Split[1]; New-SmbShare -Name (($given + "." + $sur).ToLower() + "$") -Path ("C:\Shares\Users\" + ($given + "." + $sur).ToLower()) -ChangeAccess ((($given + "." + $sur).ToLower() + "@" + $env:USERDNSDOMAIN)) }
