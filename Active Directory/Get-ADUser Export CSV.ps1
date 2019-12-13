$User = Get-Content -Path {Import File}

$employees = @()

$User | ForEach-Object {
    
    try {

        $ADInfo = Get-ADUser $_ -Properties * -ErrorAction stop | Select-Object EmployeeID, DisplayName, UserPrincipalName, telephoneNumber, mobilePhone
        
        If($ADInfo.telephoneNumber) {
            $Phone = $ADInfo.telephoneNumber
            $Cell = ""
        }else{
            $Phone = "Not Listed"
            $Cell = $ADInfo.mobilePhone
        }


        $employee = New-Object System.Object
	    $employee | Add-Member -MemberType NoteProperty -Name "Employee ID" -Value $ADInfo.EmployeeID
	    $employee | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $ADInfo.DisplayName
        $employee | Add-Member -MemberType NoteProperty -Name "Email" -Value $ADInfo.UserPrincipalName
        $employee | Add-Member -MemberType NoteProperty -Name "Work Phone" -Value $Phone
        $employee | Add-Member -MemberType NoteProperty -Name "Cell" -Value $Cell
	
    } catch {

        $employee = New-Object System.Object
	    $employee | Add-Member -MemberType NoteProperty -Name "Employee ID" -Value "Not Found"
	    $employee | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $_
        $employee | Add-Member -MemberType NoteProperty -Name "Email" -Value "Not Found"
        $employee | Add-Member -MemberType NoteProperty -Name "Work Phone" -Value "Not Found"

    }
    
        $employees += $employee
    
    

} 

$employees | Export-Csv {Export Path} -Encoding ascii -NoTypeInformation
