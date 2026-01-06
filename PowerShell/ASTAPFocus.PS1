<#
.SYNOPSIS
    Compute focus with ASTAP for all .fits files in a folder and record the exit code.

.DESCRIPTION
    Accepts a single parameter: the path to a folder. Finds all `.fits` files in
    that folder (non-recursive), builds sequential `-focusN` arguments for each
    file and runs `ASTAP.exe` with those arguments. The script writes the
    process exit code to `exitcode.txt` placed in the same folder. Non-
    terminating errors are suppressed so the script fails quietly.

.PARAMETER FOLDER
    Path to the folder containing `.fits` files to process.

.EXAMPLE
    .\ASTAPFocus.ps1 "C:\Images"
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $FOLDER
)

# Suppress non-terminating PowerShell errors (affects cmdlets, not external processes).
$ErrorActionPreference = 'SilentlyContinue'

# Gather all .fits files in the folder and sort them alphabetically by filename.
$fitsFiles = Get-ChildItem -Path $FOLDER -File -Filter '*.fits' | Sort-Object Name

# If no files are found, create an empty exitcode.txt and exit silently.
if (-not $fitsFiles -or $fitsFiles.Count -eq 0) {
    $exitCodePath = Join-Path $FOLDER 'exitcode.txt'
    New-Item -Path $exitCodePath -ItemType File -Force | Out-Null
    return
}

# Build the ASTAP.exe argument list with sequential -focusN switches.
$focusArguments = @()
$index = 1
foreach ($file in $fitsFiles) {
    $focusArguments += "-focus$index"
    $focusArguments += $file.FullName
    $index++
}

# Run ASTAP.exe with the generated arguments and capture the exit code.
# Do not pass an empty argument to ASTAP.exe; only pass the focus arguments.
$process = Start-Process -FilePath 'ASTAP.exe' `
    -ArgumentList $focusArguments `
    -WorkingDirectory $FOLDER `
    -NoNewWindow `
    -Wait `
    -PassThru

# Write the exit code back to exitcode.txt inside the target folder.
# If Start-Process failed and returned $null, create an empty exitcode.txt.
$exitCodePath = Join-Path $FOLDER 'exitcode.txt'
if ($process) {
    $exitCode = $process.ExitCode
    $exitCode | Out-File -FilePath $exitCodePath -Encoding ASCII
} else {
    New-Item -Path $exitCodePath -ItemType File -Force | Out-Null
}