# Creates a Desktop shortcut that opens the Whistling Archive Workbench
# in its own window (Edge/Chrome "app mode"). No install, nothing copied:
# the shortcut simply points at the index.html sitting next to this script.
$ErrorActionPreference = 'Stop'
$dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $dir
$html = Join-Path $root 'index.html'
if (!(Test-Path $html)) { Write-Host '  Could not find index.html next to the installer.'; exit 1 }
$uri = ([uri]$html).AbsoluteUri

$browsers = @(
  "$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$Env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
$browser = $browsers | Where-Object { Test-Path $_ } | Select-Object -First 1

$desktop = [Environment]::GetFolderPath('Desktop')
$ws = New-Object -ComObject WScript.Shell
$s  = $ws.CreateShortcut((Join-Path $desktop 'Whistling Archive.lnk'))
if ($browser) { $s.TargetPath = $browser; $s.Arguments = '--app="' + $uri + '"' }
else          { $s.TargetPath = $html }    # no Edge/Chrome: open in the default browser
$s.WorkingDirectory = $root
$icon = Join-Path $root 'WhistlingArchive.ico'
if (Test-Path $icon) { $s.IconLocation = "$icon,0" }
$s.Description = 'Whistling Archive Workbench'
$s.Save()

Write-Host ''
Write-Host '  Done - "Whistling Archive" is now on your Desktop.'
if ($browser) { Write-Host '  Double-click it: the Workbench opens in its own window, like an app.' }
else { Write-Host '  (Edge/Chrome not found, so it will open in your usual browser instead.)' }
