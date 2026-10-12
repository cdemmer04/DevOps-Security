$url = "http://localhost:8080/"
$server = "https://18.232.114.147:6443"
$tokenPath = "./token.txt"

if (-not (Test-Path $tokenPath)) {
    Write-Host "Waarschuwing: $tokenPath niet gevonden in de huidige map!" -ForegroundColor Yellow
}

$bearerToken = (Get-Content $tokenPath -Raw).Trim()
$headers = @{
    "Authorization" = "Bearer $bearerToken"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Webserver draait op $url" -ForegroundColor Green
Write-Host "Open je browser en ga naar http://localhost:8080"

# SSL-validatie bypass voor .NET Framework
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $response = $context.Response

    try {
        $r = Invoke-RestMethod -Uri "$server/api/v1/pods" -Headers $headers
        
        $runningPods = $r.items |
            Where-Object { $_.status.phase -eq "Running" } |
            Select-Object @{n="Namespace";e={$_.metadata.namespace}},
                          @{n="Name";e={$_.metadata.name}},
                          @{n="Node";e={$_.spec.nodeName}}
        
        if ($runningPods) {
            $podText = ($runningPods | ForEach-Object { "[$($_.Namespace)] $($_.Name) (Node: $($_.Node))" }) -join "`n"
        } else {
            $podText = "Geen actieve pods gevonden."
        }
    }
    catch {
        $podText = "Fout bij ophalen: $($_.Exception.Message)"
    }

    $html = @"
<!DOCTYPE html>
<html style="height: 100vh;">
<body style="margin: 0; height: 100vh; display: flex; flex-direction: column; justify-content: center; align-items: center; font-family: sans-serif; background-color: #f9f9f9;">
    
    <h2>K3s Running Pods</h2>
    <pre style="margin-top: 10px; max-width: 700px; max-height: 400px; overflow-y: auto; background: #fff; padding: 15px; border: 1px solid #ddd; border-radius: 4px; text-align: left;">$podText</pre>
    
    <p><a href="/" style="color: #007bff; text-decoration: none;">Pagina verversen</a></p>
</body>
</html>
"@

    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentType = "text/html"
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.OutputStream.Close()
}