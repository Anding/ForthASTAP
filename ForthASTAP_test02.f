need simple-tester
include "E:\coding\ForthASTAP\ForthASTAP.f"

s" E:\coding\ForthASTAP\Resources\88d4125d4216.wcs"  ASTAP.readWCS 

cr .
 
ASTAP.solved.RA             cr .RA
ASTAP.solved.Dec            cr .Dec
ASTAP.reported.RA           cr .RA
ASTAP.reported.Dec          cr .Dec
ASTAP.reported.Sidereal     cr .RA
ASTAP.reported.NightOf      cr ~.
ASTAP.reported.Pierside$    cr type  
