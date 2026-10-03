$ErrorActionPreference = 'Stop'
$file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$out  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\scan4_out.txt'
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$cands = Get-Content 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\scan3_out.txt' -Encoding UTF8 |
    Where-Object { $_ -match '^\s*(ok|RISKY)\s*\|' } |
    ForEach-Object { ($_ -split '\|')[-1].Trim() }

$lines = New-Object System.Collections.Generic.List[string]
foreach ($c in $cands) {
    $lit = '"' + $c + '"'
    $i = $text.IndexOf($lit, [System.StringComparison]::Ordinal)
    if ($i -lt 0) { continue }
    $start = [Math]::Max(0, $i - 70)
    $len = [Math]::Min(160, $text.Length - $start)
    $ctx = $text.Substring($start, $len) -replace "\r", ' ' -replace "\n", ' '
    $lines.Add('### ' + $c)
    $lines.Add('    ' + $ctx)
}
[System.IO.File]::WriteAllLines($out, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("written: $out  entries: " + ($cands.Count))
