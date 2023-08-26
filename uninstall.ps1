<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
Remoeves ISL AlwaysOn from a Windows machine.
Warning: This script will remove all ISL AlwaysOn related files and folders and regstry keys from the system.
See: https://help.islonline.com/20304/165996
 
.PARAMETER <Parameter_Name>
<Brief description of parameter input required. Repeat this attribute if required>
 
.INPUTS
<Inputs if any, otherwise state None>
 
.OUTPUTS
<Outputs if anything is generated>
 
.NOTES
   Version:        0.1
   Author:         Matthias Henze mahescho@gmail.com
   Creation Date:  Wednesday, August 23rd 2023, 4:11:13 pm
   File:           uninstall.ps1
 
   Copyright (c) 2023 Matthias Henze

.LICENSE
Apache License Version 2.0, January 2004 http://www.apache.org/licenses/

#>

$isl_path = "C:\Program Files (x86)\ISL Online"
$alwayson_path = "$isl_path\ISL AlwaysOn"

# check if folder exists
if (Test-Path -Path $alwayson_path ) {
    # check if uninstaller exists
    $uninstaller = Get-ChildItem -Path $alwayson_path -Filter "unins*.exe" -ErrorAction SilentlyContinue
    if ($uninstaller) {
        # run uninstaller and wait for it to finish
        Start-Process "$alwayson_path\$uninstaller" -NoNewWindow -Wait -ArgumentList "/SILENT" -PassThru
    }
}

# find service by name wildcard and delete it if exists
$service = Get-Service -Name "ISL*" -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $service -Force -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Service -Name $service -Force -Confirm:$false -ErrorAction SilentlyContinue
}

# delete remaining files and folders
Remove-Item -Recurse -Force $isl_path -Confirm:$false -ErrorAction SilentlyContinue

# cleand up registry
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\ISL Online" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\SOFTWARE\ISL Online" -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
Remove-Item -Path "HKU:\S-1-5-18\Software\ISL Online" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

