# PowerShell Bridge for Bash Completions

Bridge to enable bash completions to be run from within PowerShell.

Commands like `kubectl` allow you to export command completion logic for use in bash. As these same commands get ported to Windows and/or used within PowerShell, porting the dynamic completion logic becomes challenging for the project maintainers. This project is an attempt to make a bridge so things "just work."

# Installation

1. Put the `Register-BashArgumentCompleter.ps1`, `bash_completion.sh`, and `bash_completion_bridge.sh` files in the same folder.
2. Make sure you have `bash.exe` in your path or that you have Git for Windows installed. If `bash.exe` isn't in the path, the version shipping with Git for Windows will be used.

# Usage

1. Locate the completion script for the bash command. You may have to export this like `kubectl completion bash > kubectl_completions.sh`
2. Run the `Register-BashArgumentCompleter.ps1` script to register the command you're expanding and the location of the completions.

Example:

`.\Register-BashArgumentCompleter.ps1 "kubectl" C:\completions\kubectl_completions.sh`

# How It Works

The idea is to register a PowerShell argument completer that will manually invoke the bash completion mechanism and return the output that bash would have provided. Basically, that means:

- A bridge script (`bash_completion_bridge.sh`) is used to load up the exported bash completions and manually invoke the completion functions.
- From PowerShell, locate bash, locate the bridge script, and register a completer that ties those together.
- When PowerShell invokes the completer, the completer arguments are taken and passed to the bash bridge.
- The bash bridge executes the actual completion and returns the results, which are passed back through to PowerShell.

It won't be quite as fast as if it was all running native but it means you can use provided bash completions instead of having to re-implement in PowerShell.

# Test Expansions

In the `test` folder there are some expansions to try:

- `Test-KubectlRegistration.ps1` - Expansions for `kubectl`
- `Test-EchoRegistration.ps1` - Simple echo script that shows completion parameters in bash; use `echotest` as the command to complete and whatever else after it to simulate command lines.