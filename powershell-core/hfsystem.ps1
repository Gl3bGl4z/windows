#########################################
#	Wake On Lan and Configuration		#
#	Creator:	Adam Curtis	            #
#	Date:		5/20/2017             	#
#########################################


$ver = "1.0"
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}
else
{
	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	$newProcess.Arguments = $myInvocation.MyCommand.Definition;
	$newProcess.Verb = "runas";
	[System.Diagnostics.Process]::Start($newProcess);
	exit
}
#####
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowSuperHidden -Value 1
Stop-Process -processName: Explorer
regset
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location $dir
$rec = "\*.*"


function header
{
	clear-host
	Write-host "#####################################################"
	Write-host "#                           	   		    #"
	Write-host "#       Set File 	   	    #"
	Write-host "#                           	  		    #"
	Write-host "#       Version: "$ver"		        	    #"
	Write-host "#                           	   		    #"
	Write-host "#       Date: 5/20/2017	        	   	    #"
	Write-host "#                           	   		    #"
	Write-host "#####################################################"
	Write-host " "
	Write-host " "
}

function fileorfolder
{
	Write-Host "  ----------------------------------------"
	" "
	Write-Host " 1 - Folder"
	Write-Host " 2 - File"
	" "
	" "
	$fileorfolder = Read-Host -Prompt "Input option"
	if ($fileorfolder -eq "1")
	{
		$forfs = "FolderBrowserDialog"
		$filen = "SelectedPath"
		mainselect
	}
	if ($fileorfolder -eq "2")
	{
		$forfs = "OpenFileDialog"
		$filen = "FileName"
		mainselect
	}
}


function mainf
{
	header

	
	" "


	" "
	" "
	Write-Host "  Options" -foreground "yellow"
	" "
	Write-Host "  ----------------------------------------"
	" "
	Write-Host " 1 - System and Hidden (+s +h)"
	Write-Host " 2 - Hidden (+h)"
	Write-Host " 3 - Normal (-s -h)"
	" "
	" "
	Write-Host "Restarting Explorer.exe to show hidden files and folders please wait..." -foreground "yellow" | Out-Null
	" "
	$runs = Read-Host -Prompt "Input option"
	fileorfolder
}







function mainselect 
{

	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
	Out-Null     

	$objForm = New-Object System.Windows.Forms.$($forfs)
	$Show = $objForm.ShowDialog()
	$modpath = $objForm.$($filen)
	If ($Show -eq "OK")
	{
		if ($runs -eq "1")
		{
			if ($fileorfolder -eq "1")
			{
				attrib +s +h /s /d "$($modpath)\*.*"
				attrib +s +h /s /d "$($modpath)"
				
			}
			if ($fileorfolder -eq "2")
			{
				attrib +s +h /s /d "$($modpath)"
				
			}
		}
		if ($runs -eq "2")
		{
			if ($fileorfolder -eq "1")
			{
				attrib +h /s /d "$($modpath)\*.*"
				attrib +h /s /d "$($modpath)"
				
			}
			if ($fileorfolder -eq "2")
			{
				attrib +h /s /d "$($modpath)"
				
			}
		}
		if ($runs -eq "3")
		{
			if ($fileorfolder -eq "1")
			{
				attrib -s -h /s /d "$($modpath)\*.*"
				attrib -s -h /s /d "$($modpath)"
				
			}
			if ($fileorfolder -eq "2")
			{
				attrib -s -h /s /d "$($modpath)"
				
			}
		}
	}
	Else
	{
		Write-Error "Operation cancelled by user."
	}
}



mainf
$reloop = Read-Host "Input [y\Y]Yes to return to the beginning press enter to quit"
clear-host

while ($reloop -eq "y" -or $reloop -eq "yes")
{

Stop-Process -processName: Explorer
	$runs = "0"
	mainf
	" "
	" "
	" "
	$reloop = Read-Host "Input [y\Y]Yes to return to the beginning press enter to quit"
	clear-host
}
	Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowSuperHidden -Value 0
Stop-Process -processName: Explorer