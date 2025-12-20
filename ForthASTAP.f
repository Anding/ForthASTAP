need finiteFractions

256 buffer: ASTAP.linebuffer
	
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


\ Invoke ASTAP Astrometry Stacking Program to plate solinclude ve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure
: ASTAP.readINI { caddr u | ra dec flag -- RA DEC 0  | IOR }
	caddr u r/o open-file ( file-id IOR ) ?dup if exit then >R
	0 -> flag	
	begin
		ASTAP.linebuffer dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
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
		
