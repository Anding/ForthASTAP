\ Verify that autofocus support does not select or load a plate solver.

NEED simple-tester
NEED ForthASTAPFocus

Tstart
T{ [DEFINED] solve-image }T 0 ==
T{ [DEFINED] allocate-frame }T 0 ==
T{ s" E:\coding\ForthASTAP\Testdata\focus\exitcode.txt"
	ASTAP.readFocus
}T 11 2569 0 ==
Tend
