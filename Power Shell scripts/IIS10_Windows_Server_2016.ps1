$ErrorActionPreference  = "Stop";
        
write-host "Starting setup…" -foregroundcolor yellow;
        
#First check if .NET 4.0 is installed
     
$net40Path = [System.IO.Path]::Combine($env:SystemRoot, "Microsoft.NET\Framework\v4.0.30319");
$aspnetRegIISFullName = [System.IO.Path]::Combine($net40Path, "aspnet_regiis.exe");
     
if ((test-path $aspnetRegIISFullName) -eq $false)
{
    $message =  "aspnet_regiis.exe was not found in {0}. Make sure that Microsoft .NET Framework 4.0 is installed first." -f $net40Path;
    write-error $message;
}
     
write-host "Microsoft .NET Framework 4.0 appears to be installed." -foregroundcolor green;
     
import-module ServerManager
     
#Check for existence of required Windows features
$features = @("MSMQ-Server", "Web-Static-Content", "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Http-Logging", "Web-Request-Monitor", "Web-Filtering", "Web-Stat-Compression", "Web-Dyn-Compression", "Web-Mgmt-Console", "Web-Scripting-Tools", "Web-Mgmt-Service", "RSAT-AD-PowerShell", "SNMP-Service", "SNMP-WMI-Provider", "Telnet-Client", "WAS-Process-Model", "WAS-Config-APIs", "Web-Http-Redirect", "Web-Basic-Auth", "Web-Windows-Auth", "Web-Net-Ext45", "Web-Asp-Net45", "Web-CGI", "Web-Includes", "Web-WMI", "Web-Lgcy-Scripting", "Web-Lgcy-Mgmt-Console", "Web-Metabase", "Web-Mgmt-Compat", "Web-WHC", "Windows-Identity-Foundation")
        
write-host "Checking for existance of required Windows features…" -foregroundcolor yellow
get-windowsfeature $features
write-host "All required features were found and can be enabled." -foregroundcolor green
     
	 
#Install features
     
write-host "Installing features…" -foregroundcolor yellow;
foreach($feature in $features)
{
    write-host "Installing feature: $feature"
    add-windowsfeature $feature
}

write-host "Features installed." -foregroundcolor green;
     
#Register ASP.NET 4.0 with IIS
     
write-host "Registering ASP.NET 4.0 with IIS…" -foregroundcolor yellow;
start-process -filepath $aspnetRegIISFullName  -argumentlist "-iru";
            
#Register web handlers in IIS
     
write-host "Registering web handlers" -foregroundcolor yellow;
        
if(!(Get-WebHandler "xamlx-Integrated-4.0")){
    New-WebHandler -Name "xamlx-Integrated-4.0" -Path "*.xamlx" -Verb "GET,HEAD,POST,DEBUG" -RequiredAccess "Script" -Modules "ManagedPipelineHandler" -Precondition "integratedMode" -Type "System.Xaml.Hosting.XamlHttpHandlerFactory, System.Xaml.Hosting, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
}

if(!(Get-WebHandler "xamlx-ISAPI-4.0_32bit")){
    New-WebHandler -Name "xamlx-ISAPI-4.0_32bit" -Path "*.xamlx" -Verb "GET,HEAD,POST,DEBUG" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness32" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll"
}

if(!(Get-WebHandler "xamlx-ISAPI-4.0_64bit")){
    New-WebHandler -Name "xamlx-ISAPI-4.0_64bit" -Path "*.xamlx" -Verb "GET,HEAD,POST,DEBUG" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness64" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"
}

if(!(Get-WebHandler "svc-Integrated-4.0")){
    New-WebHandler -Name "svc-Integrated-4.0" -Path "*.svc" -Verb "*" -RequiredAccess "Script" -Modules "ManagedPipelineHandler" -Precondition "integratedMode" -Type "System.ServiceModel.Activation.ServiceHttpHandlerFactory, System.ServiceModel.Activation, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
}

if(!(Get-WebHandler "svc-ISAPI-4.0_32bit")){
    New-WebHandler -Name "svc-ISAPI-4.0_32bit" -Path "*.svc" -Verb "*" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness32" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll"
}

if(!(Get-WebHandler "svc-ISAPI-4.0_64bit")){
    New-WebHandler -Name "svc-ISAPI-4.0_64bit" -Path "*.svc" -Verb "*" -RequiredAccess "Script" -Modules "IsapiModule" -Precondition "classicMode,runtimeVersionv4.0,bitness64" -ScriptProcessor "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll"
}

