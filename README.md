# PowerShell Bridge for Bash Completions

Bridge to enable bash completions to be run from within PowerShell.

Commands like `kubectl` allow you to export command completion logic for use in bash. As these same commands get ported to Windows and/or used within PowerShell, porting the dynamic completion logic becomes challenging for the project maintainers. This project is an attempt to make a bridge so things "just work."

# Installation

**First, make sure you have `bash.exe` in your path or that you have Git for Windows installed.** If `bash.exe` isn't in the path, the version shipping with Git for Windows will be used.

## From PowerShell Gallery

`Install-Module -Name "PSBashCompletions"`

## Manual Install

1. Put the `PSBashCompletions` folder in your PowerShell module folder (e.g., `C:\Users\username\Documents\WindowsPowerShell\Modules`).
2. `Import-Module PSBashCompletions`

# Usage

1. Locate the completion script for the bash command. You may have to export this like:
    ```PowerShell
    ((kubectl completion bash) -join "`n") | Set-Content -Encoding ASCII -NoNewline -Path kubectl_completions.sh
    ```
    **Make sure the completion file is ASCII.** Some exports (like `kubectl`) come out as UTF-16 with CRLF line endings. Windows `bash` may see this as a binary file that can't be interpreted which results in no completions happening.  Using `join` and `Set-Content`  ensures the completions script will load in bash.

2. Run the `Register-BashArgumentCompleter` cmdlet to register the command you're expanding and the location of the completions.
    Example:
    ```PowerShell
    Register-BashArgumentCompleter "kubectl" C:\completions\kubectl_completions.sh`
    ```

# How It Works

The idea is to register a PowerShell argument completer that will manually invoke the bash completion mechanism and return the output that bash would have provided. Basically, that means:

- A bridge script (`bash_completion_bridge.sh`) is used to load up the exported bash completions and manually invoke the completion functions.
- From PowerShell, locate bash, locate the bridge script, and register a completer that ties those together.
- When PowerShell invokes the completer, the completer arguments are taken and passed to the bash bridge.
- The bash bridge executes the actual completion and returns the results, which are passed back through to PowerShell.

It won't be quite as fast as if it was all running native but it means you can use provided bash completions instead of having to re-implement in PowerShell.

# Demo Expansions

In the `Demo` folder there are some expansions to try:

- `Register-KubectlCompleter.ps1` - Expansions for `kubectl`
- `Register-GitCompleter.ps1` - Expansions for `git`
- `Register-EchoTestCompleter.ps1` - Simple echo script that shows completion parameters in bash; use `echotest` as the command to complete and whatever else after it to simulate command lines.

# Troubleshooting

There are lots of moving pieces, so if things aren't working there isn't "one answer" as to why.

**First, run `Register-BashArgumentCompleter` with the `-Verbose` flag.** When you do that, you'll get a verbose line that shows the actual `bash.exe` command that will be used to generate completions. You can copy that and run it yourself to see what happens.

The command will look something like this:

`&"C:\Program Files\Git\bin\bash.exe" "/c/Users/username/Documents/WindowsPowerShell/Modules/PSBashCompletions/1.0.0/bash_completion_bridge.sh" "/c/completions/kubectl_completions.sh" "<url-encoded-command-line>"`

The last parameter is what you can play with - it's a URL-encoded version of the whole command line being completed (with `%20` as space, not `+`).

Say you're testing `kubectl` completions and want to see what would happen if you hit TAB after `kubectl c`. You'd run:

`&"C:\Program Files\Git\bin\bash.exe" "/c/Users/username/Documents/WindowsPowerShell/Modules/PSBashCompletions/1.0.0/bash_completion_bridge.sh" "/c/completions/kubectl_completions.sh" "kubectl%20c"`

If it works, you'd see a list like:

```
certificate
cluster-info
completion
config
convert
cordon
cp
create
```

**If it generates an error, that's the error to troubleshoot.**

Common things that can go wrong:

- Bash isn't found or the path to bash is wrong.
- Your completion script isn't found or the path is wrong.
- Your completion script isn't UTF-8 or ASCII. UTF-16 doesn't get read as text by Windows `bash`.
- You have something in your bash profile that's interfering with the completions.
- You're trying to use a completion that isn't compatible with the Windows version of the command. This happens with `git` completions - you need to use the completion script that comes with Git for Windows, not the Linux version.
- The completions rely on other commands or functions that aren't available/loaded. If the completion script isn't self-contained, things won't work. For example, the `kubectl` completions actually call `kubectl` to get resource names in some completions. If bash can't find `kubectl`, the completion won't work.

# Add to Your Profile

After installing the module you can set the completions to be part of your profile. One way to do that:

- Create a folder for completions in your PowerShell profile folder, like: `C:\Users\username\OneDrive\Documents\WindowsPowerShell\bash-completion`
- Save all of your completions in there (e.g., `kubectl_completions.sh`).
- Add a script block to your `Microsoft.PowerShell_profile.ps1` that looks for `bash` (or Git for Windows) and conditionally registers completions based on that. (This will avoid errors if you sync your PowerShell profile to machines that might not have bash.)

```powershell
$enableBashCompletions = ($Null -ne (Get-Command bash -ErrorAction Ignore)) -or ($Null -ne (Get-Command git -ErrorAction Ignore))

if ($enableBashCompletions) {
  Import-Module PSBashCompletions
  $completionPath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($profile), "bash-completion")
  Register-BashArgumentCompleter kubectl "$completionPath/kubectl_completions.sh"
  Register-BashArgumentCompleter git "$completionPath/git_completions.sh"
}
```

# Known Issues

PowerShell doesn't appear to pass _flags_ to custom argument completers. So, say you tried to do this:

`kubectl apply -<TAB>`

Note the `TAB` after the dash `-`. In bash you'd get completions for the flag like `-f` or `--filename`. PowerShell doesn't seem to call a custom argument completer for flags. (If you know how to make that work [let me know!](https://github.com/tillig/ps-bash-completions/issues))
