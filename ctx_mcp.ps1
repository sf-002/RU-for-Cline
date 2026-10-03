$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\ctx_mcp.txt'
$lines = New-Object System.Collections.Generic.List[string]

$anchors = @('Connect Cline to external', 'No MCP servers installed', 'Add Remote Server', 'Advanced MCP Settings')
foreach ($a in $anchors) {
    $i = $t.IndexOf($a, [System.StringComparison]::Ordinal)
    if ($i -lt 0) { $lines.Add("NOT FOUND: $a"); continue }
    $s = [Math]::Max(0, $i - 120); $e = [Math]::Min($t.Length, $i + 240)
    $lines.Add('==== ' + $a + ' ====')
    $lines.Add($t.Substring($s, $e - $s))
    $lines.Add('')
}
# tab list around the Skills tab (its Russian label "Навыки" was produced by us)
$i = $t.IndexOf([char]0x041D + [char]0x0430 + [char]0x0432 + [char]0x044B + [char]0x043A + [char]0x0438, [System.StringComparison]::Ordinal)
if ($i -ge 0) {
    $s = [Math]::Max(0, $i - 700); $e = [Math]::Min($t.Length, $i + 300)
    $lines.Add('==== tabs context ====')
    $lines.Add($t.Substring($s, $e - $s))
    $lines.Add(('index of Навыки: ' + $i))
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output "written $out"
