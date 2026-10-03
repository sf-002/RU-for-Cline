$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\ctx_tabs.txt'
$lines = New-Object System.Collections.Generic.List[string]

foreach ($a in @('type:"plugin",label:', 'type:"mcp",label:')) {
    $i = $t.IndexOf($a, [System.StringComparison]::Ordinal)
    if ($i -lt 0) { $lines.Add("NOT FOUND: $a"); continue }
    $s = [Math]::Max(0, $i - 900); $e = [Math]::Min($t.Length, $i + 1400)
    $lines.Add('==== ' + $a + ' ====')
    $lines.Add($t.Substring($s, $e - $s))
    $lines.Add('')
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output "written $out"
