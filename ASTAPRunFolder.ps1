<#
.SYNOPSIS
    Run ASTAP on every .fits and .xisf file in a folder, then call LIST-WCS.ps1
    passing the folder name as an argument.

.DESCRIPTION
    Accepts a single parameter: the path to a folder. The script finds all files
    in that folder with extensions .fits or .xisf (non-recursive), runs
    `astap -f <file>` on each file in turn (synchronously), and after the last
    file finishes invokes a hardcoded `LIST-WCS.ps1` script, passing the folder
    path as the first argument. The script assumes `astap` is on PATH and that
    the provided LIST-WCS path will be updated by you. All output and errors are
    suppressed so the script fails quietly.

.PARAMETER FOLDER
    Path to the folder containing `.fits` and `.xisf` files.

.EXAMPLE
    .\run-astap.ps1 "C:\Images"
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $FOLDER
)

# Update this to the full path of your LIST-WCS.ps1 script.
$LISTWCS_PATH = 'C:\full\path\to\LIST-WCS.ps1'

# Suppress non-terminating PowerShell errors (affects cmdlets, not external processes).
$ErrorActionPreference = 'SilentlyContinue'

# Collect files with the desired extensions (case-insensitive), non-recursive.
$files = Get-ChildItem -Path $FOLDER -File |
    Where-Object { @('.fits', '.xisf') -contains $_.Extension.ToLower() } |
    Sort-Object Name

# Process each file in turn. Direct invocation of `astap` is synchronous.
foreach ($file in $files) {
    # Run astap on the file and suppress both stdout and stderr.
    #
    # - `> $null` redirects standard output (PowerShell success stream 1) to $null.
    # - `2>&1` redirects standard error (stream 2) into the success stream (1),
    #   so both streams are discarded when stream 1 is sent to $null.
    astap -f $file.FullName > $null 2>&1
}

# After processing all files, invoke the provided LIST-WCS.ps1 script,
# passing the folder path as the first positional argument.
# Use the call operator because the script path is stored in a variable.
& $LISTWCS_PATH $FOLDER > $null 2>&1

# End - intentionally silent on errors.