\ Verify the single ASTAP package loads focus support and its solver together.

NEED simple-tester
NEED ForthASTAP

Tstart
T{ ACTION-OF solve-image ' astap.solve-image = }T -1 ==
T{ [DEFINED] allocate-frame }T -1 ==
T{ s" E:\coding\ForthASTAP\Testdata\focus\exitcode.txt"
	ASTAP.readFocus
}T 11 2569 0 ==
Tend
