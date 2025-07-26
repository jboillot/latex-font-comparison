# LaTeX Font Comparison Viewer

This project provides a simple, browser-based tool for comparing how a LaTeX document renders with different fonts, side-by-side. It uses [pdf.js](https://mozilla.github.io/pdf.js/) to display PDFs in the browser and [SyncTeX](https://itexmac.sourceforge.net/SyncTeX.html) to enable synchronized scrolling between views.

## How to use

### Regenerate the PDF and map files

To regenerate all auxiliary files (PDFs and scroll maps):

```
make clean && make -j8
```

### Add support for additional fonts

1. Edit [fonts.json](fonts.json) to add a new entry.
2. Each entry must include a command field with the LaTeX font selection code (as a one-liner).
3. Then run:
```
make -j8
```

### Render a different LaTeX document

1. Edit the first few constants in the [Makefile](Makefile) to specify your `.tex` file and line range (the first and last lines of the `document` environment in your LaTeX file).
2. Make sure the document contains `\usepackage{amsmath,amsthm}` — the font selection line will be inserted immediately after that. Also, all occurrences of `P_\X` will be replaced with `P_{\X}` by default. You can change those behaviors in the [Makefile](Makefile).
4. Then run:
```
make clean && make -j8
```

## Dependencies (to re-generate the PDF and map files)
- LuaLaTex
- latexmk
- jq
- SyncTeX
- awk and sed

## License

This project is licensed under the [MIT license](LICENSE.md).

However, it includes the file [testmath.tex](testmath.tex) which is provided by the [American Mathematical Society](https://www.ams.org/) as part of AMS-LaTeX.
That file is licensed under the [LaTeX Project Public License v1.3c](https://www.latex-project.org/lppl/lppl-1-3c/).
