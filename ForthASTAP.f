need finiteFractions

512 buffer: ASTAP.buf0
512 buffer: ASTAP.buf1	
	
\ compute a hash h1 by hashing x1 and h0
: ASTAP.hash ( x1 h0 -- h1)
	31 * swap 13 + xor
;	
	
\ hash a string to a single value on stack
\ 	borrowed from simple-tester
: ASTAP.hash$ ( c-addr u -- h)
	swap 2dup + swap ( u end+1 start)
		?do													\ Let h0 = u
			i c@ ( h_i x) swap ASTAP.hash ( h_j) 	\ j = i + 1
		loop
;


\ Read the ini file produced by ASTAP after a plate solve
: ASTAP.readINI { caddr u | ra dec flag -- RA DEC 0  | IOR }
	caddr u r/o open-file ( file-id IOR ) ?dup if exit then >R
	0 -> flag	
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
\  return the full file path of the expected ASTAP ini file
: ASTAP.invoke { caddr u | m  n -- caddr' u' }
	ASTAP.buf1 256 42 fill									\ for clarity
	s" ASTAP -update -f " dup -> m ASTAP.buf1 swap move  \ m = 9
	caddr u ASTAP.buf1 m + swap move
	u m + -> n
	ASTAP.buf1 n ( 2dup type cr ) ShellCmd
	n 4 - -> n													\ 4 - to remove the "xisf" extension
	s" ini" ASTAP.buf1 n + swap move
	n 3 + m - -> n												\ 3 + to add the "ini" extension
	ASTAP.buf1 m + n 
;

\ Invoke ASTAP Astrometry Stacking Program to plate solve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure
: platesolve { caddr u -- RA DEC 0  | IOR }
	ASTAP.invoke ASTAP.readINI
;
