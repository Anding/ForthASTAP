\ Integration coverage for known-good ASTAP fixture images.

need ForthASTAP
need simple-tester

4 3 1 allocate-frame constant wcs.image

: ASTAP.fixture-geometry ( caddr u -- width height depth )
    xisf.open-FITSfile abort" Cannot open ASTAP fixture" >R
    R@ XISF.scan-FITSgeometry
    R> close-file drop
;

: ASTAP.fixture-solved? ( caddr u -- flag )
    ASTAP.solveFile dup 0= if
        drop 2drop -1
    else
        drop 0
    then
;

Tstart

T{ s" E:\images\tests\astap\known-good\LUM-E137-F5100-3a99ed69c350.fits"
   ASTAP.fixture-geometry
}T 9576 6388 1 ==
T{ s" E:\images\tests\astap\known-good\LUM-E8-F5100-12365844e78a.fits"
   ASTAP.fixture-solved?
}T -1 ==
T{ s" E:\images\tests\astap\known-good\LUM-E8-F5100-12365844e78a.wcs"
   wcs.image ASTAP.import-WCS
}T ==
T{ s" CRVAL1" wcs.image FRAME_METADATA @ >string nip 0> }T -1 ==
T{ s" CTYPE1" wcs.image FRAME_METADATA @ >string drop 8 hashS }T s" RA---TAN" hashS ==

Tend

wcs.image free-frame
bye
