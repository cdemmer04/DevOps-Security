$server = "https://18.232.114.147:6443"
$bearerToken = (Get-Content "./token.txt" -Raw).Trim()
$headers = @{
    "Authorization" = "Bearer $bearerToken"
}

$r = Invoke-RestMethod -Uri "$server/api/v1/pods" -Headers $headers
$r.items |
  Where-Object { $_.status.phase -eq "Running" } |
  Select-Object @{n="Namespace";e={$_.metadata.namespace}},
                @{n="Name";e={$_.metadata.name}},
                @{n="Node";e={$_.spec.nodeName}}