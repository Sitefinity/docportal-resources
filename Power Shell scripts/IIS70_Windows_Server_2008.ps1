<#

.SYNOPSIS 

Configures the Windows Features and Internet Information Services (IIS) Features required to host Sitefinity projects on Windows Server 2008 R2.

#>

Import-Module ServerManager

$windowsRolesList = @("File-Services",
    "FS-FileServer",
    "Web-Server",
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Default-Doc",
    "Web-Dir-Browsing",
    "Web-Http-Errors",
    "Web-Static-Content",
    "Web-Health",
    "Web-Http-Logging",
    "Web-Request-Monitor",
    "Web-Performance",
    "Web-Stat-Compression",
    "Web-Security",
    "Web-Filtering",
    "Web-App-Dev",
    "Web-Net-Ext",
    "Web-Asp-Net",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Mgmt-Tools",
    "Web-Mgmt-Console",
    "Web-Scripting-Tools",
    "Web-Mgmt-Service",
    "NET-Framework",
    "NET-Framework-Core",
    "NET-HTTP-Activation",
    "NET-Non-HTTP-Activ",
    "SNMP-Service",
    "SNMP-WMI-Provider",
    "Telnet-Client",
    "PowerShell-ISE",
    "WAS",
    "WAS-Process-Model",
    "WAS-NET-Environment",
    "WAS-Config-APIs")

$windowsFeaturesList = @("MSMQ-Server",
    "Web-Static-Content",
    "Web-Default-Doc",
    "Web-Dir-Browsing",
    "Web-Http-Errors",
    "Web-Asp-Net",
    "Web-Net-Ext",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Http-Logging",
    "Web-Request-Monitor",
    "Web-Filtering",
    "Web-Stat-Compression",
    "Web-Dyn-Compression",
    "Web-Mgmt-Console",
    "Web-Scripting-Tools",
    "Web-Mgmt-Service",
    "NET-Framework-Core",
    "NET-Win-CFAC",
    "NET-HTTP-Activation",
    "NET-Non-HTTP-Activ",
    "RSAT-AD-PowerShell",
    "RSAT-Web-Server",
    "SNMP-Service",
    "SNMP-WMI-Provider",
    "Telnet-Client",
    "WAS-Process-Model",
    "WAS-NET-Environment",
    "WAS-Config-APIs",
    "Backup",
    "Backup-Tools",
    "Desktop-Experience")


Write-Host "Starting setup…" -Foregroundcolor Yellow

#Verify existence of Windows Roles.
Write-Host "Checking for existance of required Windows roles…" -Foregroundcolor Yellow
Get-WindowsFeature $windowsRolesList
Write-Host "All required roles were found and can be enabled." -Foregroundcolor Green

#Install Windows Roles.
Write-Host "Installing roles…" -Foregroundcolor Yellow
Add-WindowsFeature $windowsRolesList
Write-Host "Features installed." -Foregroundcolor Green
        
#Verify that .NET 4.0 is installed.  
$net40Path = [System.IO.Path]::Combine($env:SystemRoot, "Microsoft.NET\Framework\v4.0.30319")
Write-Host "Microsoft .NET Framework 4.0 appears to be installed." -Foregroundcolor Green     

#Verify aspnet_regiis.exe location
$aspnetRegIISFullName = [System.IO.Path]::Combine($net40Path, "aspnet_regiis.exe")
     
if (!(Test-Path $aspnetRegIISFullName))
{
    $message =  "aspnet_regiis.exe was not found in {0}. Make sure that Microsoft .NET Framework 4.0 is installed first." -f $net40Path
    Write-Error $message
}
     
#Verify existence of Windows Features.
Write-Host "Checking for existance of required Windows features…" -Foregroundcolor Yellow
Get-WindowsFeature $windowsFeaturesList
Write-Host "All required features were found and can be enabled." -Foregroundcolor Green
     	 
#Install windows features.
Write-Host "Installing features…" -Foregroundcolor Yellow
Add-WindowsFeature $windowsFeaturesList
Write-Host "Features installed." -Foregroundcolor Green
 
#Register ASP.NET 4.0 with IIS
Write-Host "Registering ASP.NET 4.0 with IIS…" -Foregroundcolor Yellow
Start-Process -FilePath $aspnetRegIISFullName  -ArgumentList "-iru"      
            
#Register Web Handlers
if(!(Get-WebHandler "xamlx-ISAPI-4.0_32bit")){
    New-WebHandler -Name "xamlx-ISAPI-4.0_32bit" -Path "*.xamlx" -Verb "GET,HEAD,POST,DEBUG" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness32" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll"
}

if(!(Get-WebHandler "xamlx-ISAPI-4.0_64bit")){
    New-WebHandler -Name "xamlx-ISAPI-4.0_64bit" -Path "*.xamlx" -Verb "GET,HEAD,POST,DEBUG" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness64" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"
}

