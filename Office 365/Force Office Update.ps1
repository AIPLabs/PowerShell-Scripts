<#

.SYNOPSIS
Script to force Office 365 updates, change channels or enable verbose logging

.DESCRIPTION
Script to force Office 365 updates, change channels or enable verbose logging

.EXAMPLE
./<Script>.ps1 
./<Script>.ps1 -Channel Current
./<Script>.ps1 -UpdatePrompt $False -ForceAppShutDown $True
./<Script>.ps1 -UpdatePrompt $False -ForceAppShutDown $True -VerboseLogging $True

.NOTES
channel [Deferred|FirstReleaseDeferred|Current|FirstReleaseCurrent]
updatepromptuser [True|False] - This specifies whether or not the user will see this dialog before automatically applying the updates.
forceappshutdown [True|False] - This specifies whether the user will be given the option to cancel out of the update. However, if this variable is set to True, then the applications will be shut down immediately and the update will proceed.
displaylevel [True|False] - This specifies whether the user will see a user interface during the update. Setting this to false will hide all update UI (including error UI that is encountered during the update).

#>

Param(
    [Parameter()]
    [ValidateSet("Deferred","FirstReleaseDeferred","Current","FirstReleaseCurrent")]
    [String]$Channel = "Deferred",
    #[ValidateSet($True,$False)]
    [Bool]$UpdatePrompt = $True,
    [ValidateSet($True,$False)]
    [Bool]$ForceAppShutDown = $False,
    [ValidateSet($True,$False)]
    [Bool]$DisplayLevel = $True,
    [ValidateSet($True,$False)]
    [Bool]$VerboseLogging = $False
)

$RegPath = "HKLM:\SOFTWARE\Microsoft\ClickToRun\OverRide" 

If($VerboseLogging) {
    New-Item -Path $RegPath -Force
    New-ItemProperty -Path $RegPath -Name "LogLevel" -Value 3 -Type dword -Force
    New-ItemProperty -Path $RegPath -Name "PipelineLogging" -Value 1 -Type dword -Force
} else {
    Remove-Item -Path $RegPath -Force -ErrorAction SilentlyContinue
}

If($Channel -ne "Deferred") {
    Start-Process -FilePath "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/changesetting Channel=$Channel"
    Start-Process -FilePath "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user updatepromptuser=$UpdatePrompt forceappshutdown=$ForAppShutDown displaylevel=$DisplayLevel"
} else {
    Start-Process -FilePath "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user updatepromptuser=$UpdatePrompt forceappshutdown=$ForAppShutDown displaylevel=$DisplayLevel"
}



