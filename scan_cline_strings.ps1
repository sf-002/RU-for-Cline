$ErrorActionPreference = 'Stop'
$file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$out  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\scan_out.txt'
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add(("FILE: {0} MB, chars: {1}" -f [math]::Round((Get-Item $file).Length / 1MB, 2), $text.Length))

$counts = @{}
$rx = [regex]'"([A-Z][A-Za-z0-9 ,.&%!:?()/-]{2,70})"'
foreach ($m in $rx.Matches($text)) {
    $s = $m.Groups[1].Value
    if ($counts.ContainsKey($s)) { $counts[$s]++ } else { $counts[$s] = 1 }
}
$lines.Add('')
$lines.Add('=== TOP 200 (strings containing a space = likely UI labels) ===')
$top = $counts.GetEnumerator() |
    Where-Object { $_.Key -match ' ' -and $_.Key -notmatch '^(https?|data|rgb|var|calc|translate|rgba|linear)' } |
    Sort-Object -Property @{Expression='Value';Descending=$true}, @{Expression='Key';Descending=$false} |
    Select-Object -First 200
foreach ($e in $top) { $lines.Add(("{0,4}  {1}" -f $e.Value, $e.Key)) }

$lines.Add('')
$lines.Add('=== ONBOARDING SCREEN PROBE (dq = "..." count) ===')
$probe = @(
    'How will you use Cline?', 'Select an option below to get started.', 'Absolutely Free',
    'Currently $0; no cost', 'ClinePass', 'Frontier Model', 'Bring my own API key',
    'Login to Cline', 'You can change this later in settings', 'Continue',
    'New Task', 'History', 'Settings', 'MCP Servers', 'Auto-approve', 'Start New Task',
    'Plan', 'Act', 'Chat', 'Clear', 'Approve', 'Reject', 'Retry', 'Save', 'Cancel'
)
foreach ($p in $probe) {
    $c  = ([regex]::Matches($text, [regex]::Escape('"' + $p + '"'))).Count
    $c2 = ([regex]::Matches($text, [regex]::Escape("'" + $p + "'"))).Count
    $lines.Add(("{0,4} dq {1,3} sq   {2}" -f $c, $c2, $p))
}

[System.IO.File]::WriteAllLines($out, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "written: $out"
