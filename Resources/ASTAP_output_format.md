# ASTAP output format


In command line mode the program produces two output files at the same location as the input image. In case a solution is found it will write a .wcs file 1) containing the solved FITS header only.  In any case it will write an INI file using the standard FITS keywords.

Example of the INI output file after an successful solve:
```
PLTSOLVD=T                                     // T=true, F=false
CRPIX1= 1.1645000000000000E+003                // X of reference & centre pixel
CRPIX2= 8.8050000000000000E+002                // Y of reference & centre pixel  
CRVAL1= 1.5463033992314939E+002                // RA (J2000) of the reference pixel [deg]                   
CRVAL2= 2.2039358425145043E+001                // DEC (J2000)of the reference pixel [deg]                   
CDELT1=-7.4798001762187193E-004                // X pixel size [deg]
CDELT2= 7.4845252983311850E-004                // Y pixel size [deg]
CROTA1=-1.1668387329628058E+000                // Image twist of X axis [deg]
CROTA2=-1.1900321176194073E+000                // Image twist of Y axis [deg]                
CD1_1=-7.4781868711882519E-004                 // CD matrix to convert (x,y) to (Ra, Dec)  
CD1_2= 1.5241315209850368E-005                 // CD matrix to convert (x,y) to (Ra, Dec)                                   
CD2_1= 1.5534412042060001E-005                 // CD matrix to convert (x,y) to (Ra, Dec)             
CD2_2= 7.4829732842251226E-004                 // CD matrix to convert (x,y) to (Ra, Dec)
CMDLINE=......                                 // Text message containing command line used
WARNING=......                                 // Text message containing warning(s)
```

The reference pixel is always specified for the centre of the image. The decimal separator is always a dot as for FITS headers.

Example of the INI output file in case of solve failure:
```
PLTSOLVD=F                                     // T=true, F=false
CMDLINE=......                                 // Text message containing command line used
ERROR= .....                                   // Text message containing any error(s). Same as exit code errors
WARNING= .....                                 // Text message containing any warnings(s)
```
The .wcs file contains the original FITS header with the solution added. No data, just the header. Any warning is added to the .wcs file using the keyword WARNING. This warning could be presented to the user for information.