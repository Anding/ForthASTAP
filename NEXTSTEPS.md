## Next steps for ForthASTAP

### Testing

1. Test command line plate-solve with actual images

2. Test command-line focus finding with actual images

### Develop a system to create 10Micron model points

Hypothesis: 

1. Separate image acquistion with model point extraction

2. A script in AstroImagingInForth will produce a folder of .fits images or .wcs files

2. Use a PS1 script to scan the folder for .fist and provide a list of filenames in a text file

3. Iterate over the text file and produce a mixed data/code .f file that is executable in Forth, with clear-text data in comments

Processing .wcs files might be better since no-solution images can be repeated or substituted during acquisition
