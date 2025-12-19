need finiteFractions

256 buffer: ForthASTAP.linebuffer
	
\ compute a hash h1 by hashing x1 and h0
: ForthASTAP.hash ( x1 h0 -- h1)
	31 * swap 13 + xor
;	
	
\ hash a string to a single value on stack
\ 	borrowed from simple-tester
: ForthASTAP.hash$ ( c-addr u -- h)
	swap 2dup + 1- swap ( u end start)
		?do												\ Let h0 = u
			i c@ ( h_i x) swap hash ( h_j)		\ j = i + 1
		loop
;

\ Invoke ASTAP Astrometry Stacking Program to plate solve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure
: platesolve ( " filepath.xisf" -- RA DEC 0 | IOR)
	read-file open-file ( file-id) >R
	ForthASTAP.linebuffer dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) 
	drop if
		2dup drop 5 hash$ 
		case
		 1234 ( "CRVAL1") of 
		 	endof
		 5678 ( "CRVAL2") of 
		 	endof
		 endcase
	end if
;
		
	