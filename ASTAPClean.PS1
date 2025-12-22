# pass the filename of the .xisf file as the argument, this script will delete the .ini and .wcs files created by ASTAP

$path = $args[0]

$ini = [System.IO.Path]::ChangeExtension($path, ".ini")
$wcf = [System.IO.Path]::ChangeExtension($path, ".wcf")

Remove-Item -LiteralPath $ini -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $wcf -Force -ErrorAction SilentlyContinue