need ForthASTAPFocus
need finiteFractions
need forth-map   
need astrocalc
need ForthAstroFormats
    
FILEPATH_SIZE allocate-buffer constant ASTAP.tempFITSpath

\ Global values obtained from scanning the ASTAP WCS file
\   finite fraction single integer format, J2000 as read from the FITS file
0 value ASTAP.solved.RA
0 value ASTAP.solved.Dec
0 value ASTAP.reported.RA
0 value ASTAP.reported.Dec
0 value ASTAP.reported.Sidereal
0 value ASTAP.reported.NightOf
s" " $value ASTAP.reported.Pierside$

: ASTAP.readWCS ( caddr u  -- IOR)
\ read a WCS file and populate the ForthASTAP globals with the relevant FITS values
    r/o open-file ( file-id IOR ) if exit then >R
	begin
		ASTAP.buf0 dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
	while
		2dup drop 8 hash$ ( c-addr u2 h)
	case
		1035617187  ( "CRVAL1  ") of                
		    drop 10 + 20 >float drop 1.5E1 f/   \ CRVAL1 reports RA in degrees
		    fp~ -> ASTAP.solved.RA    
		endof
		1035616990  ( "CRVAL2  ") of drop 10 + 20 >float drop fp~ -> ASTAP.solved.Dec   endof
		602714565   ( "OBJCTRA ") of drop 11 + 10 >number~ -> ASTAP.reported.RA         endof
		602712226   ( "OBJCTDEC") of drop 11 + 10 >number~ -> ASTAP.reported.Dec        endof  
		-1898806661 ( "SIDEREAL") of drop 11 + 10 >number~ -> ASTAP.reported.Sidereal   endof
		1151949815  ( "PIERSIDE") of drop 11 + 1          $-> ASTAP.reported.Pierside$  endof
		300196965   ( "NIGHTOF ") of drop 10 + 12 >number~ -> ASTAP.reported.NightOf    endof
	    nip nip 
	endcase
	repeat   
	drop drop
	R> close-file drop 0
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
\ Take the global plate parameters and format the 10u :newaslpt command string ready for execution
\ reported coordinates and solved coordinates are converted from JNOW to J2000
    s\" s\" " $-> ASTAP.str0
    ASTAP.reported.RA ASTAP.reported.Dec ASTAP.reported.NightOf JNOW ( RA_JNOQ Dec_JNOW) swap
    10u.~RA$ $+> ASTAP.str0                         s" ," $+> ASTAP.str0   
    10u.~Dec$ $+> ASTAP.str0                        s" ," $+> ASTAP.str0      
    ASTAP.reported.Pierside$ $+> ASTAP.str0         s" ," $+> ASTAP.str0
    ASTAP.solved.RA ASTAP.solved.Dec ASTAP.reported.NightOf JNOW ( RA_JNOQ Dec_JNOW) swap
    10u.~RA$ $+> ASTAP.str0                         s" ," $+> ASTAP.str0
    10u.~Dec$ $+> ASTAP.str0                        s" ," $+> ASTAP.str0   
    ASTAP.reported.Sidereal  10u.~RA$ $+> ASTAP.str0  
    s\" \" add-alignment-point" $+> ASTAP.str0  
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
    caddr1 u1 + 1- c@ '\' = if u1 1- -> u1 then   \ remove any trailing '\'
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

: ASTAP.solveFolder ( caddr u -- IOR)
\ Take a folder path, invoke ASTAP for each .fits image in that folder
\ List the created .wcs files in WCS-LIST.txt
\ Return an IOR = 0 if the process completed successfully (regardless of how many of the images were successfully solved)
    s" pwsh.exe -File E:\coding\ForthASTAP\PowerShell\ASTAPRunFolder.PS1  " $-> ASTAP.str0
    2dup $+> ASTAP.str0
    ASTAP.str0 ShellCmd
    ( caddr u) $-> ASTAP.str1 s" \WCS-LIST.txt" $+> ASTAP.str1
    ASTAP.str1 180 ASTAP.waitForFile
;

: ASTAP.solveFile ( caddr u -- RA DEC 0  | -1 )
\ Take a filename with fullpath and invoke ASTAP
\ Return an IOR = 0 
    s" pwsh.exe -File E:\coding\ForthASTAP\PowerShell\ASTAPRun.PS1  " $-> ASTAP.str0 
    2dup $+> ASTAP.str0
    ASTAP.str0 ShellCmd
    2dup 4 - ( caddr u') $-> ASTAP.str1 s" ini" $+> ASTAP.str1
    ASTAP.str1 45 ASTAP.waitForFile if -1 exit then       \ no ini file was produced
    4 - ( caddr u') $-> ASTAP.str1 s" wcs" $+> ASTAP.str1
    ASTAP.str1 45 ASTAP.waitForFile if -1 exit then       \ no WCS file was produced
    ASTAP.str1 ASTAP.readWCS 0= if
        ASTAP.solved.RA ASTAP.solved.Dec 0
    else -1 then
;

: ASTAP.wcs-filepath ( caddr u -- caddr u)
\ replace the .fits extension with .wcs
    4 - $-> ASTAP.str1
    s" wcs" $+> ASTAP.str1
    ASTAP.str1
;

: ASTAP.temp-FITSfilepath { img | filepath-buffer -- filepath-buffer }
\ create a per-image temporary solver filepath in the configured working root
    ASTAP.tempFITSpath -> filepath-buffer
    filepath-buffer reset-buffer
    s" E:\images\working\" filepath-buffer write-buffer drop
    s" UUID" img FRAME_METADATA @ >string filepath-buffer write-buffer drop
    '\' filepath-buffer echo-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" solve.fits" filepath-buffer write-buffer drop
    filepath-buffer
;

 : ASTAP.import-WCS { caddr u img | map fileid -- }
\ merge all ordinary WCS FITS cards into the image context's ordered map
    img FRAME_METADATA @ -> map
    caddr u r/o open-file abort" Cannot open ASTAP WCS file" -> fileid
    begin
        ASTAP.buf0 255 fileid read-line abort" Cannot read ASTAP WCS file"
    while
        ASTAP.buf0 swap FITS.read-line
        dup 0= if
            drop map =>
        else
            drop
        then
    repeat
    drop
    fileid close-file abort" Cannot close ASTAP WCS file"
;

: ASTAP.solve-image { img | filepath-buffer -- solved? }
\ solve an image context and append successful solution data to its FITS map
    img ASTAP.temp-FITSfilepath -> filepath-buffer
    img filepath-buffer save-FITSimage-to
    filepath-buffer buffer-to-string ASTAP.solveFile
    dup 0= if
        drop 2drop
        filepath-buffer buffer-to-string ASTAP.wcs-filepath img ASTAP.import-WCS
        s" ASTAP" img FRAME_METADATA @ =>" SOLVER"
        s" SOLVED" img FRAME_METADATA @ =>" SOLVSTAT"
        ASTAP.formatALPT img FRAME_METADATA @ =>" 10UALPT"
        0
    else
        drop
        s" FAILED" img FRAME_METADATA @ =>" SOLVSTAT"
        -1
    then
;

DEFER solve-image ( img -- solved? )
ASSIGN ASTAP.solve-image TO-DO solve-image

: platesolve ( caddr u -- RA DEC 0  | IOR )
\ Invoke ASTAP Astrometry Stacking Program to plate solve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure       
	ASTAP.solveFile 
;
