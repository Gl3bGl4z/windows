## winstall
### **Paste links in an Administrator elevated PowerShell window**
## winstall-setupscript
#### This script can rename the PC, join a domain, remove OneDrive, remove all Desktop, Startmenu, Taskbar icons (Including the People, Taskview, and Action Center icons on the Taskbar) delete all Windows Store apps (except the Calculator, Photos, and the Windows Store) and install Chocolatey with selected packages and install major system dependencies. (Dependencies include all .NET Framework versions and all VCRedist Visual C++ versions)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-setupscript.ps1'))
```
## winstall-update
#### This script will run Windows update and install all available updates except any updates including Bing* and Silverlight*
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-update.ps1'))
```
## winstall-hfsystem
#### This script can change hidden and system file flags
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-hfsystem.ps1'))
```
## enable-rdpwol
#### This script can enable both RDP and WOL depending on selection
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/enable-rdpwol.ps1'))
```
## enable-powershellcontextmenu
#### This script will add an "Open Windows PowerShell Here as Administrator" option to the context (right click) menu in File Explorer
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/enable-powershellcontextmenu.ps1'))
```
## geforceexp-nologin
#### This script will disable the forced Geforce Experience login
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/geforceexp-nologin.ps1'))
```