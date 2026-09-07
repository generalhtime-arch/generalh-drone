[CmdletBinding()]
param(
  [string]$SiteRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$imagePath = Join-Path $SiteRoot 'assets\images\og\default.jpg'
$imageUrl = 'https://drone.general-h.com/assets/images/og/default.jpg'

if (-not (Test-Path -LiteralPath $imagePath)) {
  throw "OGP画像がありません: $imagePath"
}

$ogMeta = @"
<meta property="og:image" content="$imageUrl"><meta property="og:image:width" content="1200"><meta property="og:image:height" content="630"><meta property="og:image:alt" content="ドローン教習所東京上野校">
"@

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$pages = Get-ChildItem -LiteralPath $SiteRoot -Recurse -Filter 'index.html' -File

foreach ($page in $pages) {
  $html = [System.IO.File]::ReadAllText($page.FullName)
  if ($html -match '<meta property="og:image"') {
    Write-Output "設定済み: $($page.FullName)"
    continue
  }

  if ($html -notmatch '<meta name="twitter:card"') {
    throw "OGPメタ情報の挿入位置が見つかりません: $($page.FullName)"
  }

  $html = $html.Replace('<meta name="twitter:card"', "$ogMeta<meta name=`"twitter:card`"")
  [System.IO.File]::WriteAllText($page.FullName, $html, $utf8NoBom)
  Write-Output "設定: $($page.FullName)"
}
