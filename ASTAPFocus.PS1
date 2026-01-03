# this script file accepts the name of a folder
# it will identify all the FITS files in the folder, compute the focus and write it to exitcode.txt

param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Folder
)

# Resolve the folder path and ensure it exists before proceeding.
$target = Get-Item -LiteralPath $Folder -ErrorAction Stop

# Gather all .xisf files in the folder and sort them alphabetically by filename.
$xisfFiles = Get-ChildItem -LiteralPath $target.FullName -Filter '*.fits' | Sort-Object Name

# Handle the case where no .fits files are found.
if ($xisfFiles.Count -eq 0) {
    Write-Error "No .fits files found in $($target.FullName)."
    $exitCodePath = Join-Path $target.FullName 'exitcode.txt'
    '0' | Out-File -FilePath $exitCodePath -Encoding ASCII
    exit 1
}

# Build the ASTAP.exe argument list with sequential -focusN switches.
$focusArguments = @()
$index = 1
foreach ($file in $xisfFiles) {
    $focusArguments += "-focus$index"
    $focusArguments += $file.FullName
    $index++
}

# Run ASTAP.exe with the generated arguments and capture the exit code.
$logFile = Join-Path $target.FullName 'astap.log'
$errorFile = Join-Path $target.FullName 'astap.err'
# $fixedArguments = @('-debug')
$fixedArguments = @('')
$process = Start-Process -FilePath 'ASTAP.exe' `
    -ArgumentList ($fixedArguments + $focusArguments) `
    -WorkingDirectory $target.FullName `
    -NoNewWindow `
    -Wait `
    -PassThru `
    -RedirectStandardOutput $logFile `
    -RedirectStandardError $errorFile

# Write the exit code back to exitcode.txt inside the target folder.
$exitCode = $process.ExitCode
$exitCodePath = Join-Path $target.FullName 'exitcode.txt'
$exitCode | Out-File -FilePath $exitCodePath -Encoding ASCII