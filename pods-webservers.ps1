# pods-webserver.ps1
# Small web server in pure PowerShell (no extra modules needed).
# Open http://localhost:8080 and click the button to list the running pods.

# ---------- SETTINGS: change these ----------
$server    = "https://18.232.114.147:6443"
$tokenFile = "./token.txt"
$port      = 8080
# --------------------------------------------

# The webpage (served at /)
$html = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>K3s running pods</title>
  <style>
    body   { font-family: Segoe UI, Arial, sans-serif; margin: 2rem; background: #f4f6f8; color: #222; }
    button { padding: .6rem 1.2rem; font-size: 1rem; border: 0; border-radius: 6px;
             background: #2563eb; color: #fff; cursor: pointer; }
    button:hover    { background: #1d4ed8; }
    button:disabled { background: #94a3b8; cursor: wait; }
    table  { border-collapse: collapse; margin-top: 1.5rem; background: #fff; }
    th, td { border: 1px solid #d0d7de; padding: .5rem .9rem; text-align: left; }
    th     { background: #e8edf2; }
    #msg   { margin-top: 1rem; }
    .error { color: #b91c1c; }
  </style>
</head>
<body>
  <h1>K3s cluster</h1>
  <button id="btn" onclick="loadPods()">Show running pods</button>
  <div id="msg"></div>
  <table id="tbl" hidden>
    <thead><tr><th>Namespace</th><th>Name</th><th>Node</th><th>Pod IP</th></tr></thead>
    <tbody id="body"></tbody>
  </table>

<script>
function esc(s) {
  return String(s ?? '').replace(/[&<>"']/g, c =>
    ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

async function loadPods() {
  const btn = document.getElementById('btn');
  const msg = document.getElementById('msg');
  const tbl = document.getElementById('tbl');
  btn.disabled = true;
  msg.className = '';
  msg.textContent = 'Loading...';
  tbl.hidden = true;
  try {
    const res  = await fetch('/pods');
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || res.statusText);
    document.getElementById('body').innerHTML = data.map(p =>
      `<tr><td>${esc(p.Namespace)}</td><td>${esc(p.Name)}</td><td>${esc(p.Node)}</td><td>${esc(p.PodIP)}</td></tr>`
    ).join('');
    tbl.hidden = false;
    msg.textContent = data.length + ' running pod(s)';
  } catch (e) {
    msg.className = 'error';
    msg.textContent = 'Error: ' + e.message;
  } finally {
    btn.disabled = false;
  }
}
</script>
</body>
</html>
'@

# Same request as your working script, wrapped in a function
function Get-RunningPods {
    $token   = (Get-Content $tokenFile -Raw).Trim()
    $headers = @{ Authorization = "Bearer $token" }

    $r = Invoke-RestMethod -Uri "$server/api/v1/pods" -Headers $headers

    $r.items |
        Where-Object { $_.status.phase -eq "Running" } |
        ForEach-Object {
            [pscustomobject]@{
                Namespace = $_.metadata.namespace
                Name      = $_.metadata.name
                Node      = $_.spec.nodeName
                PodIP     = $_.status.podIP
            }
        }
}

function Send-Response($context, [string]$body, [string]$contentType, [int]$status = 200) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    $context.Response.StatusCode      = $status
    $context.Response.ContentType     = $contentType
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.OutputStream.Close()
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running on http://localhost:$port  (Ctrl+C to stop)"

try {
    while ($listener.IsListening) {
        # Async wait so Ctrl+C still works
        $async = $listener.BeginGetContext($null, $null)
        while (-not $async.AsyncWaitHandle.WaitOne(500)) { }
        $ctx = $listener.EndGetContext($async)

        $path = $ctx.Request.Url.AbsolutePath
        Write-Host "$(Get-Date -Format T)  $($ctx.Request.HttpMethod) $path"

        try {
            if ($path -eq "/") {
                Send-Response $ctx $html "text/html; charset=utf-8"
            }
            elseif ($path -eq "/pods") {
                # @() + -InputObject makes sure 0 or 1 pods still come out as a JSON array
                $json = ConvertTo-Json -InputObject @(Get-RunningPods) -Depth 3
                Send-Response $ctx $json "application/json; charset=utf-8"
            }
            else {
                Send-Response $ctx "Not found" "text/plain" 404
            }
        }
        catch {
            $err = ConvertTo-Json -InputObject @{ error = $_.Exception.Message }
            Send-Response $ctx $err "application/json; charset=utf-8" 500
        }
    }
}
finally {
    $listener.Stop()
}