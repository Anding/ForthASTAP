need finiteFractions

\ values presented in the .ini file are parsed as floating point numbers by VFX Forth
\ RA is presented in degrees, so divide by 24
s" 5.6768965776997369E+001" >float drop s" 15.0" >float drop f/ 
fp~
CR dup ~.
CR dup ~$ type
CR 'h' 'm' 0 ~custom$ type

\ Declination in degrees
s" 2.3889596666131958E+001" >float drop
fp~
CR dup ~.
CR dup ~$ type
CR 'd' ''' -1 ~custom$ type

\ Test if negative numbers also handled
s" -8.5041715965678577E+001" >float drop
fp~ 
CR dup ~.
CR dup ~$ type
CR 'd' ''' -1 ~custom$ type

CR


s" Astap -f E:\coding\ForthASTAP\Resources\image1.xisf" ShellCmd

( c-addr u) ASTAP.buffer 9 + move
s" Astap -f " ASTAP.buffer swap move
