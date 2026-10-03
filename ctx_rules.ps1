$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\ctx_rules.txt'
$lines = New-Object System.Collections.Generic.List[string]

$i = $t.IndexOf('Rules allow you to', [System.StringComparison]::Ordinal)
if ($i -ge 0) {
    $s = [Math]::Max(0, $i - 400); $e = [Math]::Min($t.Length, $i + 2600)
    $lines.Add('==== rules/skills/workflows panel ====')
    $lines.Add($t.Substring($s, $e - $s))
    $lines.Add('')
}
$i = $t.IndexOf('New rule file', [System.StringComparison]::Ordinal)
if ($i -ge 0) {
    $s = [Math]::Max(0, $i - 1500); $e = [Math]::Min($t.Length, $i + 1500)
    $lines.Add('==== new rule dialog ====')
    $lines.Add($t.Substring($s, $e - $s))
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output "written $out"
