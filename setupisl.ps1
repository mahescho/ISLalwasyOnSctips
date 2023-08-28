<#
#### requires ps-version 3.0 ####

.SYNOPSIS
Installs ISL AlwaysOn on a Windows machine and configures it to use https.
If an uninstall.ps1 script is found in the same directory as this script, it will be executed before installing the new version.

.NOTES
   Version:        0.1
   Author:         Matthias Henze mahescho@gmail.com
   Creation Date:  Wednesday, August 23rd 2023, 4:11:13 pm
   File:           setupisl.ps1
   
   Copyright (c) 2023 Matthias Henze

.LICENSE
Apache License Version 2.0, January 2004 http://www.apache.org/licenses/

#>

function Get-IniFile {

    param(
        [parameter(Mandatory = $true)] [string] $filePath
    )

    $ini = @{}
    switch -regex -file ($filePath) {
        "^(.+?)\s*=\s*(.*)$" {
            # Key
            $name, $value = $matches[1..2]
            $name = $name.Trim()
            $value = $value.Trim()
            $ini[$name] = $value
            continue
        }
    }

    return $ini
}

# setup logging

$tpath = $(Join-Path -Path $env:ProgramData -ChildPath "isl")

if (!(Test-Path -Path $tpath -ErrorAction SilentlyContinue)) {
    New-Item -Path $tpath -ItemType Directory -Force | Out-Null
}
$lfile = $(Join-Path -Path $env:ProgramData -ChildPath "isl\setup.log")
Start-Transcript $lfile -Force

# read ini file

$ini = $(Join-Path -Path $PSScriptRoot -ChildPath "isl.ini")
if (Test-Path -Path $ini -ErrorAction SilentlyContinue) {
    $ini = Get-IniFile $ini
    if ($ini.ContainsKey("downloadURL")) {
        $downloadURL = $ini["downloadURL"]
    }
    if ($ini.ContainsKey("islexec")) {
        $islexec = $ini["islexec"]
    }
}

if ($downloadURL) {
    # get current installer
    $islexec = "$tpath\isl.exe"
    Invoke-WebRequest  $downloadURL -outfile $islexec
}

if ($islexec) {

    $uninstall = $(Join-Path -Path $PSScriptRoot -ChildPath "uninstall.ps1")

    # if uninstall script exists, execute it to uninstall old version
    if (Test-Path -Path $uninstall -ErrorAction SilentlyContinue) {
        & $uninstall
        # copy uninstall script for later use by device management system like endpoint manager
        Copy-Item "uninstall.ps1" "$tpath\uninstall.ps1"
    }

    # execute installer
    start-process $islexec -ArgumentList "/SILENT" -Wait -NoNewWindow

    # cleanup
    Remove-Item $islexec -Force -Confirm:$false

    # boost https
    New-Item -Path "HKLM:\SOFTWARE\WOW6432Node\ISL Online\AutoTransport\Connect options" -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\ISL Online\AutoTransport\Connect options" -Name "boost" -Value "wininet-https" -PropertyType STRING -Force -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\ISL Online\AutoTransport\Connect options" -Name "https" -Value "1" -PropertyType STRING -Force -ErrorAction SilentlyContinue
}

Stop-Transcript