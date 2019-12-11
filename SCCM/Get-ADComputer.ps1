# Get Deployed patches script.


$SiteCode = "{Site Code}"
$ProviderMachineName = "{SCCM Server FQDN}"
  
# Customizations
$initParams = @{}
  
# Import the ConfigurationManager.psd1 module 
try {
  if((Get-Module ConfigurationManager) -eq $null) {
      Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
  }
} Catch {
    throw "SCCM not installed."
}
  
# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
  
  
  # Set the current location to be the site code.
  Set-Location "$($SiteCode):\" @initParams

  Get-CMDevice -CollectionName 'All Inactive Clients' | ForEach-Object {
    
    $cName = $_.Name
    
    try {
       Get-ADComputer $cName -Properties PasswordLastSet | Format-table Name,PasswordLastSet | Out-Null
    } 
     Catch {
        Write-Host "$cName not in AD."
     }
        
  }
