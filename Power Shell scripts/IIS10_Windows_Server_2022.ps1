$ErrorActionPreference  = "Stop"  
     
Import-Module ServerManager

$features = @(
    "Web-Server",
    "Web-WebServer",
    "Web-Mgmt-Console",
    "Web-Static-Content",
    "Web-Asp-Net45",
    "Web-Net-Ext45",
    "Web-Health",
    "Web-Http-Logging",
    "Web-Performance",
    "Web-Stat-Compression"
)

Write-Host "Installing features..." -ForegroundColor Yellow

Add-WindowsFeature $features

Write-Host "Features installed." -ForegroundColor Green