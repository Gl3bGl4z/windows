net stop InstallService
sc config InstallService start=disabled

#VirtuallyInclined.com 2018
#You may have to manually uninstall some Sponsored Apps from the Start Menu.
#This has been tested on Windows 10 Enterprise 1709 and 1703.

#This is the short version of this script with a variable including all the apps and a loop that runs
#Remove-AppXPackage and Remove-AppXProvisionedPackage on each app called by the variable.
#This unnecessarily runs against some apps that don't have corresponding provisioning packages
#due to the loop.

Import-Module AppX
Import-Module Dism
&nbsp;

#Use "#" to comment out apps you don't want to remove in the AppXApps variable

$AppXApps = @(

    #Unnecessary Windows 10 AppX Apps
    "*Microsoft.BingNews*"
    "*Microsoft.DesktopAppInstaller*"
    "*Microsoft.GetHelp*"
    "*Microsoft.Getstarted*"
    "*Microsoft.Messaging*"
    "*Microsoft.Microsoft3DViewer*"
    "*Microsoft.MicrosoftOfficeHub*"
    "*Microsoft.MicrosoftSolitaireCollection*"
    "*Microsoft.NetworkSpeedTest*"
    "*Microsoft.Office.OneNote*"
    "*Microsoft.Office.Sway*"
    "*Microsoft.OneConnect*"
    "*Microsoft.People*"
    "*Microsoft.Print3D*"
    "*Microsoft.RemoteDesktop*"
    "*Microsoft.SkypeApp*"
    "*Microsoft.StorePurchaseApp*"
    "*Microsoft.WindowsAlarms*"
    "*Microsoft.WindowsCamera*"
    "*microsoft.windowscommunicationsapps*"
    "*Microsoft.WindowsFeedbackHub*"
    "*Microsoft.WindowsMaps*"
    "*Microsoft.WindowsSoundRecorder*"
    "*Microsoft.Xbox.TCUI*"
    "*Microsoft.XboxApp*"
    "*Microsoft.XboxGameOverlay*"
    "*Microsoft.XboxIdentityProvider*"
    "*Microsoft.XboxSpeechToTextOverlay*"
    "*Microsoft.ZuneMusic*"
    "*Microsoft.ZuneVideo*"

    #Sponsored Windows 10 AppX Apps
    #Add sponsored/featured apps to remove in the "*AppName*" format
    "*EclipseManager*"
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Duolingo-LearnLanguagesforFree*"
    "*PandoraMediaInc*"
    "*CandyCrush*"
    "*Wunderlist*"
    "*Flipboard*"
    "*Twitter*"
    "*Facebook*"
    "*Spotify*"
    
    "*Microsoft*"
    "*Office*"

    #Optional: Typically not removed but you can if you need to for some reason
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
    #"*Microsoft.BingWeather*"
    #"*Microsoft.MSPaint*"
    #"*Microsoft.MicrosoftStickyNotes*"
    #"*Microsoft.Windows.Photos*"
    #"*Microsoft.WindowsCalculator*"
    #"*Microsoft.WindowsStore*"
    )
foreach ($App in $AppXApps) {
    Get-AppxPackage -Name $App | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online
    }