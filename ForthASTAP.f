include e:\coding\forthbase\libraries\libraries.f
need finiteFractions

\ values presented in the .ini file are parsed as floating point numbers by VFX Forth
\ RA is presented in degrees, so divide by 24
5.6768965776997369E+001 1.5E+1 f/ 
fp~~~ 
CR ~~~.

\ Declination in degrees
2.3889596666131958E+001 
fp~~~
CR ~~~.

\ Test if negative numbers also handled
-8.5041715965678577E+001
fp~~~ 
CR ~~~.

CR

\\ problems here - check how to define VFX floating point recogntion characters
