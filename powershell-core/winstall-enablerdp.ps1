##################################################
#	Title:      Windows 10 Enable RDP\WOL Script #
#	Creator:	Ad3t0	                         #
#	Date:		10/21/2018             	         #
##################################################
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
}#####
$ver = "1.0"
Write-host "###########################################"
Write-host "#       Windows 10 Enable RDP\WOL Script  #"
Write-host "#       Version: "$ver"	                  #"
Write-host "###########################################"
Write-host
Write-host
while ($confirmationrdp -ne "n" -and $confirmationrdp -ne "y")
{	
	$confirmationrdp = Read-Host "Enable RDP on this PC? [y/n]"
}while ($confirmationwol -ne "n" -and $confirmationwol -ne "y")
{	
	$confirmationwol = Read-Host "Enable WOL on this PC? [y/n]"
}if ($confirmationrdp -eq "y")
{(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
	(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
	Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true
	Write-Host "Enabling Windows RDP completed successfully."
}if ($confirmationwol -eq "y")
{$Adapters = gwmi MSPower_DeviceWakeEnable -namespace 'root\wmi'
	if ($Adapters.count -gt 0){
		foreach ($Adapter in $Adapters){$Adapter.enable = "$True"}
	}else{$Adapters.enable = "$True"}
	$Adapters = gwmi MSNdis_DeviceWakeOnMagicPacketOnly -namespace 'root\wmi'
	if ($Adapters.count -gt 0){
		foreach ($Adapter in $Adapters){$Adapter.enablewakeonmagicpacketonly = "$True"}
	}else{$Adapters.enablewakeonmagicpacketonly = "$True"}
	Write-Host "Enabling Windows RDP completed successfully."
}Read-Host "Press any key to exit"