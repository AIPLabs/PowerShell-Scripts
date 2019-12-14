Function SendEmail {
    
    [CmdletBinding()]
    Param(
        [string]$mailBody,
        [string]$ComputerName
    )

    $toField = "{To Email}"
    $fromField = "{From Email}"
    #$ccField = "{CC Email}"
    $subjectField = "{Email Subject}"

    #Send-MailMessage -To $toField -From $fromField -Cc $ccField -Subject $subjectField -Body $mailBody -SmtpServer "{SMTP Server}"
    Send-MailMessage -To $toField -From $fromField -Subject $subjectField -Body $mailBody -SmtpServer "{SMTP Server}"
}


# Site configuration
$SiteCode = "{Site Code}"
$ProviderMachineName = "{SCCM Server FQDN}"

# Customizations
$initParams = @{}

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$emailCount = 0

$SysInfo = Get-CMDevice -CollectionName "{Collection Name}"

$SysInfo | ForEach-Object {

    $emailCount ++
    
    $ComputerName = $_.Name
    $ResID = $_.ResourceID
    
    $PrimaryUser = Get-CMUserDeviceAffinity -DeviceName $_.Name | Select-Object UniqueUserName
    
    $PrimaryUsers = $PrimaryUser.UniqueUserName

    If ($PrimaryUsers -like "*$ComputerName\local_users*") {
        $NoDomainCreds = "Please check why this system is not being logged into with domain credentials."
    }

    If (!$PrimaryUsers) {
        $PrimaryUsers= "Primary User not available."
    }

    $dbOS = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_Operating_System -Filter "ResourceID = '$ResID'"
    $dbComp = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_COMPUTER_SYSTEM -Filter "ResourceID = '$ResID'"
    $dbSysEnc = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_SYSTEM_ENCLOSURE -Filter "ResourceID = '$ResID'"
    
    $CompManufacturer = $dbComp.Manufacturer
    $CompModel = $dbComp.Model
    $LastBootTime = $dbOS.ConverttoDateTime($dbOS.lastbootuptime) 
    $SerialNum = $dbSysEnc.SerialNumber


    $emailBody = "This system has not been rebooted since $($LastBootTime), please work with the user to have this system rebooted.`r`n`r`nYou DO NOT need to update the SCCM Team once this system has been rebooted.`r`n`r`n"

    If($NoDomainCreds) {
        $emailBody += "$NoDomainCreds`r`n`r`n"
    }

    $emailBody += "Computer Name: $ComputerName`r`n"
    $emailBody += "Primary User(s): $PrimaryUsers`r`n`r`n"
    $emailBody += "Computer Manufacturer: $CompManufacturer`r`n"
    $emailBody += "Computer Model: $CompModel`r`n`r`n"
    $emailBody += "Serial Number: $SerialNum`r`n"

    Write-Host "Sending: $emailCount ($ComputerName)"

    Start-Sleep -Seconds 2

    #$emailBody
    SendEmail -ComputerName $ComputerName -mailBody $emailBody

    Clear-Variable emailBody -ErrorAction SilentlyContinue
    Clear-Variable NoDomainCreds -ErrorAction SilentlyContinue
    Clear-Variable ComputerName -ErrorAction SilentlyContinue
    Clear-Variable PrimaryUser -ErrorAction SilentlyContinue
    Clear-Variable CompManufacturer -ErrorAction SilentlyContinue
    Clear-Variable CompModel -ErrorAction SilentlyContinue
    Clear-Variable SerialNum -ErrorAction SilentlyContinue
    
}
