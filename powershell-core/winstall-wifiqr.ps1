#############################################
#	Title:      Windows 10 WifiQR Script    #
#	Creator:	Ad3t0	                    #
#	Date:		11/06/2018             	    #
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
function New-QR {
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "low")]
		param(
	[Parameter(
	Mandatory=$false,
	ValueFromPipeline=$false)]
	$chs = "150x150",
		[Parameter(
	Mandatory=$false,
	ValueFromPipeline=$false)]
	$ECL = "L",
		[Parameter(
	Mandatory=$false,
	ValueFromPipeline=$false)]
	$Enc = "UTF-8",
		[Parameter(
	Mandatory=$false,
	Position=1,
	ValueFromPipelineByPropertyName = $true)]
	[string]$fileName="$env:temp\QR.png",
		[Parameter(
	Mandatory=$false,
	ValueFromPipeline=$false)]
	$margin = 4,
		[Parameter(
	Mandatory=$true,
	Position=0,
	HelpMessage="Message to be encoded",
	ValueFromPipelineByPropertyName = $true)]
	[object]$Message,
		[Parameter(
	Mandatory=$false,
	ValueFromPipeline=$false)]
	$Size = "M"
	)
		process
	{
		switch ($Size)
		{
			"S" {$chs = "75x75"}
			"M" {$chs = "150x150"}
			"L" {$chs = "300x300"}
			"X" {$chs = "547x547"}
			"C" {If ($chs -imatch "[5-9][0-9][x][5-9][0-9]" -or  $chs -imatch "[1-5][0-4][0-9][x][1-5][0-4][0-9]") {write-verbose "Custom chs $chs"} else {Write-verbose "chs invalid, changing to default - 150x150"; $chs = "150x150"};
				$split = $chs.split("x");
				If ($split[0] -ne $split[1] ){$chs = "$($split[0])x$($split[0])"; Write-Verbose "Making chs symmetrical $chs"}
				If ($split[0] -gt 547){$chs = "547x547"}
			}
			default {$chs = "150x150"}
		}
		switch ($ECL)
		{
			"L" {$chld = "L"}
			"M" {$chld = "M"}
			"Q" {$chld = "Q"}
			"H" {$chld = "H"}
			default {$chld = "L"}
		}
		switch ($Enc)
		{
			"UTF-8" {$choe = "UTF-8"}
			"Shift_JIS" {$choe = "Shift_JIS"}
			"ISO-8859-1" {$choe = "ISO-8859-1"}
			default {$choe = "UTF-8"}
		}
		$Limit = @{
			"LN"=7089;
			"LA"=4296;
			"MN"=5596;
			"MA"=3391;
			"QN"=3993;
			"QA"=2420;
			"HN"=3057;
			"HA"=1852;
		}
		$NorA="N"
		for ($a = 1; $a -le $Message.length; $a++) {if (!($Message.substring($a-1,1) )){$NorA="A"; break}}
		if ($Message.length -gt $Limit."$chld$NorA")
		{
			Write-Verbose "Message Size Limit Exceeded"; Break
		}
		else
		{
			Write-Verbose "Message $(if ($NorA -eq "N"){"Purely Numeric"}else{"Not Purely Numeric"})"
			Write-Verbose "Max Message Length $($Limit."$chld$NorA")"
			Write-Verbose "Message Length $($Message.length) OK"
		}
		$chld = "$chld`|$margin"
		$Message = $Message -replace(" ", "+")
		$URL = "https://chart.googleapis.com/chart?chs=$chs&cht=qr&chld=$chld&choe=$choe&chl=$($Message)"
		$req = [System.Net.HttpWebRequest]::Create($url)
		$req.Proxy = [System.Net.WebRequest]::DefaultWebProxy
		$req.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
		try {$res = $req.GetResponse()} catch {Write-host $URL; Write-error $error[0]; break}
		if($res.StatusCode -eq 200)
		{
			$reader = $res.GetResponseStream()
			try {$writer = new-object System.IO.FileStream $fileName, "Create"}catch{Write-host "Invalid File Path?"; break}
			[byte[]]$buffer = new-object byte[] 4096
			do
			{
				$count = $reader.Read($buffer, 0, $buffer.Length)
				$writer.Write($buffer, 0, $count)
			} while ($count -gt 0)
			$reader.Close()
			$writer.Flush()
			$writer.Close()
			$QRProperties = @{
				FullName = (ls $filename).fullname
				DataSize = $Message.length
				Dimensions = $chs
				ECLevel = $chld.split("|")[0]
				Margin = $chld.split("|")[1]
			}
			New-Object PSObject -Property $QRProperties
		}
		Write-Verbose "FileName $fileName"
		Write-Verbose "chs $chs"
		Write-Verbose "chld $chld"
		Write-Verbose "choe $choe"
		Write-Verbose "URL $URL"
		Write-Verbose "Http Status Code $($res.StatusCode)"
		Write-Verbose "Message $Message"
		$res.Close()
	}
}function header
{	Write-host " #####################################"
	Write-Host " #                                   #"
	Write-host " #     " -NoNewLine
	Write-host "Windows 10 WifiQR Script" -foregroundcolor yellow -NoNewLine
	Write-host "      #"
	Write-host " #          " -NoNewLine
	Write-host "Version: " -foregroundcolor yellow -NoNewLine
	Write-host $ver -foregroundcolor cyan -NoNewLine
	Write-host "           #"
	Write-host " #                                   #"
	Write-host " #####################################"
	Write-host
		
}header
$data = netsh wlan show profile
$datePattern = [Regex]::new("(?<=All User Profile     : ).*\S")
$matches = $datePattern.Matches($data)
$wifiprofile = $matches.Value
$data2 = netsh wlan show profile $matches.Value key=clear
$datePattern2 = [Regex]::new("(?<=Key Content            : ).*\S")
$matches2 = $datePattern2.Matches($data2)
$wifikey = $matches2.Value.split(' ')[0]
$wifilink = "WIFI:S:$($wifiprofile);T:WPA;P:$($wifikey);;"
$wifilink = [uri]::EscapeDataString($wifilink)
(New-QR -message $wifilink -Size X -ECL H -Verbose).fullname | Out-Null
start "$($env:TEMP)\QR.png"
