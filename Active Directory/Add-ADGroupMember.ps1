$ComputerName = Get-Content {path}

$ComputerName | ForEach-Object {
    $Name = $_
    # For MEMBERS, using $ after the name indicates that its a computer object.
    Add-ADGroupMember -Identity {Group Name} -Members "$Name$" -Server {DC Server} -Verbose
}
