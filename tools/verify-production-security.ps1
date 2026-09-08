[CmdletBinding()]
param(
  [string]$BaseUrl = "https://drone.general-h.com",
  [switch]$SkipHttpRedirectCheck
)

# Read-only security verification for the live site.
# Example: powershell -ExecutionPolicy Bypass -File .\tools\verify-production-security.ps1
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Net.Http

if ($BaseUrl -notmatch "^https://") {
  throw "BaseUrl must begin with https://."
}

$BaseUrl = $BaseUrl.TrimEnd("/")
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$client = [System.Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromSeconds(20)
$failures = New-Object System.Collections.Generic.List[string]

function Send-Request {
  param(
    [Parameter(Mandatory = $true)][string]$Method,
    [Parameter(Mandatory = $true)][string]$Url
  )

  $httpMethod = [System.Net.Http.HttpMethod]::new($Method)
  $request = [System.Net.Http.HttpRequestMessage]::new($httpMethod, $Url)
  try {
    $response = $client.SendAsync($request).GetAwaiter().GetResult()
    return $response
  } finally {
    $request.Dispose()
  }
}

function Get-HeaderValue {
  param(
    [Parameter(Mandatory = $true)]$Response,
    [Parameter(Mandatory = $true)][string]$Name
  )

  [System.Collections.Generic.IEnumerable[string]]$values = $null
  if ($Response.Headers.TryGetValues($Name, [ref]$values)) {
    return ($values -join ", ")
  }
  if ($Response.Content.Headers.TryGetValues($Name, [ref]$values)) {
    return ($values -join ", ")
  }
  return ""
}

function Assert-Status {
  param(
    [Parameter(Mandatory = $true)][string]$Label,
    [Parameter(Mandatory = $true)]$Response,
    [Parameter(Mandatory = $true)][int[]]$Expected
  )

  $status = [int]$Response.StatusCode
  $result = if ($Expected -contains $status) { "OK" } else { "NG" }
  Write-Host ("{0,-32} {1,3}  {2}" -f $Label, $status, $result)
  if ($result -eq "NG") {
    $failures.Add("$Label expected $($Expected -join ' or ') but received $status.")
  }
}

try {
  Write-Host "Target: $BaseUrl"
  Write-Host ""

  $homeResponse = Send-Request -Method "GET" -Url "$BaseUrl/"
  Assert-Status -Label "Home page" -Response $homeResponse -Expected 200

  $requiredHeaders = @{
    "Content-Security-Policy" = "frame-src 'none'"
    "X-Content-Type-Options" = "nosniff"
    "X-Frame-Options" = "DENY"
    "Referrer-Policy" = "strict-origin-when-cross-origin"
    "Cross-Origin-Opener-Policy" = "same-origin"
    "Cross-Origin-Resource-Policy" = "same-origin"
  }
  foreach ($header in $requiredHeaders.GetEnumerator()) {
    $value = Get-HeaderValue -Response $homeResponse -Name $header.Key
    $result = if ($value -like "*$($header.Value)*") { "OK" } else { "NG" }
    Write-Host ("{0,-32} {1}" -f $header.Key, $result)
    if ($result -eq "NG") {
      $failures.Add("Response header $($header.Key) is missing '$($header.Value)'.")
    }
  }
  $homeResponse.Dispose()

  $checks = @(
    @{ Label = ".git protected"; Method = "GET"; Path = "/.git/HEAD"; Expected = @(403, 404) },
    @{ Label = ".env protected"; Method = "GET"; Path = "/.env"; Expected = @(403, 404) },
    @{ Label = "Operational docs protected"; Method = "GET"; Path = "/SECURITY.md"; Expected = @(403, 404) },
    @{ Label = "Operational tools protected"; Method = "GET"; Path = "/tools/verify-production-security.ps1"; Expected = @(403, 404) },
    @{ Label = "Backup protected"; Method = "GET"; Path = "/index.coreserver-backup.html"; Expected = @(403, 404) },
    @{ Label = "Unknown URL returns 404"; Method = "GET"; Path = "/security-check-not-found/"; Expected = @(404) },
    @{ Label = "POST rejected"; Method = "POST"; Path = "/"; Expected = @(403, 405) },
    @{ Label = "TRACE rejected"; Method = "TRACE"; Path = "/"; Expected = @(403, 405) }
  )
  foreach ($check in $checks) {
    $response = Send-Request -Method $check.Method -Url "$BaseUrl$($check.Path)"
    Assert-Status -Label $check.Label -Response $response -Expected $check.Expected
    $response.Dispose()
  }

  if (-not $SkipHttpRedirectCheck) {
    $httpUrl = $BaseUrl -replace "^https://", "http://"
    $redirect = Send-Request -Method "GET" -Url "$httpUrl/"
    Assert-Status -Label "HTTP redirects to HTTPS" -Response $redirect -Expected 301, 308
    $location = Get-HeaderValue -Response $redirect -Name "Location"
    if ($location -notmatch "^https://") {
      $failures.Add("HTTP redirect target is not HTTPS: $location")
    }
    $redirect.Dispose()
  }
} finally {
  $client.Dispose()
  $handler.Dispose()
}

Write-Host ""
if ($failures.Count -gt 0) {
  Write-Host "Security verification failed:" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host "All security checks passed." -ForegroundColor Green
