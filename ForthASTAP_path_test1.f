\ ASTAP solver FITS path substitution and restoration.

NEED simple-tester
include "%libdir%\ForthAstroFormats\ForthAstroFormats_test_support.f"
NEED ForthASTAP

0 value ASTAP.path-test.frame

: ASTAP.path-test-science { frame suffix-addr suffix-u filepath-buffer -- }
\ Distinct caller policy used to prove ASTAP restores the previous action.
    frame drop
    filepath-buffer reset-buffer
    s" E:\Coding\ForthASTAP\caller-science"
        filepath-buffer write-buffer drop
    suffix-addr suffix-u filepath-buffer write-buffer drop
;

ASSIGN ASTAP.path-test-science TO-DO write-science-filepath
ACTION-OF write-science-filepath constant ASTAP.path-test.saved-action

test.make-frame -> ASTAP.path-test.frame
s" 11111111-2222-3333-4444-555555555555"
    ASTAP.path-test.frame FRAME_METADATA @ =>" UUID"

Tstart
T{ ASTAP.path-test.frame ASTAP.save-temp-FITS }T ==
T{ ASTAP.tempFITSpath buffer-to-string hashS
}T s" E:\images\working\11111111-2222-3333-4444-555555555555\solve.fits" hashS ==
T{ ASTAP.tempFITSpath buffer-to-string FileExists? }T -1 ==
T{ ACTION-OF write-science-filepath ASTAP.path-test.saved-action = }T -1 ==
Tend

ASTAP.tempFITSpath buffer-to-string delete-file drop
ASTAP.path-test.frame free-frame
