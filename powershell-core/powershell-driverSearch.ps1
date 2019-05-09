#############################################
#	Title:      Google Drivers Update Check #
#	Creator:	Ad3t0	                    #
#	Date:		05/01/2018             	    #
#############################################
$ver = "1.0.5"
$text = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/

    Driver Update Google
  
----------------------------------------
  
'@
Write-Host $text
$systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=','')
$systemmodel = $systemmodel + "drivers"
$systemmodel = [uri]::EscapeDataString($systemmodel)
$systemmodel = $systemmodel -replace ('%20%20%20%20%20%20%20','')
$URL = "https://www.google.com/search?q=$($systemmodel)"
start $URL
