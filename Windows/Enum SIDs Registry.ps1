$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
$ProfileList = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} | Select-Object  @{name="SID";expression={$_.PSChildName}}, @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
$LoadedHives = Get-ChildItem Registry::HKEY_USERS | Where-Object {$_.PSChildname -match $PatternSID} | Select-Object @{name="SID";expression={$_.PSChildName}}
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select-Object @{name="SID";expression={$_.InputObject}}, UserHive, Username
 
Foreach ($item in $ProfileList) {
  If ($item.SID -in $UnloadedHives.SID) {
    reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
  }
	
  If ($item.SID -in $UnloadedHives.SID) {
	  reg unload HKU\$($Item.SID) | Out-Null
  }
}
