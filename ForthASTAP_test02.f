need simple-tester
include "E:\coding\ForthASTAP\ForthASTAP.f"

s" E:\Coding\ForthASTAP\Testdata\solve\89058d892eac.wcs"  ASTAP.readWCS 

cr .
 
ASTAP.solved.RA             cr .RA
ASTAP.solved.Dec            cr .Dec
ASTAP.reported.RA           cr .RA
ASTAP.reported.Dec          cr .Dec
ASTAP.reported.Sidereal     cr .RA
ASTAP.reported.NightOf      cr ~.
ASTAP.reported.Pierside$    cr type  

ASTAP.formatALPT            cr type

s" E:\Coding\ForthASTAP\Testdata\solve\89058d892eac.wcs" ASTAP.WCS-to-ALPT cr . cr type

s" E:\Coding\ForthASTAP\Testdata\solve\" ASTAP.folder-to-ALPT cr . cr type
