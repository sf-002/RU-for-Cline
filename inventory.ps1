$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)

$propRx = '(?:children|title|aria-label|placeholder|label|shortName|description|tooltip|tooltipText|headerText|primaryText|secondaryText|helpText|name|buttonText|emptyText|notFoundText|searchPlaceholder|markdownDescription|enumDescriptions|message)"\s*:\s*"([^"]{3,220})"'
$arrRx  = '"enumDescriptions"\s*:\s*\[([^\]]{3,2000})\]'

$notUi = '(var\(--|\d+px|flex |codicon|url\(|https?://|^M\d|cubic-bezier|rgba?\(|^\d+[ )]|translate|\bauto\b.*\b\d|--vscode|^\.[a-z-]+$|^[a-z-]+$|^\d)'

$jobs = @(
    @{ name = 'WEBVIEW (next)'; file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'; out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv_webview.txt' },
    @{ name = 'EXTENSION HOST (next)'; file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\dist\extension.js'; out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv_host.txt' },
    @{ name = 'PACKAGE.JSON'; file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\package.json'; out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv_pkg.txt' }
)

foreach ($j in $jobs) {
    $text = [System.IO.File]::ReadAllText($j.file, [System.Text.Encoding]::UTF8)
    $counts = @{}
    foreach ($m in [regex]::Matches($text, $propRx)) {
        $v = $m.Groups[1].Value
        if ($v -notmatch '[A-Za-z]{2}') { continue }
        if ($v -match $notUi) { continue }
        if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 }
    }
    foreach ($m in [regex]::Matches($text, $arrRx)) {
        foreach ($s in [regex]::Matches($m.Groups[1].Value, '"([^"]{3,220})"')) {
            $v = $s.Groups[1].Value
            if ($v -notmatch '[A-Za-z]{2}' -or $v -match $notUi) { continue }
            if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 }
        }
    }
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add(('### ' + $j.name + '  |  unique display strings: ' + $counts.Count))
    foreach ($e in ($counts.GetEnumerator() | Sort-Object -Property @{Expression='Value';Descending=$true}, @{Expression='Key';Descending=$false})) {
        $lines.Add(("{0,4}  {1}" -f $e.Value, $e.Key))
    }
    [System.IO.File]::WriteAllLines($j.out, $lines, $enc)
    Write-Output ("{0}: {1} unique -> {2}" -f $j.name, $counts.Count, $j.out)
}
