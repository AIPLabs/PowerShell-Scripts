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


$Schedule = New-CMSchedule -Start "12/12/2019 12:00 AM" -RecurInterval Days -RecurCount 1

$CollectionName = '{Collection Name}'

$CollectionQuery = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.NetbiosName like 'CAMA%' OR SMS_R_System.NetbiosName like 'CARL%'"

New-CMDeviceCollection -Name $CollectionName -LimitingCollectionId "{CollectionID}" -RefreshSchedule $Schedule -RefreshType Periodic | Move-CMObject -FolderPath "{Site Code}:\DeviceCollection\Office Locations\Regions"

Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $CollectionQuery -RuleName $CollectionName
