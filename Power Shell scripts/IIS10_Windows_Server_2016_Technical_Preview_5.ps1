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
