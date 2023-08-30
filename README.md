# ISLalwasyOnSctips
Scripts for managing ISL AlwaysOn

## WARNING
**The uninstall sctips removes all data and services of all connections!**

## Usage

**Create a isl.ini file**
     
Your download URL for the ISL AlwaysOn client has to be placed in a file as the setup script called "isl.ini". The content should look like this:

    $url = https://your.isl.server.com/download/ISLAlwaysOn?cmdline=%2FVERYSILENT+grant_password+%22H....... 

The easiest way to create a working URL is using my PHP script: https://github.com/mahescho/ISLalwaysOnLinkGenerator

If you don't want to or can't download ISL AlwaysOn while setup you can provide a setup binary instead by adding $islexec to "isl.ini":

    $islexec = "ISLAlwaysOn.exe"

**Run the scripts**

The scripts can be used individually or in combination. If "setupisl.ps1" detects "uninstall.ps1" in the same folder, "uninstall.ps1" gets called before setup of the new ISL client. "uninstall.ps1" also gets copied to %programdata%/isl for later use by e.g. MS Endpoint Manager where a uninstaller is mandatory. After installing ISL AlwaysOn HTTPS gets boosted as transport. See: https://help.islonline.com/19925/166628

For local execution use:

    powershell -ExecutionPolicy Unrestricted -file setupisl.ps1

For convenience there is "runps.cmd".

    runps.cnd setupisl.ps1
