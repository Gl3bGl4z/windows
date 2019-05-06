# Windows 7, 8, 10 and Windows Server PowerShell Scripts
### **Paste links into PowerShell**
## powershell-setupScript
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-setupScript.ps1'))
```
Each option can be selected individually within the script
- Basic
  - Rename the PC and join a domain
  - Disable Start Menu Bing search and application suggestions
  - Disable subscribed ads, location tracking, and advertiser ID
  - Disable resource intensive P2P update sharing
  - Disable Cortana, Ink Space and 3D Objects folder
  - Disable ALL Windows Telemetry and Online Tips/Ads
  - Disable Wi-Fi Sense (Removed in 1803)
  - Remove/Unpin all Startmenu icons
  - Remove the People and Taskview icons
  - Delete all Windows Store apps (except the Calculator, Photos, StickyNotes, and the Windows Store)
  - Install [Chocolatey](https://chocolatey.org/) and defined packages
  - Install all available [VCRedist Visual C++](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads) versions (via Chocolatey)
- Advanced
  - Remove OneDrive
  - Increase wallpaper to max compression quality at no additional resource cost
  - Enable Show File Extension in File Explorer
  - Enable Show Hidden Files and Folders in File Explorer
  - Enable Remote Desktop Connection
  - Enable Wake On LAN
  - Download [MVPS](http://winhelp2002.mvps.org/hosts.txt) hosts file for system wide ad blocking
## powershell-hOVPN
#### Private OVPN
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-hOVPN.ps1'))
```
## powershell-essentialUtils
#### Installs GeekUninstaller and BleachBit (via [Chocolatey](https://chocolatey.org/))
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-essentialUtils.ps1'))
```
## powershell-driverSearch
#### Google search with system model for drivers
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-driverSearch.ps1'))
```
## powershell-belarcAudit
#### Run a Windows PC Audit using BelarcAdvisor
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-belarcAudit.ps1'))
```
## powershell-adBatchAdd
#### Batch add Active Directory users into a new Organizational Unit named Employees and create private home directories from a text file formatted like
```
John Snow
Elon Musk
Jason Bourne
```
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-adBatchAdd.ps1'))
```
## powershell-mbCustom
#### MalwareBytes custom install
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-mbCustom.ps1'))
```
## powershell-wifiQr
#### Create a iOS camera readable Wi-Fi connect QR code using information from the currently connected Wi-Fi network
```
netsh wlan show profile * key=clear
```
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/powershell-wifiQr.ps1'))
```