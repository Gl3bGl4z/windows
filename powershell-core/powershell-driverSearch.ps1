#############################################
#	Title:      Google Drivers Update Check #
#	Creator:	Ad3t0	                    #
#	Date:		05/01/2018             	    #
#############################################
$ver = "1.0.4"
$systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=','')
$systemmodel = $systemmodel + "drivers"
$systemmodel = [uri]::EscapeDataString($systemmodel)
$systemmodel = $systemmodel -replace ('%20%20%20%20%20%20%20','')
$URL = "https://www.google.com/search?q=$($systemmodel)"
start $URL
