$ErrorActionPreference = 'Stop'
$file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$out  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\scan3_out.txt'
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$cands = @(
 'How will you use Cline?','Select an option below to get started.','Absolutely Free','ClinePass',
 'Frontier Model','Bring my own API key','Login to Cline','Create my Account','Create Account',
 'Continue','Back','Cancel','Save','Save Changes','Approve','Reject','Retry','Retry Task',
 'New Task','Start New Task','Resume Task','Resume','Delete','Delete Task','Delete all history',
 'Clear','Clear search','Clear all','Copy','Copy Code','Copy failed','Edit','Edit Configuration',
 'History','Settings','Chat','MCP Servers','MCP','Servers','Tools','Resources','Prompts','Marketplace',
 'Plan','Act','Plan Mode','Act Mode','Ask','Auto-approve','Auto-Approve','Approve While Running',
 'Proceed While Running','Add to Context','Explain Code','Improve Code','View Diff','View changes',
 'Open File','Open in Editor','Show more','See more','Show less','Collapse','Expand','Follow up',
 'Send','Send message','Type a message...','Ask a question','Thinking','Thinking...','Generating',
 'Loading','Loading...','Error','Warning','Success','Info','Completed','Running','Waiting for approval',
 'Context Window','Context Window Size','Max Output Tokens','Max Tokens','Reasoning Effort',
 'Temperature','Top P','API Provider','API Key','API Provider ID','Base URL','Base URL:',
 'Model','Model ID','Model Configuration','OpenAI Compatible','Ollama','LM Studio','OpenRouter',
 'Anthropic','Custom Instructions','Use custom base URL','Enable Checkpoints','Checkpoints',
 'Auto Condense','Focus Chain','Advanced','Debug','About','Account','Usage','Language','Notifications',
 'Terminal','Browser','Files','Images','Video','Audio','Add Files','Add Files & Images','Add Image',
 'Search','Search and select a model...','Select a model','Favorite','Favorites','Create file',
 'Create skill','Create rule','Create workflow','New Rule','New Workflow','Rules','Workflows',
 'Skills','Delete Server','Console Logs','Learn more','Enter API Key...','Invalid API Key',
 'You must provide a valid API key or choose a different provider.','This file is outside of your workspace',
 'This is outside of your workspace','Compact Task','Completion summary','Tokens','Cost','Steps',
 'Duration','Response','Request','No data','Empty','Not set','Enabled','Disabled','Configure',
 'Reset','Default','Custom','Active','Inactive','Both','None','All','Close','Done','Finish',
 'Submit','Next','Previous','Skip','Start','Stop','Pause','Run','Cancel Task','Abort','Kill',
 'Task','Tasks','New','Open','Select','Change','Update','Refresh','Reload','Import','Export',
 'Upload','Download','Browse','Choose','Set','Add','Remove','Apply','Confirm','Yes','No',
 'Preferences','Configuration','Providers','Models','Tools & Features','Features','Integrations',
 'Experimental','Beta','General','Appearance','Keyboard Shortcuts','Help','Documentation',
 'Feedback','Report Issue','Community','Discord','GitHub','Log out','Log Out','Sign out','Sign Out',
 'Sign in','Sign In','Sign up','Upgrade','Upgrade to ClinePass','Billing','Plans','Pricing',
 'Free','Free Plan','Get Started','Get Started for Free','Try it now','Get Started Now',
 'Message','Message body','Message subject','Comment','Adds a comment','Blocking reason',
 'Access to this feature requires','Unsupported','Not supported','Unknown','Optional','Required'
)

$lines = New-Object System.Collections.Generic.List[string]
$found = 0; $risky = 0
$lines.Add('status | count | logicHits | string')
foreach ($c in $cands) {
    $lit = '"' + $c + '"'
    $n = ([regex]::Matches($text, [regex]::Escape($lit))).Count
    if ($n -eq 0) { continue }
    $found++
    $logic = 0
    $logic += ([regex]::Matches($text, [regex]::Escape($lit) + '\s*[=!]==?')).Count
    $logic += ([regex]::Matches($text, '[=!]==?\s*' + [regex]::Escape($lit))).Count
    $logic += ([regex]::Matches($text, 'case\s*' + [regex]::Escape($lit))).Count
    $logic += ([regex]::Matches($text, [regex]::Escape($lit) + '\s*:')).Count
    $logic += ([regex]::Matches($text, '\[\s*' + [regex]::Escape($lit) + '\s*\]')).Count
    $tag = if ($logic -gt 0) { $risky++; 'RISKY' } else { 'ok   ' }
    $lines.Add(("{0} | {1,4} | {2,4} | {3}" -f $tag, $n, $logic, $c))
}
$lines.Add('')
$lines.Add(("found: {0} / {1}; risky: {2}" -f $found, $cands.Count, $risky))
[System.IO.File]::WriteAllLines($out, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "written: $out"
