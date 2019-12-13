# This will convert an ip address to UInt32 so that it can be used to test whether current 
# IP address falls within a range/site or whatever you want to test against.

#Start IP address
$startip = "192.168.1.1"
#End IP address
$endip = "192.168.2.254"

#Start IP convert
$startip = [ipaddress]::Parse($startip).getaddressbytes()
[array]::Reverse($startip)
$startip = [bitconverter]::ToUInt32($startip,0)

#End IP convert
$endip = [ipaddress]::Parse($endip).getaddressbytes()
[array]::Reverse($endip)
$endip = [bitconverter]::ToUInt32($endip,0)

#Display the Start and End UInt32 values.
"Start: $startip"
"End: $endip"
