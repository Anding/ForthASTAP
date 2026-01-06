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

    For each input file the script waits until ASTAP produces a sidecar `.ini`
    file with the same base filename (replacement of the input extension with
    `.ini`) before proceeding to the next input. This ensures ASTAP has
    completed processing each file before the script moves on. If the `.ini`
    file is not observed within 10 seconds the script gives up waiting and
    proceeds to the next file.

    As the final step the script deletes all `.ini` sidecar files from the
    folder so only the intended output files remain.

.PARAMETER FOLDER
    Path to the folder containing `.fits` and `.xisf` files.

.EXAMPLE
    .\run-astap.ps1 "C:\Images"
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $FOLDER
)

# Suppress non-terminating PowerShell errors (affects cmdlets, not external processes).
$ErrorActionPreference = 'SilentlyContinue'

# Remove any .ini sidecar files already in the folder.
Get-ChildItem -Path $FOLDER -Filter '*.ini' -File | Remove-Item -Force -ErrorAction SilentlyContinue

# Collect files with the desired extensions (case-insensitive), non-recursive.
$files = Get-ChildItem -Path $FOLDER -File |
    Where-Object { @('.fits', '.xisf') -contains $_.Extension.ToLower() } |
    Sort-Object Name

# Maximum time to wait for the .ini sidecar (seconds) and polling interval (ms).
$timeoutSeconds = 10
$pollMilliseconds = 200

# Process each file in turn. Direct invocation of `astap` is synchronous.
foreach ($file in $files) {
    # Run astap on the file
    astap -f $file.FullName

    # Wait for the companion .ini file (same base name, extension .ini) which
    # ASTAP creates when processing is finished. Poll until the file exists or
    # until the timeout elapses.
    $iniPath = [System.IO.Path]::ChangeExtension($file.FullName, '.ini')
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while ((-not (Test-Path -Path $iniPath)) -and ($stopwatch.Elapsed.TotalSeconds -lt $timeoutSeconds)) {
        Start-Sleep -Milliseconds $pollMilliseconds
    }
    $stopwatch.Stop()
}

# Remove any .ini sidecar files left in the folder.
Get-ChildItem -Path $FOLDER -Filter '*.ini' -File | Remove-Item -Force -ErrorAction SilentlyContinue

# After processing all files, invoke the provided LIST-WCS.ps1 script,
# passing the folder path as the first positional argument.
E:\coding\ForthASTAP\PowerShell\LIST-WCS.ps1 $FOLDER

# End - intentionally silent on errors.