write-host "Setup complete." -foregroundcolor green;
# SIG # Begin signature block
# MIIXnAYJKoZIhvcNAQcCoIIXjTCCF4kCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6CE+w2B0/YpjYDKbIc6/wd0f
# w5agghK8MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# ggTUMIIDvKADAgECAhB5ded51rMwoW/To4csnLVUMA0GCSqGSIb3DQEBCwUAMIGE
# MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAd
# BgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxNTAzBgNVBAMTLFN5bWFudGVj
# IENsYXNzIDMgU0hBMjU2IENvZGUgU2lnbmluZyBDQSAtIEcyMB4XDTE4MDUwMzAw
# MDAwMFoXDTE4MTIyMjIzNTk1OVowZjELMAkGA1UEBhMCQkcxDjAMBgNVBAgMBVNv
# ZmlhMQ4wDAYDVQQHDAVTb2ZpYTEUMBIGA1UECgwLVEVMRVJJSyBFQUQxCzAJBgNV
# BAsMAklUMRQwEgYDVQQDDAtURUxFUklLIEVBRDCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAOWW+Tp+4PgZN9CyAjElsN0psKK+dLDO0FqELfgwXcIE1axv
# WgtCLSQ/1rN8WIxC8Tfu3fFNcqccOsNjP22pKgBsVF1iwzQjIQ895376gZSjvlLo
# UMV3WTV8xcvwPP7VFPmMJ8xYd5LjcKXHqaXSNM4yqSUSRjJ9PJD3QJoReOr+AGXM
# n7xKJNXVvcRJ05hqnTSZ1qZCYoS/0t3PfWXyOJ8S2u1DnGr8dvcEU/uFYpe/k/YV
# HnPQZ6JwO8GtB8pTJLTNRL/aN/QYHVhfXT5CMX/8q2+QdAXaj7mYNpfr3r+pIVTF
# UI/8mmGIXBIicNYHADVvaFT7N93W4TWmNBXHHVECAwEAAaOCAV0wggFZMAkGA1Ud
# EwQCMAAwDgYDVR0PAQH/BAQDAgeAMCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9y
# Yi5zeW1jYi5jb20vcmIuY3JsMGEGA1UdIARaMFgwVgYGZ4EMAQQBMEwwIwYIKwYB
# BQUHAgEWF2h0dHBzOi8vZC5zeW1jYi5jb20vY3BzMCUGCCsGAQUFBwICMBkMF2h0
# dHBzOi8vZC5zeW1jYi5jb20vcnBhMBMGA1UdJQQMMAoGCCsGAQUFBwMDMFcGCCsG
# AQUFBwEBBEswSTAfBggrBgEFBQcwAYYTaHR0cDovL3JiLnN5bWNkLmNvbTAmBggr
# BgEFBQcwAoYaaHR0cDovL3JiLnN5bWNiLmNvbS9yYi5jcnQwHwYDVR0jBBgwFoAU
# 1MAGIknrOUvdk+JcobhHdglyA1gwHQYDVR0OBBYEFKjafrVTZQvLodzhkK2E2QF/
# G94SMA0GCSqGSIb3DQEBCwUAA4IBAQAVjO76Huz5G/CPBMbLrnnZz+BmT+Ht9NO+
# lqlcJkKDsp01L8bAcPyXXGXRlHv1FFVrRttxB82YqKXFad/lgPosyNDRkBu8pyP6
# uRqBHnSMZYM/gUJ1Z/ac+I83cgwIHxqlLauydqslevXjl96a0yOTyAnFNH1iKFtW
# RcFMQKZKcFgiGx6oul9mAnFfzUhJkn36GQqSmUBwZ+CwAUJrxj08P0cHNnfZdHE+
# JKXlk2VgqR6l1x4//aLo557b0K1lBc6PtjvQ5AmRVUu9TsQiCLMi/8FHckLbhY8h
# XFMEgd1zJpgW6n9SiVY641qqIIFTsZg4k+CTDL5akMEMeOmpsxNvMIIFRzCCBC+g
# AwIBAgIQfBs1NUrn23TnQV8RacprqDANBgkqhkiG9w0BAQsFADCBvTELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2ln
# biBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwOCBWZXJpU2lnbiwgSW5j
# LiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MTgwNgYDVQQDEy9WZXJpU2lnbiBV
# bml2ZXJzYWwgUm9vdCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNDA3MjIw
# MDAwMDBaFw0yNDA3MjEyMzU5NTlaMIGEMQswCQYDVQQGEwJVUzEdMBsGA1UEChMU
# U3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5l
# dHdvcmsxNTAzBgNVBAMTLFN5bWFudGVjIENsYXNzIDMgU0hBMjU2IENvZGUgU2ln
# bmluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA15VD
# 1NzfZ645+1KktiYxBHDpt45bKro3aTWVj7vAMOeG2HO73+vRdj+KVo7rLUvwVxhO
# sY2lM9MLdSPVankn3aPT9w6HZbXerRzx9TW0IlGvIqHBXUuQf8BZTqudeakC1x5J
# sTtNh/7CeKu/71KunK8I2TnlmlE+aV8wEE5xY2xY4fAgMxsPdL5byxLh24zEgJRy
# u/ZFmp7BJQv7oxye2KYJcHHswEdMj33D3hnOPu4Eco4X0//wsgUyGUzTsByf/qV4
# IEJwQbAmjG8AyDoAEUF6QbCnipEEoJl49He082Aq5mxQBLcUYP8NUfSoi4T+Idpc
# Xn31KXlPsER0b21y/wIDAQABo4IBeDCCAXQwLgYIKwYBBQUHAQEEIjAgMB4GCCsG
# AQUFBzABhhJodHRwOi8vcy5zeW1jZC5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBm
# BgNVHSAEXzBdMFsGC2CGSAGG+EUBBxcDMEwwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# ZC5zeW1jYi5jb20vY3BzMCUGCCsGAQUFBwICMBkaF2h0dHBzOi8vZC5zeW1jYi5j
# b20vcnBhMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9zLnN5bWNiLmNvbS91bml2
# ZXJzYWwtcm9vdC5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQD
# AgEGMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFTeW1hbnRlY1BLSS0xLTcyNDAd
# BgNVHQ4EFgQU1MAGIknrOUvdk+JcobhHdglyA1gwHwYDVR0jBBgwFoAUtnf6aUhH
# n1MS1cLqBzJ2B9GXBxkwDQYJKoZIhvcNAQELBQADggEBAH/ryqfqi3ZC6z6OIFQw
# 47e53PpIPhbHD0WVEM0nhqNm8wLtcfiqwlWXkXCD+VJ+Umk8yfHglEaAGLuh1KRW
# pvMdAJHVhvNIh+DLxDRoIF60y/kF7ZyvcFMnueg+flGgaXGL3FHtgDolMp9Er25D
# KNMhdbuX2IuLjP6pBEYEhfcVnEsRjcQsF/7Vbn+a4laS8ZazrS359N/aiZnOsjhE
# wPdHe8olufoqaDObUHLeqJ/UzSwLNL2LMHhA4I2OJxuQbxq+CBWBXesv4lHnUR7J
# eCnnHmW/OO8BSgEJJA4WxBR5wUE3NNA9kVKUneFo7wjw4mmcZ26QCxqTcdQmAsPA
# WiMxggRKMIIERgIBATCBmTCBhDELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFu
# dGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3Jr
# MTUwMwYDVQQDEyxTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2RlIFNpZ25pbmcg
# Q0EgLSBHMgIQeXXnedazMKFv06OHLJy1VDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUaEvG5CjG
# VMKh629QNprfMY7q7jgwDQYJKoZIhvcNAQEBBQAEggEAOfrUJG7Btl5QWlkT23UI
# Wu4OrH6QQsAJom9b7Tg76Emzqn5j1exEZE8RYotZQq/xdnVk53QfLIT/JxhAlfEo
# eoxZhgGsF7NDTQTq6DZ79HU8Nca8zR9DuirRYmco1u5vz+oOa8xU1NXUvx005EDH
# ZhwIsfi82fLrL8vPUjDrUuyGGTgq+2AwJLFtK3IzMNFF1r2BdUjt3hvtSFUsjOfy
# Bp7ubVLsrJQvmcKYHF+M0IufBUIWkJA95DbinhQ4jxiDjfY8kGbhjsfNmVipHogw
# 0Hdm44FANdKTQWUBK79GoF4AACE/Nex6cwu2LZqn1HiKvmCUcGh6yJbZ82hxOr5n
# 7aGCAgswggIHBgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVT
# MR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50
# ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqY
# GxpQMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
# SIb3DQEJBTEPFw0xODA2MjYxMDUzMjRaMCMGCSqGSIb3DQEJBDEWBBSReLGufSt2
# Zr36Xi1YqGCEsiwdxjANBgkqhkiG9w0BAQEFAASCAQA4RiIFNRJCQBNgSliePA5S
# 2ZQusYFaGar3g5JNbhrqeGVvhB51i5Rvkh0fha+1X74GIzGhvpLvGGkqv3smv3E4
# DkchPDsP13/LAPKNpGqZFJBYfSLPz1JnfUoL2k7zqDMoEUh46k4evU7JnA30hCkV
# 4KxwmOXhkkWLLz/Zq6tJKVOHTUdLYWMjkaad2TC4O3zA/Jyts7PMzXReQs/ZrcQ0
# tcp3dFFP0FgRu56zHSHBuljRyRvsmeJjaj5KBVLFXHqDIgxsnrWjYc8BOhNdy5et
# UOdfQjX/h3C/jMfdW1BAs0oR26sQlLhct1C7x/qrzfwzUDOe2c9gCvvkuUcphj51
# SIG # End signature block
