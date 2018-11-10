# Winstall Windows 10 Setup Scripts
### **Paste links in an Administrator elevated PowerShell window**
## winstall-setupscript
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-setupscript.ps1'))
```
Basic
- Rename the PC
- Join a domain
- Disable Start Menu web search and app search
- Disable Cortana and Ink Space
- Disable ALL Windows Telemetry
- Remove/Unpin all Startmenu and default Taskbar icons
- Remove the People and Taskview icons on the Taskbar
- Delete all Windows Store apps (except the Calculator, Photos, and the Windows Store)
- Permanently disable all Windows ad tracking
- Install [Chocolatey](https://chocolatey.org/) and defined packages
- Install all available .NET Framework versions and all VCRedist Visual C++ versions (via Chocolatey)

Advanced
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
#### Create a iOS camera readable Wifi connect QR code using information from the currently connected Wifi network
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-wifiqr.ps1'))
```
## winstall-update - BETA
#### Run Windows update and install all available updates except any updates including **Bing** and **Silverlight**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-update.ps1'))
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
