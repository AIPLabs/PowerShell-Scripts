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

Get-ADUser -Identity {manager username} -Properties directreports |
    Select-Object -ExpandProperty directreports |
    Get-ADUser -Properties mail |
    Select-Object SamAccountName, mail | % {

        
        $ResID = Get-CMUser -Name "{domain}\$($_.SamAccountName)"
        Add-CMUserCollectionDirectMembershipRule -CollectionName '{Collection Name}' -ResourceId $ResID.ResourceID

    }