if(!(Get-WebHandler "svc-ISAPI-4.0_32bit")){
    New-WebHandler -Name "svc-ISAPI-4.0_32bit" -Path "*.svc" -Verb "*" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness32" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll"
}

if(!(Get-WebHandler "svc-ISAPI-4.0_64bit")){
    New-WebHandler -Name "svc-ISAPI-4.0_64bit" -Path "*.svc" -Verb "*" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness64" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"
}

Write-Host "Setup complete." -Foregroundcolor Green
# SIG # Begin signature block
# MIIXkwYJKoZIhvcNAQcCoIIXhDCCF4ACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/aVnO1qxJH9Nwu6KK2pYqeoj
# EEigghK5MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggS/MIIDp6ADAgECAhAUWbKknAzZKgj5xQMVzT2KMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE2MDEyODAwMDAwMFoX
# DTE2MTIxNjIzNTk1OVowVzELMAkGA1UEBhMCQkcxDjAMBgNVBAgTBVNvZmlhMQ4w
# DAYDVQQHEwVTb2ZpYTETMBEGA1UEChQKVEVMRVJJSyBBRDETMBEGA1UEAxQKVEVM
# RVJJSyBBRDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALZXufjISN0m
# XyNP67TrDt6eIyposvPvYDsvM28ugGnMPr6KAR8iBBocd4i97eQwq4IqiNIb1nSg
# 2OPlmCgAod7mUZO71GS9kW2njwcs7i0PN8xoFnlPAiM8bmdPWlqrc3RRqtvOkRsi
# NtUoOMaIc4Zyd21G136DKxf9zWCIWJfv9z3YicbY1h5PJelS+FVcTtAqujKjPrBz
# MyODNom5Nhljdg4HdlxNuYfOvP0E6A/0eUvh5ni1idt6sZw3JVZTtv+gWoIUfS4I
# aSuCoiemzgKXR+8TlObcYW2BBhcZ8Netd6Ey1QEeXWBi9I2D7XihSIc+/cfx3eUT
# aJNMRu9c5b0CAwEAAaOCAV0wggFZMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgeA
# MCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9zdi5zeW1jYi5jb20vc3YuY3JsMGEG
# A1UdIARaMFgwVgYGZ4EMAQQBMEwwIwYIKwYBBQUHAgEWF2h0dHBzOi8vZC5zeW1j
# Yi5jb20vY3BzMCUGCCsGAQUFBwICMBkMF2h0dHBzOi8vZC5zeW1jYi5jb20vcnBh
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMFcGCCsGAQUFBwEBBEswSTAfBggrBgEFBQcw
# AYYTaHR0cDovL3N2LnN5bWNkLmNvbTAmBggrBgEFBQcwAoYaaHR0cDovL3N2LnN5
# bWNiLmNvbS9zdi5jcnQwHwYDVR0jBBgwFoAUljtT8Hkzl699g+8uK8zKt4YecmYw
# HQYDVR0OBBYEFHyLDsSFScdMklkrzSXW+JAAuOrjMA0GCSqGSIb3DQEBCwUAA4IB
# AQAHn1Y3Ot+ZXyoxm4XQTWJ0u9cadtpHfBShYvWLor42/V4Ddoaw9P5e3RQ6K8mJ
# BGBamC4vIaWe0angg7+F8oRQMt4tBGu3qqsUZbZP4mcNXQ4ytnCdcgoZK+hLF0x2
# dmzVPdtX+AAtPzp0VMpe8X7pFYKfTIJXMye9cWkCnYxiiHQlpAj9y+O1bUIcqNu1
# +hgodwGSOYN7/9qsqPBLOvZVlIntuuUq1jC3aG/afd8R3bm4E4ns8a0ueUuzUDBp
# U1JPzPG2Ia2Ogmd7D3jN3iPOnG066ADd81Ve4rv8lMyBLJ0c9O0AsR2GrYsv0PHb
# PIUAyT5HS+4HsGRsU/xbzhrKMIIFWTCCBEGgAwIBAgIQPXjX+XZJYLJhffTwHsqG
# KjANBgkqhkiG9w0BAQsFADCByjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlT
# aWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYD
# VQQLEzEoYykgMjAwNiBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVz
# ZSBvbmx5MUUwQwYDVQQDEzxWZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gRzUwHhcNMTMxMjEwMDAwMDAwWhcN
# MjMxMjA5MjM1OTU5WjB/MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMg
# Q29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxMDAu
# BgNVBAMTJ1N5bWFudGVjIENsYXNzIDMgU0hBMjU2IENvZGUgU2lnbmluZyBDQTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJeDHgAWryyx0gjE12iTUWAe
# cfbiR7TbWE0jYmq0v1obUfejDRh3aLvYNqsvIVDanvPnXydOC8KXyAlwk6naXA1O
# pA2RoLTsFM6RclQuzqPbROlSGz9BPMpK5KrA6DmrU8wh0MzPf5vmwsxYaoIV7j02
# zxzFlwckjvF7vjEtPW7ctZlCn0thlV8ccO4XfduL5WGJeMdoG68ReBqYrsRVR1PZ
# szLWoQ5GQMWXkorRU6eZW4U1V9Pqk2JhIArHMHckEU1ig7a6e2iCMe5lyt/51Y2y
# NdyMK29qclxghJzyDJRewFZSAEjM0/ilfd4v1xPkOKiE1Ua4E4bCG53qWjjdm9sC
# AwEAAaOCAYMwggF/MC8GCCsGAQUFBwEBBCMwITAfBggrBgEFBQcwAYYTaHR0cDov
# L3MyLnN5bWNiLmNvbTASBgNVHRMBAf8ECDAGAQH/AgEAMGwGA1UdIARlMGMwYQYL
# YIZIAYb4RQEHFwMwUjAmBggrBgEFBQcCARYaaHR0cDovL3d3dy5zeW1hdXRoLmNv
# bS9jcHMwKAYIKwYBBQUHAgIwHBoaaHR0cDovL3d3dy5zeW1hdXRoLmNvbS9ycGEw
# MAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL3MxLnN5bWNiLmNvbS9wY2EzLWc1LmNy
# bDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgEG
# MCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFTeW1hbnRlY1BLSS0xLTU2NzAdBgNV
# HQ4EFgQUljtT8Hkzl699g+8uK8zKt4YecmYwHwYDVR0jBBgwFoAUf9Nlp8Ld7Lvw
# MAnzQzn6Aq8zMTMwDQYJKoZIhvcNAQELBQADggEBABOFGh5pqTf3oL2kr34dYVP+
# nYxeDKZ1HngXI9397BoDVTn7cZXHZVqnjjDSRFph23Bv2iEFwi5zuknx0ZP+XcnN
# XgPgiZ4/dB7X9ziLqdbPuzUvM1ioklbRyE07guZ5hBb8KLCxR/Mdoj7uh9mmf6RW
# pT+thC4p3ny8qKqjPQQB6rqTog5QIikXTIfkOhFf1qQliZsFay+0yQFMJ3sLrBkF
# IqBgFT/ayftNTI/7cmd3/SeUx7o1DohJ/o39KK9KEr0Ns5cF3kQMFfo2KwPcwVAB
# 8aERXRTl4r0nS1S+K4ReD6bDdAUK75fDiSKxH3fzvc1D1PFMqT+1i4SvZPLQFCEx
# ggREMIIEQAIBATCBkzB/MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMg
# Q29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxMDAu
# BgNVBAMTJ1N5bWFudGVjIENsYXNzIDMgU0hBMjU2IENvZGUgU2lnbmluZyBDQQIQ
# FFmypJwM2SoI+cUDFc09ijAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUw9jOE37XN1HJnWQ2aMKI
# vRw90P0wDQYJKoZIhvcNAQEBBQAEggEABLhTwf8C06jOkG7XwLO/hV0ThUKdlBPa
# qOFSOfmpx0127KdttzXyqGZxMjY1/fcATjZEVtXiF73xYHEviEoPW4JpkaZHnId9
# tSnejneYmTulK9B8U5/ftKy3pV7YA0PMJ+BCihosRSvTBS2FhzJofoDdxf36mLjD
# 8E2ebVkEcD6hvLeTkEm2O/LG6LvOkg24W0sSu6hvzcblCqUP0iMQFi6oOPmTG2Vk
# 3Y5WopTD3mKHYB2PaFDy2FaSEfvldN9wdRIL4tIWUQUeUhQKJj0lKXwCV8r4oRgO
# LfeoSRMHrXoXW7U7qqcxaMlXFY4PF+7ThSDyTlaDGN6V5ZQUGNm7uqGCAgswggIH
# BgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBT
# dGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsO
# AwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
# Fw0xNjA4MDgxMTA0NDNaMCMGCSqGSIb3DQEJBDEWBBTfbt04XnmZFBr6mgSam0wd
# ZJDVvjANBgkqhkiG9w0BAQEFAASCAQCP7CfXz/zYD6OfsJDkEpMaOQPQgiRIEqz/
# 3uOiPkidAyK/z8HpkJju5yrp1CDNkrwsazOGGSk1MKKcg2k+Dbw2BG5Q6PK10myO
# V37FZ5rj8N3H6srPl1Ss5B+Z7LovfU50Et0cRufCBhQ3XtjIA+WPswrm/32UocrR
# /OCDZLa3H3+Z9V9Oz27qvFJlhoeCdWK3dq+ckqFp8mfYNWsEZ0sf0uLjYiw4TPaA
# wTZHzrA7aBhCDVbw0/jCagV6nVLdaFUD+oWKFdS4KW9w64C2ynA+LxLWO5KmmMmT
# spShNB3nBONpsZk/A4TpoVxiRgpWtZtpqAr51R0KOAx+WCHp/LOm
# SIG # End signature block
