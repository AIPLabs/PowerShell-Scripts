Get-ADGroup -Filter 'GroupCategory -eq "Security" -and Name -like "*cadd*" ' | Select-Object Name
