need forthbase
need finiteFractions
need forth-map   

512 buffer: ASTAP.buf0
512 buffer: ASTAP.buf1	
	
\ compute a hash h1 by hashing x1 and h0
: ASTAP.hash ( x1 h0 -- h1)
	31 * swap 13 + xor
;	
	
\ hash a string to a single value on stack
\ 	borrowed from simple-tester
\   used in scanning a .wcs file
: ASTAP.hash$ ( c-addr u -- h)
	swap 2dup + swap ( u end+1 start)
		?do													\ Let h0 = u
			i c@ ( h_i x) swap ASTAP.hash ( h_j) 	\ j = i + 1
		loop
;


: 10u.~Dec$ ( deg-min-sec -- caddr u)
 \ format for the :newalpt command
    ':' ':' -1 ~custom$
 ;
 
: 10u.~RA$ ( hr-min-sec -- caddr u)
 \ format for the :newalpt command
    ':' ':' 0 ~custom$ ( caddr u)
    s" HH:MM:SS.0" drop dup >R       
    ( caddr u dest R:dest) swap move R> 10
 ; 

\ Global values obtained from scanning the ASTAP WCS file

\ finite fraction single integer format
s" " value ASTAP.solved.RA
s" " value ASTAP.solved.Dec

\ string format compatible with the 10Micron :newalpt command
s" " $value ASTAP.solved.RA$
s" " $value ASTAP.solved.Dec$
s" " $value ASTAP.reported.RA$
s" " $value ASTAP.reported.Dec$
s" " $value ASTAP.reported.Sidereal$
s" " $value ASTAP.reported.Pierside$

\ Read the wcs file produced by ASTAP after a plate solve and populate the data

: ASTAP.readWCS ( caddr u  -- IOR)
\ read a WCS file and populate the ForthASTAP globals with the relevant FITS values
    r/o open-file ( file-id IOR ) if exit then >R
	begin
		ASTAP.buf0 dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
	while
		2dup drop 8 ASTAP.hash$ ( c-addr u2 h)
	case
		1035617187  ( "CRVAL1  ") of                \ CRVAL1 reports RA in degrees
		    drop 10 + 20 >float drop 1.5E1 f/ fp~ 
		    dup -> ASTAP.solved.RA
		    \ *** convert J2000 to JNOW for reporting back to the mount
		    10u.~RA$ $-> ASTAP.solved.RA$     
		endof
		1035616990  ( "CRVAL2  ") of 
		    drop 10 + 20 >float drop fp~ 
		    dup -> ASTAP.solved.Dec
		    \ *** convert J2000 to JNOW for reporting back to the mount		    
		    10u.~Dec$ $-> ASTAP.solved.Dec$    
		endof
		602714565   ( "OBJCTRA ") of drop 10 + 10 >number~ 10u.~RA$     $-> ASTAP.reported.RA$          endof  \ *** replace with RA_JNOW
		602712226   ( "OBJCTDEC") of drop 10 + 10 >number~ 10u.~Dec$    $-> ASTAP.reported.Dec$         endof  \ *** replace with DECJNOW
		-1898806661 ( "SIDEREAL") of drop 10 + 10 >number~ 10u.~RA$     $-> ASTAP.reported.Sidereal$    endof
		1151949815  ( "PIERSIDE") of drop 10 + 1                        $-> ASTAP.reported.Pierside$    endof
	    nip nip 
	endcase
	repeat   
	drop drop
	R> close-file drop 0
;

\ Read the ini file produced by ASTAP after a plate solve and report the solved RA and Dec
: ASTAP.readINI { caddr u | ra dec flag -- RA DEC 0  | IOR }
	0 -> flag
	caddr u r/o open-file ( file-id IOR ) if exit then >R
	begin
		ASTAP.buf0 dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
	while
		2dup drop 6 ASTAP.hash$ ( c-addr u2 h)
		case
		-1959004665 ( "CRVAL1") of 7 /string >float drop 1.5E1 f/ fp~ -> ra endof		\ degrees to hours
		-1959004666 ( "CRVAL2") of 7 /string >float drop fp~ -> dec -1 -> flag endof
		nip nip 
		endcase
	repeat
	drop drop 	
	R> close-file drop	
	flag if ra dec 0 else -1 then
;

\ Invoke ASTAP for a plate solve
\ 	take the full file path of the image as an xisf file
\  return the full file path of the expected ASTAP wcs file
: ASTAP.invoke { caddr u | m  n -- caddr' u' }
	ASTAP.buf1 512 42 fill                                      \ for debug clarity
	s" ASTAP -f " dup -> m ASTAP.buf1 swap move                 \ m = 9
	caddr u ASTAP.buf1 m + swap move
	u m + -> n
	ASTAP.buf1 n ( 2dup type cr ) ShellCmd
	n 4 - -> n                                                  \ 4 - to remove the "xisf" or "fits" extension
	s" wcs" ASTAP.buf1 n + swap move
	n 3 + m - -> n												\ 3 + to add the "ini" extension
	ASTAP.buf1 m + n 
;

\ Wait for ASTAP to complete a plate solve 
\  take and return the file path of the wcs file
: ASTAP.waitForSolve ( caddr u -- caddr u)
	100 0 do			\ 10 second timeout
		2dup FileExists? if unloop exit then
		100 ms
	loop
;

\ Invoke ASTAP Astrometry Stacking Program to plate solve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure
: platesolve { caddr u | m -- RA DEC 0  | IOR }
	caddr u ASTAP.invoke ASTAP.waitForSolve ASTAP.readWCS
	if ASTAP.solved.RA ASTAP.solved.Dec 0 else -1 then
	\ clean up the ASTAP files
    ASTAP.buf1 512 42 fill									\ for clarity
    s" pwsh.exe -File E:\coding\ForthASTAP\ASTAPClean.PS1 " dup -> m ASTAP.buf1 swap move
    caddr u ASTAP.buf1 m + swap move
    ASTAP.buf1 u m + ShellCmd
;



: ASTAP