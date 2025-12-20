need simple-tester
include "E:\coding\ForthASTAP\ForthASTAP.f"

CR
Tstart
t{ s" E:\coding\ForthASTAP\Resources\image1.ini" ASTAP.readINI }T 13625 86003 0 ==
t{ s" E:\coding\ForthASTAP\Resources\image2.ini" ASTAP.readINI }T 19577 59779 0 ==
t{ s" E:\coding\ForthASTAP\Resources\image3.ini" ASTAP.readINI }T 19577 -59779 0 ==
t{ s" E:\coding\ForthASTAP\Resources\image4.ini" ASTAP.readINI }T -1 ==
Tend
CR