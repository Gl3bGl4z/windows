#############################################
#	Title:      Windows 10 SysInfo Script   #
#	Creator:	Ad3t0	                    #
#	Date:		10/27/2018             	    #
#############################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}else
{	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}##############
$ver = "1.0.1"
$strComputer = "."
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" -computername $strComputer
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId"
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName"
$mobomodel = Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BaseBoardProduct"
$mobomanu = Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BaseBoardManufacturer"
function header
{	Write-host " #####################################"
	Write-Host " #                                   #"
	Write-host " #    " -NoNewLine
	Write-host "Windows 10 SysInfo Script" -foregroundcolor yellow -NoNewLine
	Write-host "      #"
	Write-host " #          " -NoNewLine
	Write-host "Version: " -foregroundcolor yellow -NoNewLine
	Write-host $ver -foregroundcolor cyan -NoNewLine
	Write-host "           #"
	Write-host " #                                   #"
	Write-host " #####################################"
	Write-host
	foreach ($objItem in $colItems) {
		Write-Host
		Write-Host " CPU Model: " -foregroundcolor yellow -NoNewLine
		Write-Host $objItem.Name -foregroundcolor white	
		Write-Host " System: " -foregroundcolor yellow -NoNewLine
		Write-Host $productname.ProductName $currentversion.ReleaseId -foregroundcolor white	
		Write-Host " PC Name: " -foregroundcolor yellow -NoNewLine
		Write-Host $env:COMPUTERNAME -foregroundcolor white
		Write-Host " Username: " -foregroundcolor yellow -NoNewLine
		Write-Host $env:USERNAME -foregroundcolor white
		Write-Host " Domain: " -foregroundcolor yellow -NoNewLine
		Write-Host $env:LOGONSERVER -foregroundcolor white
		Write-Host " Manufacturer: " -foregroundcolor yellow -NoNewLine
		Write-Host $mobomanu.BaseBoardManufacturer -foregroundcolor white
		Write-Host " Motherboard: " -foregroundcolor yellow -NoNewLine
		Write-Host $mobomodel.BaseBoardProduct -foregroundcolor white
		Write-Host
	}
}header