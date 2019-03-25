#############################################
#	Title:      Windows 10 EssentialUtils   #
#	Creator:	Ad3t0	                    #
#	Date:		11/07/2018             	    #
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
for($I = 1; $I -lt 101; $I++ )
{	
    Write-Progress -Activity Updating -Status 'Main Progress' -PercentComplete $I -CurrentOperation MainBackupProg
	
    for($j = 1; $j -lt 101; $j++ )
    {
		$j = Get-Random -Maximum 101
        Write-Progress -Id 1 -Activity Updating -Status 'Progress' -PercentComplete $j -CurrentOperation InnerBackupProg
    }
}