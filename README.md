# Indentation Analysis
This is a package of functions for making strain rate jump load functions for the Bruker Hysitron TI980. For compatibility purposes: The load function generator is written in Python 3.7.6; the analysis functions are written in Matlab 2020.

An article regarding these functions has been published in Experimental Mechanics: https://doi.org/10.1007/s11340-022-00833-x. It provides information regarding the validation of these tools on single crystal tungsten. A more thorough usage of these tools, applied to microcrystalline cellulose, can be found in our earlier paper in the Journal of Materials Research: https://doi.org/10.1557/s43578-021-00138-0.

Most of this is well tested. Some portions, particularly those related to spherical indentation ldf generation, are still being tested. If you encounter any errors or issues, please contact me! My goal is to release a bug-free set of code. There are likely edge cases which I have not considered which may cause errors. If you find any, let me know, and I'll be happy to put out a fix. There is also a separate branch ('Experimental') that incorporates additional features.

For information on input parameters and how to use the software, please see the "Using the Software" pdf. A lot of the sections for reading data are specific to my proprietary format which may not be the same as the text format exported from TriboScan. Some editing of the data reading sections will thus need to be edited to read from the appropriate fields (such as in the NixGao-related functions). If there is anything unclear after reading the "Using the Software" pdf, please contact me (schma174@umn.edu) and I'll be happy to assist however I can.

In theory, much of this code could be adapted for non-Bruker/Hysitron systems. If you are interested in doing so, let me know!
