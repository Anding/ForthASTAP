# ForthASTAP

Forth integration for the [ASTAP](https://www.hnsky.org/astap.htm)
autofocus and optional astrometric solver.

`NEED ForthASTAP` loads the complete repository: ASTAP astrometry, autofocus
and shared subprocess helpers. There is no separate focus-only loader.
AstroImagingInForth uses Seiza and does not load this package.

## Prerequisites

- `astap.exe` must be available on `PATH`.
- PowerShell (`pwsh.exe`) must be available.
- The bundled PowerShell scripts are invoked from
  `E:\coding\ForthASTAP\PowerShell`.
- `ForthAstroFormats` provides the format-neutral frame, FITS creation, and
  FITS-card parsing used by the solver, along with its other format tools.

## Autofocus

In a standalone ASTAP session:

```forth
NEED ForthASTAP
```

This supplies:

```forth
astap.findfocus ( caddr u -- errlevel focuspos 0 | IOR )
```

Loading the package also selects ASTAP's `solve-image` implementation.

## Optional ASTAP solver selection

For standalone ASTAP astrometry, load the complete package:

```forth
NEED ForthASTAP
```

AstroImagingInForth loads Seiza directly; preloading ASTAP is not an
application solver-selection mechanism.

## Context solver contract

`solve-image` is a deferred word with the default assignment:

```forth
ASTAP.solve-image TO-DO solve-image
```

Its stack effect is:

```forth
( img -- solved? )
```

It saves a temporary FITS image at:

```text
<astro.root>\working\<UUID>\solve.fits
```

and invokes ASTAP on that file.

The save executes ASTAP's private filename creator without changing
`write-filepath-fits`. Ordinary FITS failures report the error and clear the
temporary path, so solving is skipped and later science destinations are unchanged.

| Result | `solved?` | Context-map updates |
| --- | --- | --- |
| Solved | `0` | `SOLVER=ASTAP`, `SOLVSTAT=SOLVED`, imported WCS cards, `10UALPT` |
| Not solved | non-zero | `SOLVSTAT=FAILED` |

The caller owns the policy for a failed solve. AstroImagingInForth preserves
and saves science XISF/FITS output on failure; it writes no WCS sidecar. On
success, `10UALPT` contains comma-separated 10Micron alignment data, not Forth
source. The live mount-model script passes it directly to `add-alignment-point`.
ASTAP calls `solver.solved-metadata` after importing a successful solution;
AstroImagingInForth binds this to generate `10UALPT` for every successful
frame solve, not just model building.

## WCS import

```forth
ASTAP.import-WCS ( caddr u img -- )
```

Imports ordinary FITS cards from an ASTAP `.wcs` file into `img FITS_MAP`.
ASTAP emits CRLF-terminated 80-character cards, so this importer reads
complete lines before using `XISF.read-FITSline`. It has no stack result; its
observable result is the augmented ordered FITS map.

`ASTAP.solveFile` remains useful for direct file solving:

```forth
( caddr u -- RA DEC 0 | -1 )
```

## Tests

`ForthASTAPFocus_dependency_test1.f` verifies that the single package loads
focus parsing, frame formats and the ASTAP `solve-image` implementation together.

`ForthASTAP_fixture_test1.f` uses verified real FITS fixtures beneath:

```text
E:\images\tests\astap\known-good
```

It checks a stable image-size baseline, ASTAP success, WCS import, and
imported `CRVAL1`/`CTYPE1` keys. It is an external integration test and needs
a bounded timeout; the fast ForthAstroFormats regressions remain separate.
