\ ASTAP process adapter for the shared solve-image contract. ASTAP-specific
\ solved coordinates remain here; WCS import and alignment metadata are shared.

need ForthASTAPFocus
need ForthAstroSolver
need ForthAstroPaths
    
FILEPATH_SIZE allocate-buffer constant ASTAP.tempFITSpath

\ Global values obtained from scanning the ASTAP WCS file
\   finite fraction single integer format, J2000 as read from the FITS file
0 value ASTAP.solved.RA
0 value ASTAP.solved.Dec

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
	    nip nip 
	endcase
	repeat   
	drop drop
	R> close-file drop 0
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

: ASTAP.write-temp-FITSfilepath
    { img suffix-addr suffix-u filepath-buffer -- }
\ Build the pathname stem for ASTAP's private solver image.
    filepath-buffer reset-buffer
    astro.root filepath-buffer write-buffer drop
    s" working" filepath-buffer append-path
    '\' filepath-buffer echo-buffer drop
    s" UUID" img FRAME_METADATA @ >string filepath-buffer write-buffer drop
    '\' filepath-buffer echo-buffer drop
    filepath-buffer buffer-punctuate-filepath
    s" solve" filepath-buffer write-buffer drop
    suffix-addr suffix-u filepath-buffer write-buffer
        abort" ASTAP filepath buffer full"
;

: ASTAP.save-temp-FITS { img | saved-path ior -- }
\ Temporarily replace FITS pathname policy while writing the solver image.
    ACTION-OF write-filepath-fits -> saved-path
    ASSIGN ASTAP.write-temp-FITSfilepath TO-DO write-filepath-fits
    img ASTAP.tempFITSpath ['] save-FITSframe-to catch -> ior
    saved-path TO-DO write-filepath-fits
    ior ?dup if throw then
;

: ASTAP.solve-image { img -- solved? }
\ Save through private path policy, solve, and append solution data to the map.
    img ASTAP.save-temp-FITS
    ASTAP.tempFITSpath buffer-to-string ASTAP.solveFile
    dup 0= if
        drop 2drop
        ASTAP.tempFITSpath buffer-to-string ASTAP.wcs-filepath
            img solver.import-WCS
        s" ASTAP" img FRAME_METADATA @ =>" SOLVER"
        s" SOLVED" img FRAME_METADATA @ =>" SOLVSTAT"
        0
    else
        drop
        s" FAILED" img FRAME_METADATA @ =>" SOLVSTAT"
        -1
    then
;

ASSIGN ASTAP.solve-image TO-DO solve-image

: platesolve ( caddr u -- RA DEC 0  | IOR )
\ Invoke ASTAP Astrometry Stacking Program to plate solve an image
\ 	take the full file path of the image 
\ 	return the RA and DEC as single integer finite fractions or an IOR on failure       
	ASTAP.solveFile 
;
