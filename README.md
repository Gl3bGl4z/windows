# Winstall Windows 10 Setup Scripts
### **Paste links in an Administrator elevated PowerShell window**
## winstall-setupscript
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-setupscript.ps1'))
```
Each option can be selected individually within the script
- Basic
  - Rename the PC and join a domain
  - Disable Start Menu Bing search and application suggestions
  - Disable subscribed ads, location tracking, and advertiser ID
  - Disable resource intensive P2P sharing
  - Disable Cortana, Ink Space and 3D Objects folder
  - Disable ALL Windows Telemetry and Online Tips/Ads
  - Disable Wi-Fi Sense (Removed in 1803)
  - Remove/Unpin all Startmenu and default Taskbar icons
  - Remove the People and Taskview icons
  - Delete all Windows Store apps (except the Calculator, Photos, and the Windows Store)
  - Install [Chocolatey](https://chocolatey.org/) and defined packages
  - Install all available [VCRedist Visual C++](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads) versions (via Chocolatey)
- Full
  - Remove OneDrive
  - Increase wallpaper to max compression quality at essentially no additional resource cost
  - Enable Show File Extension in File Explorer
  - Enable Show Hidden Files and Folders in File Explorer
  - Enable Remote Desktop Connection
  - Enable Wake On LAN
  - Download [MVPS](http://winhelp2002.mvps.org/hosts.txt) hosts file for system wide ad blocking
## winstall-sysinfo
#### Run a small Windows 10 script to display important system information
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-sysinfo.ps1'))
```
## winstall-essentialutils
#### Installs ProcessExplorer, GeekUninstaller, and BleachBit (via [Chocolatey](https://chocolatey.org/))
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-essentialutils.ps1'))
```
## winstall-benchmark
#### Run a quick and simple Windows multi-thread benchmark
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-benchmark.ps1'))
```
- Intel(R) Core(TM) i7-7700K CPU @ 4.20GHz = 1879.400024 ms
## winstall-wifiqr
#### Create a iOS camera readable Wi-Fi connect QR code using information from the currently connected Wi-Fi network
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-wifiqr.ps1'))
```
## winstall-hfsystem
#### Change hidden and system file flags
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-hfsystem.ps1'))
```
## enable-powershellcontextmenu
#### Add an "Open Windows PowerShell Here as Administrator" option to the context (right click) menu in File Explorer
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/enable-powershellcontextmenu.ps1'))
```
