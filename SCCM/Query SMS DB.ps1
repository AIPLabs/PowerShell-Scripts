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

$ResultObject = New-Object System.Collections.Generic.List[object]


$ComputerName = Get-Content "{File path}"
$i = 0
$ComputerName | ForEach-Object {

    $i ++
    "Record: $i $_"

    $ComputerInfo = Get-CMDevice -Name $_ | Select-Object ResourceID, DeviceOS, Name, UserName
    
    $ResID = $ComputerInfo.ResourceID

    Switch -Wildcard ($ComputerInfo.DeviceOS) {
        "Microsoft Windows NT Workstation 10*" {
            $OS = "Windows 10"
        }
        "Microsoft Windows NT Workstation 6.1" {
            $OS = "Windows 7"
        }
    }

    $dbModel = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_COMPUTER_SYSTEM -Filter "ResourceID = '$ResID'" | Select-Object Model

    $dbFirmware = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_Firmware -Filter "ResourceID = '$ResID'"
    
    Switch($dbFirmware.UEFI) {
        0 {$UEFI= "Disabled"}
        1 {$UEFI= "Enabled"}
    }
        
    Switch($dbFirmware.SecureBoot) {
        0 {$SecureBoot= "Disabled"}
        1 {$SecureBoot= "Enabled"}
    }

    $dbTPM = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_TPM -Filter "ResourceID = '$ResID'" | Select-Object -ExpandProperty SpecVersion

    $dbEncryption = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_ENCRYPTABLE_VOLUME -Filter "ResourceID = '$ResID' and DriveLetter = 'C:'" | Select-Object ProtectionStatus

    Switch($dbEncryption.ProtectionStatus) {
        0 {$Encrypted = "False"}
        1 {$Encrypted = "True"}
    }

    $newobj = [PSCustomObject]@{
                'ResourceID' = $ResID
                'ComputerName' = $_
                'Computer OS' = $OS
                'Computer Model' = $dbModel.Model
                'Primary User' = $ComputerInfo.UserName
                'UEFI' = $UEFI
                'Secure Boot' = $SecureBoot
                'TPM Version' = $dbTPM
                'Encrypted' = $Encrypted
                
        }
    
        $ResultObject.Add($newobj)

}

$ResultObject  | Out-GridView

#$UserInfo | ForEach-Object {

#     Get-CMUserDeviceAffinity -UserName $_.SMSID | Select-Object ResourceID, ResourceName, UniqueUserName | ForEach-Object {
        
#         $ResID = $_.ResourceID
        
#         $DeviceOS = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_Operating_System -Filter "ResourceID = $ResID" | Select-Object Caption

#         If($DeviceOS.Caption -like "Microsoft Windows 10*") 
#         {

#             #"Computer Name: $($_.ResourceName)" 
#             #"Computer OS: $($DeviceOS.Caption)"
            
#             $dbComp = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_COMPUTER_SYSTEM -Filter "ResourceID = '$ResID'" | Select Model

#             #"Computer Model: $($dbComp.Model)"
#             #"Primary User: $($_.UniqueUserName)"

#             $dbFirmware = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_Firmware -Filter "ResourceID = '$ResID'"

#             Switch($dbFirmware.UEFI)
#             {
#                 0 {$UEFI= "Disabled"}
#                 1 {$UEFI= "Enabled"}
#             }
    
#             Switch($dbFirmware.SecureBoot)
#             {
#                 0 {$SecureBoot= "Disabled"}
#                 1 {$SecureBoot= "Enabled"}
#             }

#             $dbTPM = Get-WmiObject -ComputerName $ProviderMachineName -Namespace "root\SMS\Site_$SiteCode" -Class SMS_G_System_TPM -Filter "ResourceID = '$ResID'" | Select-Object -ExpandProperty SpecVersion
#             #"TPM Version: $dbTPM"
#             $newobj = [PSCustomObject]@{
#                 'ComputerName' = $_.ResourceName
#                 'Computer OS' = $DeviceOS.Caption
#                 'Computer Model' = $dbComp.Model
#                 'Primary User' = $_.UniqueUserName
#                 'UEFI' = $UEFI
#                 'Secure Boot' = $SecureBoot
#                 'TPM Version' = $dbTPM
#             }
#             $ResultObject.Add($newobj)
#         } 
        
#     }
    
# } 
# $ResultObject  | Out-GridView
