need simple-tester
include "E:\coding\ForthASTAP\ForthASTAP.f"

CR
Tstart
T{ s" E:\coding\ForthASTAP\Testdata\solve\20dfdbdd79fb.fits" platesolve }T 16270 53772  0 ==
T{ s" E:\coding\ForthASTAP\Testdata\solve\fail01.fits" platesolve }T -1 ==
T{ s" E:\coding\ForthASTAP\Testdata\solve" ASTAP.solveFolder }T 0 ==
T{ s" nothing" ASTAP.solveFolder }T 0 ==    \ correct behavior, a comment on the process not on the plate solve

T{ s" E:\coding\ForthASTAP\Testdata\focus\exitcode.txt" astap.readfocus }T 11 2569 0 ==
T{ s" E:\coding\ForthASTAP\Testdata\focusfail\exitcode.txt" astap.readfocus }T -1 == 
T{ s" E:\coding\ForthASTAP\Testdata\empty\exitcode.txt" astap.readfocus }T -1 ==
T{ s" nothing" astap.readfocus }T -1 ==
Tend
CR