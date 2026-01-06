# pass the filename of the .xisf file as the argument, this script will delete the .ini and .wcs files created by ASTAP

$path = $args[0]

$ini = [System.IO.Path]::ChangeExtension($path, ".ini")
$wcs = [System.IO.Path]::ChangeExtension($path, ".wcs")
$log = [System.IO.Path]::ChangeExtension($path, ".log")	

Remove-Item -LiteralPath $ini -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $wcs -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $log -Force -ErrorAction SilentlyContinue