$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\ctx_onboarding.txt'
$lines = New-Object System.Collections.Generic.List[string]

foreach ($anchor in @('dM={0:{title:', 'W9e=[{title:')) {
    $i = $t.IndexOf($anchor, [System.StringComparison]::Ordinal)
    if ($i -lt 0) { $lines.Add("NOT FOUND: $anchor"); continue }
    $e = [Math]::Min($t.Length, $i + 3000)
    $lines.Add('======== ' + $anchor + ' ========')
    $lines.Add($t.Substring($i, $e - $i))
    $lines.Add('')
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output "written $out"
