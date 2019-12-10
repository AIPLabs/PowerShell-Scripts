Get-ChildItem Cert:\LocalMachine | ForEach-Object {
    $CertStore = ($_).Name
    Write-Host "Checking $CertStore"

    Get-ChildItem Cert:\LocalMachine\$CertStore | Where-Object { $_.Thumbprint -eq '{Cert Thumbprint}'}
}