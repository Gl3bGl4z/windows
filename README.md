### **Paste links into an _Administrator_ elevated Powershell window**
# winstall-setupscript
#### This script will rename a PC, join a domain, remove OneDrive, remove all desktop, startmenu, taskbar icons, delete all Windows Store apps (except the Calculator and Photos and the Windows Store) and install Chocolatey and major system dependencies.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-setupscript.ps1'))
```
# winstall-update
#### This script will run Windows update and install all available updates except any updates including Bing* and Silverlight*
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-update.ps1'))
```
# winstall-hfsystem
#### This script can change hidden and system file flags
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-hfsystem.ps1'))
```
# winstall-enablerdpwol
#### This script will enable both RDP and WOL depending on selection
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/winstall-enablerdpwol.ps1'))
```