$hostFile = Get-Content -Path 'C:\Windows\System32\drivers\etc\hosts'

$lineCount = $hostFile.Count

$defaultLineCount = 21




If($lineCount -eq $defaultLineCount) {

    $Compliant = $true
} else {
    
    #($hostFile | Select-String '127.0.0.1 view-localhost # view localhost server').LineNumber

    If(($hostFile | Select-Object -Index 22) -eq '127.0.0.1 view-localhost # view localhost server') {
        $Compliant = $true
    } else {
        $Compliant = $false
    }
    
    
}


$Compliant
