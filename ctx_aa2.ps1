$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\ctx_aa2.txt'
$lines = New-Object System.Collections.Generic.List[string]
$i = $t.IndexOf('C8e=[{id:"readFiles"', [System.StringComparison]::Ordinal)
if ($i -lt 0) { $i = $t.IndexOf('{id:"readFiles",label:', [System.StringComparison]::Ordinal) }
if ($i -lt 0) { $lines.Add('NOT FOUND') } else {
    $e = [Math]::Min($t.Length, $i + 2600)
    $lines.Add($t.Substring($i, $e - $i))
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output "written $out"
