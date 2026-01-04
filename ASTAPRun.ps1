<#
.SYNOPSIS
    Run ASTAP with a single file argument and fail quietly.

.DESCRIPTION
    Accepts a single parameter named FILENAME (full path including filename) and invokes
    the external program `astap` with the `-f` switch. The script assumes the filepath
    is correct, that `astap` is available on PATH, and suppresses all output and errors
    so it fails quietly.

.PARAMETER FILENAME
    Full path to the file to pass to `astap -f`.

.EXAMPLE
    .\run-astap.ps1 "E:\Images\target.fits"
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $FILENAME
)

# Suppress non-terminating PowerShell errors (affects cmdlets, not external processes).
$ErrorActionPreference = 'SilentlyContinue'

# Invoke astap (direct invocation is fine when the executable is on PATH).

astap -f $FILENAME
