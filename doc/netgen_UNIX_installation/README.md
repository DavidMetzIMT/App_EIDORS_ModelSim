

# NETGEN 5.3.1 intallation for EIDORS on Ubuntu focal 20.04.3 LTS 
by David Metz


## STEP 1
THANKS TO Alistair Boyle
here the help from the eidors mailinglist archive:
https://sourceforge.net/p/eidors3d/mailman/message/35841071/


Over the years there have been a number of people who have asked for
help compiling and installing Netgen. I had a script or two from years
back that I have, at various times, suggested people use as a starting
point for compiling under linux. It is, generally, not easy to
successfully compile as there are a number of patches and the build
options and dependencies can be a bit tricky to work through. I've
recently gone back through my notes and those build scripts and got
them fully operational again. There are now scripts available in my
dev/a_boyle directory for three versions of netgen: 4.9.13, 5.3.1 and
6.0_beta.

All versions apply necessary patches, compile, install to a designated
location (either local or system wide), and provide a netgen wrapper
which sets necessary environment variables to allow netgen to run
under Matlab/EIDORS. The builds have been tested on Gentoo
(2017-04-25), Ubuntu (16.04) and will most likely work on other
gnu/linux distributions. These are not for Mac or Windows.

https://sourceforge.net/p/eidors3d/code/HEAD/tree/trunk/dev/a_boyle/install-netgen-4.9.13
https://sourceforge.net/p/eidors3d/code/HEAD/tree/trunk/dev/a_boyle/install-netgen-5.3.1
https://sourceforge.net/p/eidors3d/code/HEAD/tree/trunk/dev/a_boyle/install-netgen-6.0-beta

Note that under ubuntu, you need dependencies:
$ sudo apt install libxmu-dev mesa-common-dev libglu1-mesa-dev libx11-dev

If you happen to be using Gentoo, there is an ebuild which automates
the build and installs into the system; these are the builds that I
use (and maintain) in production.

https://github.com/boyle/boyle-portage-tree/tree/master/sci-mathematics/netgen

The 4.9.13 version of netgen will crash when it is executed due to a
buffer overflow that is detected by modern compilers when meshing
simple geometries. Versions 5.3.1 and 6.0_beta seem to work correctly
for me.

Good luck!
Alistair Boyle
https://aboyle.ca
University of Ottawa, Canada


## STEP 2
I downloaded the script:
https://sourceforge.net/p/eidors3d/code/HEAD/tree/trunk/dev/a_boyle/install-netgen-5.3.1

## STEP 3
I changed the script which as some errors appear

> see install-netgen-5.3.1 vs install-netgen-5.3.1_original and ERRORS descrition in following

## STEP 4
Put the script in ~, and run it 
```
cd ~ 
sh install-netgen-5.3.1
```

## STEP 5
Correct the PATH issues 
add in ~/.profile or ~/.bash_profile
```
# set PATH so it includes NETGEN
if [ -d "$HOME/netgen-5.3.1/bin" ] ; then
	NETGENDIR= "$HOME/netgen-5.3.1/bin"
	LD_LIBRARY_PATH="$HOME/netgen-5.3.1/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
	PATH="$HOME/netgen-5.3.1/bin${PATH:+:${PATH}}"
fi
```	

Refresh ~/.profile, using 
```
source ~/.profile
```

## ERRORS
### #1
```
SRCDIR=/home/ml86/netgen-5.3.1_original-src   INSTDIR=/home/ml86/netgen-5.3.1_original
install-netgen-5.3.1_original: 33: Syntax error: "(" unexpected
```

Solution:
> comment the funtion err()...
```
#function err() {
#  echo "$(basename $0) ERROR: $1"
#  return
# exit 1
#}
```


### #2
```
patching file libsrc/occ/occgeom.hpp
Hunk #1 FAILED at 385 (different line endings).
1 out of 1 hunk FAILED -- saving rejects to file libsrc/occ/occgeom.hpp.rej
patching file libsrc/occ/occgeom.cpp
Hunk #1 FAILED at 1033 (different line endings).
Hunk #2 FAILED at 1045 (different line endings).
2 out of 2 hunks FAILED -- saving rejects to file libsrc/occ/occgeom.cpp.rej
```


Solution:
> comment the patching netgen-5.3-opencascade.patch
```
cat > netgen-5.3-opencascade.patch << EOF
# --- /libsrc/occ/occgeom.hpp	2017-02-09 01:34:38.172433886 -0500
# +++ /libsrc/occ/occgeom.hpp	2017-02-09 01:34:45.283479486 -0500
# @@ -385,7 +385,7 @@
#        void GetNotDrawableFaces (stringstream & str);
#        bool ErrorInSurfaceMeshing ();
 
# -     void WriteOCC_STL(char * filename);
# +//     void WriteOCC_STL(char * filename);
 
#       virtual int GenerateMesh (Mesh*& mesh, MeshingParameters & mparam, 
#           int perfstepsstart, int perfstepsend);
# --- /libsrc/occ/occgeom.cpp	2017-02-09 01:34:58.975567262 -0500
# +++ /libsrc/occ/occgeom.cpp	2017-02-09 01:35:15.709674497 -0500
# @@ -1033,7 +1033,7 @@
 
 
 
# -
# +#if 0
#     void OCCGeometry :: WriteOCC_STL(char * filename)
#     {
#        cout << "writing stl..."; cout.flush();
# @@ -1045,7 +1045,7 @@
 
#        cout << "done" << endl;
#     }
# -
# +#endif
 
 
#     // Philippose - 23/02/2009
# EOF
# patch -p1 < netgen-5.3-opencascade.patch
```











