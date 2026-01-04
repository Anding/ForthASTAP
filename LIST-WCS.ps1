<#
.SYNOPSIS
    Create a list of .wcs files in a folder and write it to WCS-LIST.txt.

.DESCRIPTION
    Accepts a single parameter: the path to a folder. Scans the folder (non-recursive)
    for files whose extension is `.wcs` (case-insensitive) and writes one line per
    match containing the file's full path into `WCS-LIST.txt` placed in the same folder.
    The script overwrites any existing `WCS-LIST.txt`. Non-terminating errors are
    suppressed so the script fails quietly.

.PARAMETER FOLDER
    Path to the folder to scan for `.wcs` files.

.EXAMPLE
    .\LIST-WCS.ps1 "C:\Images"
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $FOLDER
)

# Suppress non-terminating PowerShell errors (affects cmdlets, not external process exits).
$ErrorActionPreference = 'SilentlyContinue'

# Output file in the same folder
$outputPath = Join-Path -Path $FOLDER -ChildPath 'WCS-LIST.txt'

# Find .wcs files (case-insensitive), non-recursive, sorted by name.
$files = Get-ChildItem -Path $FOLDER -File |
    Where-Object { $_.Extension.ToLower() -eq '.wcs' } |
    Sort-Object Name

# Write the full path of each file to WCS-LIST.txt, one per line.
# Out-File overwrites the file by default, producing a new file as requested.
$files | ForEach-Object { $_.FullName } | Out-File -FilePath $outputPath -Encoding UTF8

# End - intentionally minimal output (silent on error).