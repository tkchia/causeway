Attempt to update Devore's CauseWay DOS extender for modern build systems, and to improve on it.

To build:
 1. &nbsp;`sudo apt-get install dosbox`
 1. &nbsp;`make -j4`

(**FIXME**: figure out to rebuild the intermediate file `cw.lib` from sources.)

The source code for CauseWay v3.60 (`source/`, `misc/`, `bin/`) was originally found under the [Open Watcom source tree](https://github.com/open-watcom/open-watcom-v2).  In addition, `watcom/mkcode.c`, `watcom/cwc.c`, and `watcom/*.h` comprise Watcom's rewrite of the CauseWay Compressor, and came from the same Watcom source tree.

Andrew Jones also hosts a copy of (a slightly older) [CauseWay v3.52](https://github.com/amindlost/cw).
