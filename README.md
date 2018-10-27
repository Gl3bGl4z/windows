# Winstall Windows 10 Setup Scripts
### **Paste links in an Administrator elevated PowerShell window**
## winstall-setupscript
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-setupscript.ps1'))
```
- Rename the PC
- Join a domain
- Remove OneDrive
- Disable Cortana and Ink Space
- Disable ALL Windows Telemetry
- Remove/Unpin all Startmenu and default Taskbar icons
- Remove the People, Taskview, and Action Center icons on the Taskbar
- Delete all Windows Store apps (except the Calculator, Photos, and the Windows Store)
- Permanently disable all Windows telemetry and ad tracking
- Increase wallpaper quality to 100% at essentially no additional resource cost
- Install [Chocolatey](https://chocolatey.org/) and defined packages
- Install all available .NET Framework versions and all VCRedist Visual C++ versions (via Chocolatey)
- Disable web and Windows Store app search in the Startmenu
## winstall-update
#### Run Windows update and install all available updates except any updates including **Bing** and **Silverlight**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-update.ps1'))
```
## winstall-benchmark
#### Run a quick and simple Windows multi-thread benchmark
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-benchmark.ps1'))
```
- Intel(R) Core(TM) i7-7700K CPU @ 4.20GHz = 1879.400024 ms
## winstall-hfsystem
#### Change hidden and system file flags
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-hfsystem.ps1'))
```
## enable-rdpwol
#### Enable both RDP and WOL depending on selection
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/enable-rdpwol.ps1'))
```
## enable-powershellcontextmenu
#### Add an "Open Windows PowerShell Here as Administrator" option to the context (right click) menu in File Explorer
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/enable-powershellcontextmenu.ps1'))
```
## geforceexp-nologin
#### Disable the forced Geforce Experience login
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/geforceexp-nologin.ps1'))
```