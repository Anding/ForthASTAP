\ Verify that autofocus support does not select or load a plate solver.

NEED simple-tester
NEED ForthASTAPFocus

[DEFINED] solve-image [IF]
	abort" ForthASTAPFocus must not define solve-image"
[THEN]

[DEFINED] allocate-frame [IF]
	abort" ForthASTAPFocus must not load frame formats"
[THEN]

Tstart
T{ s" E:\coding\ForthASTAP\Testdata\focus\exitcode.txt"
	ASTAP.readFocus
}T 11 2569 0 ==
Tend

bye
