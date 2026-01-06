need forthbase
need finiteFractions
need forth-map   
    
\ a string values and buffers to construct command and output strings and read inputs
s" " $value ASTAP.str0      
s" " $value ASTAP.str1
256 buffer: ASTAP.buf0

\ Global values obtained from scanning the ASTAP WCS file
\   finite fraction single integer format, J2000 as read from the FITS file
0 value ASTAP.solved.RA
0 value ASTAP.solved.Dec
0 value ASTAP.reported.RA
0 value ASTAP.reported.Dec
0 value ASTAP.reported.Sidereal
s" " $value ASTAP.reported.Pierside$

\ compute a hash h1 by hashing x1 and h0
\ 	borrowed from simple-tester and used in scanning a .wcs file
: ASTAP.hash ( x1 h0 -- h1)
	31 * swap 13 + xor
;	
	
\ hash a string to a single value on stack
: ASTAP.hash$ ( c-addr u -- h)
	swap 2dup + swap ( u end+1 start)
	?do											\ Let h0 = u
		i c@ ( h_i x) swap ASTAP.hash ( h_j) 	\ j = i + 1
	loop
;

: ASTAP.readWCS ( caddr u  -- IOR)
\ read a WCS file and populate the ForthASTAP globals with the relevant FITS values
    r/o open-file ( file-id IOR ) if exit then >R
	begin
		ASTAP.buf0 dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
	while
		2dup drop 8 ASTAP.hash$ ( c-addr u2 h)
	case
		1035617187  ( "CRVAL1  ") of                
		    drop 10 + 20 >float drop 1.5E1 f/   \ CRVAL1 reports RA in degrees
		    fp~ -> ASTAP.solved.RA    
		endof
		1035616990  ( "CRVAL2  ") of drop 10 + 20 >float drop fp~ -> ASTAP.solved.Dec   endof
		602714565   ( "OBJCTRA ") of drop 10 + 10 >number~ -> ASTAP.reported.RA         endof
		602712226   ( "OBJCTDEC") of drop 10 + 10 >number~ -> ASTAP.reported.Dec        endof  
		-1898806661 ( "SIDEREAL") of drop 10 + 10 >number~ -> ASTAP.reported.Sidereal   endof
		1151949815  ( "PIERSIDE") of drop 10 + 1          $-> ASTAP.reported.Pierside$  endof
	    nip nip 
	endcase
	repeat   
	drop drop
	R> close-file drop 0
;

: ASTAP.readFocus ( addr u -- errlevel focuspos 0 | IOR)
\ read the exitcode.txt file produced by ASTAPFocus.PS1 and report focus position and error level
    r/o open-file ( file-id IOR ) if exit then >R       \ open-file failed
    ASTAP.buf0 dup 256 R> ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
    if isInteger? 1 = 
        if
            10000 /MOD ( errlevel focuspos)
            dup 0= if
                2drop -1 exit       \ ASTAP ran but focus not found
            else
                0 exit              \ ASTAP ran and focus was found
            then
        else 
            -1 exit                 \ the text is not an integer
        then 
    else
        2drop -1 exit               \ file is empty
    then  
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

: ASTAP.formatALPT ( -- caddr u)
\ Take the global plate parameters, convert to JNOW and format the 10u :newaslpt command string ready for execution
    s\" s\" " $-> ASTAP.str0
    ASTAP.reported.RA 10u.~RA$ $+> ASTAP.str0       s" ," $+> ASTAP.str0
    ASTAP.reported.Dec 10u.~Dec$ $+> ASTAP.str0     s" ," $+> ASTAP.str0  
    ASTAP.reported.Pierside$ $+> ASTAP.str0         s" ," $+> ASTAP.str0
    ASTAP.solved.RA 10u.~RA$ $+> ASTAP.str0         s" ," $+> ASTAP.str0
    ASTAP.solved.Dec 10u.~Dec$ $+> ASTAP.str0       s" ," $+> ASTAP.str0   
    ASTAP.reported.Sidereal  10u.~RA$ $+> ASTAP.str0  
    s\" \" 10u.AddAlignmentPoint" $+> ASTAP.str0  
    ASTAP.str0         
