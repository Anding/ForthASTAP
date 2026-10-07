\ ASTAP autofocus capability without plate-solver binding.

NEED ForthBase

s" " $value ASTAP.str0
s" " $value ASTAP.str1
256 buffer: ASTAP.buf0

: ASTAP.waitForFile ( caddr u timeout -- IOR )
\ Wait up to timeout seconds for a subprocess result file.
	10 * 0 do
		2dup FileExists? if unloop 2drop 0 exit then
		100 ms
	loop
	2drop -1
;

: ASTAP.readFocus ( caddr u -- errlevel focuspos 0 | IOR )
\ Decode the integer result written by ASTAPFocus.ps1.
	r/o open-file if exit then >R
	ASTAP.buf0 dup 256 R> read-line drop
	if
		isInteger? 1 = if
			10000 /mod
			dup 0= if
				2drop -1
			else
				0
			then
		else
			-1
		then
	else
		2drop -1
	then
;

: astap.findfocus ( caddr u -- errlevel focuspos 0 | IOR )
\ Run ASTAP autofocus over the FITS images in a folder.
	s" pwsh.exe -File E:\coding\ForthASTAP\PowerShell\ASTAPFocus.PS1  " $-> ASTAP.str0
	2dup $+> ASTAP.str0
	ASTAP.str0 ShellCmd
	$-> ASTAP.str1
	s" \exitcode.txt" $+> ASTAP.str1
	ASTAP.str1 180 ASTAP.waitForFile if -1 exit then
	ASTAP.str1 ASTAP.readFocus
;
