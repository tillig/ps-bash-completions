# PowerShell Bridge for Bash Completions

Bridge to enable bash completions to be run from within PowerShell.

Commands like `kubectl` allow you to export command completion logic for use in bash. As these same commands get ported to Windows and/or used within PowerShell, porting the dynamic completion logic becomes challenging for the project maintainers. This project is an attempt to make a bridge so things "just work."

**NOTE: It doesn't "just work" yet.** I'm still working on it.

The idea is to register a PowerShell argument completer that will manually invoke the bash completion mechanism and return the output that bash would have provided. Basically, that means:

- A bridge script (`bash_completion_bridge.sh`) is used to load up the exported bash completions and manually invoke the completion functions.
- From PowerShell, locate bash, locate the bridge script, and register a completer that ties those together.
- When PowerShell invokes the completer, the completer arguments are taken and passed to the bash bridge.
- The bash bridge executes the actual completion and returns the results, which are passed back through to PowerShell.

It won't be quite as fast as if it was all running native but it means you can use provided bash completions instead of having to re-implement in PowerShell.

I'm using the `Test-KubectlRegistration.ps1` script to invoke registration of some exported `kubectl` completions. If I can get that working, I'll try others.