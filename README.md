# ForthASTAP

Forth integration for the [ASTAP](https://www.hnsky.org/astap.htm)
astrometric solver and autofocus support.

## Prerequisites

- `astap.exe` must be available on `PATH`.
- PowerShell (`pwsh.exe`) must be available.
- The bundled PowerShell scripts are invoked from
  `E:\coding\ForthASTAP\PowerShell`.
- `ForthXISF` provides FITS creation, FITS-card parsing, and the shared image
  context used by the solver.

## Compile-time selection

ASTAP is the default solver in AstroImagingInForth. In a fresh VFXterm
session, load:

```forth
include scripts\AstroImagingInForth.f
```

The integration script loads ForthASTAP when `solve-image` has not already
been defined. To select ForthSeiza instead, restart VFXterm and load
ForthSeiza before the integration script; see the ForthSeiza README. Selection
is compile-time, so do not load both solver packages in one VFX session.

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
E:\images\working\<UUID>\solve.fits
```

and invokes ASTAP on that file.

| Result | `solved?` | Context-map updates |
| --- | --- | --- |
| Solved | `0` | `SOLVER=ASTAP`, `SOLVSTAT=SOLVED`, imported WCS cards, `10UALPT` |
| Not solved | non-zero | `SOLVSTAT=FAILED` |

The caller owns the policy for a failed solve. AstroImagingInForth preserves
and saves science XISF/FITS output on failure; it writes no WCS sidecar. On
success, `10UALPT` is the formatted command passed directly to
`add-alignment-point` by the live mount-model script.

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

`ForthASTAP_fixture_test1.f` uses verified real FITS fixtures beneath:

```text
E:\images\tests\astap\known-good
```

It checks a stable image-size baseline, ASTAP success, WCS import, and
imported `CRVAL1`/`CTYPE1` keys. It is an external integration test and needs
a bounded timeout; the fast ForthXISF regressions remain separate.
