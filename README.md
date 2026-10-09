# ForthASTAP

Forth integration for the [ASTAP](https://www.hnsky.org/astap.htm)
autofocus and optional astrometric solver.

The capabilities are deliberately separate:

| Package | Purpose | Defines `solve-image` |
|---|---|---|
| `ForthASTAPFocus` | `astap.findfocus` and shared subprocess helpers | No |
| `ForthASTAP` | Complete ASTAP astrometry plus autofocus | Yes |

## Prerequisites

- `astap.exe` must be available on `PATH`.
- PowerShell (`pwsh.exe`) must be available.
- The bundled PowerShell scripts are invoked from
  `E:\coding\ForthASTAP\PowerShell`.
- `ForthAstroFormats` provides the format-neutral frame, FITS creation, and
  FITS-card parsing used by the solver. It does not load XISF or image loaders.

## Autofocus

AstroImagingInForth loads the focus-only capability in ordinary sessions:

```forth
NEED ForthASTAPFocus
```

This supplies:

```forth
astap.findfocus ( caddr u -- errlevel focuspos 0 | IOR )
```

without loading frame/FITS code or changing the selected imaging solver.

## Optional ASTAP solver selection

Seiza is the AstroImagingInForth default. To use ASTAP for astrometry in a
fresh VFXterm session, load the complete package before the integration:

```forth
NEED ForthASTAP
include scripts\HomeObservatory.f
```

The existing `solve-image` definition prevents the integration from loading
Seiza. Solver selection remains compile-time.

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

The save temporarily assigns ASTAP's private pathname builder to
`write-science-filepath`, then restores the previous default or user action
before returning. Restoration also occurs when FITS writing throws, so solver
work cannot redirect subsequent science XISF/FITS payloads.

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

`ForthASTAPFocus_dependency_test1.f` verifies that the autofocus package
provides focus parsing without loading frame formats or defining
`solve-image`.

`ForthASTAP_fixture_test1.f` uses verified real FITS fixtures beneath:

```text
E:\images\tests\astap\known-good
```

It checks a stable image-size baseline, ASTAP success, WCS import, and
imported `CRVAL1`/`CTYPE1` keys. It is an external integration test and needs
a bounded timeout; the fast ForthXISF regressions remain separate.