;

: ASTAP.WCS-to-ALPT ( caddr1 u1 -- caddr2 u2 0 | IOR)
\ take the WCS file specified by caddr1 u1 and prepare a :newalpt command string
    ASTAP.readWCS ( IOR) if -1 exit then
    ASTAP.formatALPT 0
;

: ASTAP.folder-to-ALPT { caddr1 u1 | fid_I fid_O -- caddr2 u2 0 | IOR }
\ caddr1 u1 specifics a folder containing a WCS-LIST.txt file
\ caddr2 u2 specifics a resultant output file listing 
    caddr1 u1 $-> ASTAP.str0 s" \WCS-LIST.txt" $+> ASTAP.str0
    caddr1 u1 $-> ASTAP.str1 s" \10Umodel.f" $+> ASTAP.str1   
    ASTAP.str0 r/o open-file ( file-id IOR ) if exit then -> fid_I
    ASTAP.str1 delete-file drop
    ASTAP.str1 w/o create-file ( file-id IOR ) if exit then -> fid_O          
	begin
		ASTAP.buf0 dup 256 fid_I ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
	while
		ASTAP.WCS-to-ALPT 0= if fid_O write-line drop then
	repeat   
	2drop
	fid_I close-file drop
	fid_O close-file drop 
	ASTAP.str1 0
;

\ Invoke PowerShell scripts to run ASTAP

: ASTAP.waitForFile ( caddr u -- IOR)
\ Wait for creation of a file and return an IOR
	200 0 do			\ 20 second timeout
		2dup FileExists? if unloop 2drop 0 exit then
		100 ms
	loop
	2drop -1
;

: ASTAP.solveFolder ( caddr u -- IOR)
\ Take a folder path, invoke ASTAP for each .fits image in that folder
\ List the created .wcs files in WCS-LIST.txt
\ Return an IOR = 0 if the process completed successfully (regardless of how many of the images were successfully solved)
    s" pwsh.exe -File E:\coding\ForthASTAP\PowerShell\ASTAPRunFolder.PS1  " $-> ASTAP.str0
    2dup $+> ASTAP.str0
    ASTAP.str0 ShellCmd
    ( caddr u) $-> ASTAP.str1 s" \WCS-LIST.txt" $+> ASTAP.str1
    ASTAP.str1 ASTAP.waitForFile
;

: ASTAP.solveFile ( caddr u -- RA DEC 0  | -1 )
\ Take a filename with fullpath and invoke ASTAP
\ Return an IOR = 0 
    s" pwsh.exe -File E:\coding\ForthASTAP\PowerShell\ASTAPRun.PS1  " $-> ASTAP.str0 
    2dup $+> ASTAP.str0
    ASTAP.str0 ShellCmd
    2dup 4 - ( caddr u') $-> ASTAP.str1 s" ini" $+> ASTAP.str1
    ASTAP.str1 ASTAP.waitForFile if 2drop -1 exit then       \ no ini file was produced
    4 - ( caddr u') $-> ASTAP.str1 s" wcs" $+> ASTAP.str1
    ASTAP.str1 ASTAP.readWCS 0= if
        ASTAP.solved.RA ASTAP.solved.Dec 0
    else -1 then
;

: astap.findfocus ( caddr u -- errlevel focuspos 0 | IOR)
\ Take a folder path, invoke ASTAP to find the focus of the .fits images in that folder
    s" pwsh.exe -File E:\coding\ForthASTAP\PowerShell\ASTAPFocus.PS1  " $-> ASTAP.str0
    2dup $+> ASTAP.str0
    ASTAP.str0 ShellCmd
    ( caddr u) $-> ASTAP.str1 s" \exitcode.txt" $+> ASTAP.str1
    ASTAP.str1 ASTAP.waitForFile if 2drop -1 exit then       \ no exitcode.txt file was produced    
    ASTAP.str1 ASTAP.readFocus 
;

: platesolve ( caddr u -- RA DEC 0  | IOR )
\ Invoke ASTAP Astrometry Stacking Program to plate solve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure       
	ASTAP.solveFile 
;
