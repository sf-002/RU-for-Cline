$ErrorActionPreference = 'Stop'
$file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$out  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\scan2_out.txt'
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$modelPrefix = '^(Claude|GPT|Gemini|DeepSeek|Qwen|Grok|Kimi|GLM|Muse|Nemotron|Mistral|Llama|Gemma|Step|Fugu|Hy|Inkling|Devstral|Codestral|Writer|Perplexity|Sonnet|Opus|Haiku|Adaptive|Open Sans|Lex|Parse|Inkling|Maverick)\b'
$svgLike = '(^M\d|[ML] ?[\d.-]+ ?[\d.-]* [ML]|a\d+ \d+ 0 0|^M ?[\d,])'

$strings = @{}
$rx = [regex]'"([^"\\]{3,80})"'
foreach ($m in $rx.Matches($text)) {
    $s = $m.Groups[1].Value
    if ($s -match '[A-Za-z]' -and $s -notmatch '^\s|\s$') {
        if ($strings.ContainsKey($s)) { $strings[$s]++ } else { $strings[$s] = 1 }
    }
}

$lines = New-Object System.Collections.Generic.List[string]

$lines.Add('=== A: PHRASES (multi-word, likely UI text) ===')
$phrases = $strings.GetEnumerator() |
    Where-Object {
        $_.Key -match ' ' -and
        $_.Key -notmatch $modelPrefix -and
        $_.Key -notmatch $svgLike -and
        $_.Key -notmatch '^(https?:|data:|rgb|rgba|var\(|calc|translate|linear-)' -and
        $_.Key -notmatch '\d\s*\d' -and
        $_.Key -match '^[A-Z]'
    } |
    Sort-Object -Property @{Expression='Value';Descending=$true}, @{Expression='Key';Descending=$false}
$lines.Add(("total phrases: {0}" -f @($phrases).Count))
foreach ($e in ($phrases | Select-Object -First 250)) { $lines.Add(("{0,4}  {1}" -f $e.Value, $e.Key)) }

$lines.Add('')
$lines.Add('=== B: SINGLE WORDS (TitleCase, len 4-20, count>=2) ===')
$words = $strings.GetEnumerator() |
    Where-Object {
        $_.Key -match '^[A-Z][a-z]{3,19}$' -and
        $_.Value -ge 2 -and
        $_.Key -notmatch '^(Claude|Gemini|DeepSeek|Qwen|Grok|Kimi|Muse|Mistral|Llama|Gemma|Step|Fugu|Hy|Inkling|Devstral|Codestral|Writer|Perplexity|Sonnet|Opus|Haiku|Open|Lex|Parse|Modal|Div|Span|Button|Input|Text|Image|Icon|Path|Props|State|Type|Name|Value|Error|Array|Object|String|Number|Boolean|Promise|React|Node|Style|Class|Event|Target|Source|Result|Index|Length|Width|Height|Color|Theme|Lang|Locale|Title|Label|Children|Handler|Context|Reducer|Action|Store|Hook|Props)\b'
    } |
    Sort-Object -Property @{Expression='Value';Descending=$true}, @{Expression='Key';Descending=$false}
$lines.Add(("total words: {0}" -f @($words).Count))
foreach ($e in ($words | Select-Object -First 200)) { $lines.Add(("{0,4}  {1}" -f $e.Value, $e.Key)) }

[System.IO.File]::WriteAllLines($out, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "written: $out"
