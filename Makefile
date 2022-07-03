#	Permission is hereby granted, free of charge, to any person
#	obtaining a copy of this software and associated documentation files
#	(the "Software"), to deal in the Software without restriction,
#	including without limitation the rights to use, copy, modify, merge,
#	publish, distribute, sublicense, and/or sell copies of the Software,
#	and to permit persons to whom the Software is furnished to do so,
#	subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be
#	included in all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#	NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
#	BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
#	ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.

# Makefile for GNU make + JWasm to cross-assemble the CauseWay DOS extender
# with default configuration settings, on a Un*x system.  -- tkchia

CFLAGS = -O2 -Wall
INSTALL = install -c
prefix ?= /usr
exec_prefix = $(prefix)/i386-pc-msdos
bindir = $(exec_prefix)/bin
exec_prefix2 = $(prefix)/ia16-elf
bindir2 = $(exec_prefix2)/bin

CWMAIN = source/all/cw32.asm
CWSRCS = $(CWMAIN) source/all/raw_vcpi.asm source/all/interrup.asm \
	 source/all/ldt.asm source/all/memory.asm source/all/api.asm \
	 source/all/int10h.asm source/all/int21h.asm source/all/int33h.asm \
	 source/all/decode_c.asm source/all/exceptn.asm \
	 source/all/loadle/loadle.asm \
	 source/all/strucs.inc source/all/cw.inc
CWDEPS = $(CWSRCS)

CWCDEPS =

CWLMAIN	= source/all/cwl/cwl.asm
CWLOBJ	= $(CWLMAIN:.asm=.o)
CWLSRCS	= $(CWLMAIN) source/all/cwl/cwl.inc
CWLDEPS	= $(CWLSRCS)

CWDMAIN	= source/all/cwd/cwd.asm
CWDSRCS	= $(CWDMAIN) source/all/cwd/equates.asm source/all/cwd/macros.asm \
	  source/all/strucs.inc
CWDDEPS	= $(CWDSRCS)

CWDVMAIN = source/all/cwd/cwd-ovl.asm
CWDVOBJ  = $(CWDVMAIN:.asm=.o)
CWDVSRCS = $(CWDVMAIN) source/all/cwd/macros.inc source/all/cw.inc \
	   source/all/strucs.inc source/all/cwd/disas.inc \
	   source/all/cwd/generr.asm source/all/cwd/files.asm \
	   source/all/cwd/print.asm source/all/cwd/getkeys.asm \
	   source/all/cwd/win.asm source/all/cwd/evaluate.asm \
	   source/all/cwd/disas.asm source/all/cwd/fpu.asm
CWDVDEPS = $(CWDVSRCS)

# If we already have JWasm &/or the Watcom Linker (wlink) &/or JWlink
# installed, use those.  Otherwise, download & build JWasm & JWlink.
# JWlink is used for bootstrapping the CauseWay Linker (TODO).
GIT = git
ifneq "" "$(shell jwasm '-?' 2>/dev/null)"
    ASM = jwasm
else
    ASM = ./jwasm
    CWDEPS += $(ASM)
    CWCDEPS += $(ASM)
    CWLDEPS += $(ASM)
    CWDDEPS += $(ASM)
    CWDVDEPS += $(ASM)
endif
ifneq "" "$(shell wlink '-?' 2>/dev/null </dev/null)"
    LINK = wlink
else
ifneq "" "$(shell jwlink '-?' 2>/dev/null </dev/null)"
    LINK = jwlink
else
    LINK = ./jwlink
    CWLDEPS += $(LINK)
endif
endif
RM = rm -f

# If dosemu is installed, then use it to run CauseWay programs.  (Assume
# dosemu version >= 2.)  Otherwise, use dosbox.
#
# In the future it might be useful to have some sort of loader that can
# directly launch protected mode code from U*ix systems.
ifneq "" "$(shell dosemu --version)"
    run-dos = TERM=vt220 dosemu -td -K . -E "$1"
else
    run-dos = TERM=vt220 dosbox -c 'mount c .' -c 'c:' -c "$1" -c exit \
				>/dev/null
endif
comma = ,
# dosbox creates files with upper-case file names.  Work around this by
# first creating empty target files with the correct case before linking. :-|
define cw-link
	: >"$4"
	: >"$5"
	$(call run-dos,$(subst /,\\,$1) $2 \
		       $(subst /,\\,$3$(comma)$4$(comma)$5))
	test -s "$4" || ($(RM) "$4" "$5" && exit 1)
endef
define cw-compress
	cp "$3" "$4"
	$(call run-dos,$(subst /,\\,$1) $2 $(subst /,\\,$4))
	# Ugh.  Under dosbox, we get CWC.EXE & CWD.OVL instead of cwc.exe &
	# cwd.ovl.  dosemu is OK though.
	if test -f $4; \
	then	:; \
	else	u="`export LC_ALL=C && echo $4 | tr a-z A-Z`"; \
		mv "$$u" $4; \
	fi
	test -s "$4" -a "`LC_ALL=C wc -c <$4`" -lt "`LC_ALL=C wc -c <$3`" || \
	    ($(RM) "$4" && exit 1)
endef

# Various phony targets.

default: cwc-wat cwstub.exe cwl.exe cwd.exe cwd.ovl
.PHONY: default

install: cwc-wat cwstub.exe cwl.exe cwd.exe cwd.ovl
	$(INSTALL) -d $(DESTDIR)$(bindir) $(DESTDIR)$(bindir2)
	$(INSTALL) $^ $(DESTDIR)$(bindir)
	$(RM) -r $(^:%=$(DESTDIR)$(bindir2)/%)
	ln -s -r $(^:%=$(DESTDIR)$(bindir)/%) $(DESTDIR)$(bindir2) || \
	    $(INSTALL) $^ $(DESTDIR)$(bindir2)
.PHONY: install

clean: mostlyclean
	$(RM) -r JWasm.build JWlink.build jwasm jwlink 
.PHONY: clean

mostlyclean:
	$(RM) -r *.o *.obj *.exe *.com *.ovl *.gh *.map *.sym *.lst *.err \
		 *.tmp mkcode cwc-wat copystub.inc decstub.inc *~ \
		 source/all/*~ source/all/*/*.o source/all/*/*~
.PHONY: mostlyclean

# Various pattern rules.

%.o: %.asm
	$(ASM) -DENGLISH=1 -DCONTRIB=1 -Fo$@.tmp -Fl$(@:.o=.lst) $<
	mv $@.tmp $@
.PRECIOUS: %.o

%.gh: %.com mkcode
	./mkcode -b $< $@.tmp
	mv $@.tmp $@
.PRECIOUS: %.gh

%.inc: %.gh
	sed 's/0x\(..\),/0\1h,/g; s/^/db /; s/,$$//' $< >$@.tmp
	mv $@.tmp $@
.PRECIOUS: %.inc

%.com: source/all/cwc/%.asm $(CWCDEPS)
	$(ASM) -bin -DENGLISH=1 -DCONTRIB=1 -Fo$@.tmp -Fl$(@:.com=.lst) $<
	mv $@.tmp $@
.PRECIOUS: %.com

# Rule to build an uncompressed CauseWay loader stub.
cw32.exe: $(CWDEPS)
	$(ASM) -mz -DENGLISH=1 -DCONTRIB=1 -Fo$@.tmp -Fl$(@:.exe=.lst) \
	    $(CWMAIN)
	mv $@.tmp $@
.PRECIOUS: cw32.exe

# Rule to build a compressed CauseWay loader stub.
#
# To compress the loader stub, use Watcom's cwc.c, rather than CauseWay's
# original source/all/cwc/cwc.asm .  The former is written in C and thus is
# usable even on a non-MS-DOS build machine.
cwstub.exe: cw32.exe cwc-wat
	./cwc-wat $< $@.tmp
	mv $@.tmp $@
.PRECIOUS: cwstub.exe

# Rules to build the CauseWay linker.  Use JWlink or wlink to build a
# stage-1 linker (cwl-pre.exe) which will contain a Linear Executable (LE)
# payload, then use that to build the final linker which wil contain a 3P
# payload.
cwl.exe: cwl-pre.exe $(CWLOBJ)
	$(call cw-link,$<,/flat,$(CWLOBJ),$@,$(@:.exe=.map))
.PRECIOUS: cwl.exe

cwl-pre.exe: $(CWLOBJ) cwstub.exe
	$(LINK) format os2 le op stub=cwstub.exe file $< name $@.tmp
	mv $@.tmp $@
.PRECIOUS: cwl-pre.exe

$(CWLOBJ): $(CWLMAIN) $(CWLDEPS)

# Rules to build Watcom's rewrite of the CauseWay Compressor.  This is
# apparently only useful for compressing the stub.
cwc-wat: watcom/cwc.c copystub.gh decstub.gh \
    watcom/watcom.h watcom/bool.h watcom/exedos.h watcom/pushpck1.h \
    watcom/poppck.h
	$(CC) $(CPPFLAGS) -Iwatcom -I. $(CFLAGS) $(LDFLAGS) $< -o $@ $(LDLIBS)
.PRECIOUS: cwc

mkcode: watcom/mkcode.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $< -o $@ $(LDLIBS)
.PRECIOUS: mkcode

# Rules to build Michael Devore's original CauseWay Compressor.  This can
# compress the 3P payload & has a number of other features not in Watcom's
# compressor.
cwc.exe: cwc-pre.exe
	$(call cw-compress,cwc-pre.exe,/l245,cwc-pre.exe,cwc.exe)
.PRECIOUS: cwc.exe

cwc-pre.exe: source/all/cwc/cwc.o cw.lib cwl.exe
	$(call cw-link,cwl.exe,/flat,$<,$@,$(@:.exe=.map))
.PRECIOUS: cwc-pre.exe

source/all/cwc/cwc.o: source/all/cwc/cwc.asm copystub.inc decstub.inc

# Rules to build the CauseWay debugger driver executable.
cwd.exe: $(CWDDEPS)
	$(ASM) -mz -DENGLISH=1 -DCONTRIB=1 -Fo$@.tmp -Fl$(@:.exe=.lst) \
	    $(CWDMAIN)
	mv $@.tmp $@
.PRECIOUS: cwd.exe

# Rules to build the CauseWay debugger overlay file.
cwd.ovl: cwd-pre.ovl cwc.exe
	$(call cw-compress,cwc.exe,/l245,$<,$@)
.PRECIOUS: cwd.ovl

cwd-pre.ovl: $(CWDVOBJ) cwl.exe
	$(call cw-link,cwl.exe,,$<,$@,$(@:.ovl=.map))
.PRECIOUS: cwd.ovl

$(CWDVOBJ): $(CWDVDEPS)

# FIXME: figure out how to build this from sources!  Besides JWasm, we
# probably need a library manager along the lines of Watcom wlib.
cw.lib: source/all/cwlib/cw.lib
	cp $< $@.tmp
	mv $@.tmp $@

# Rule to build JWasm.
./jwasm:
	$(RM) -r JWasm.build
	$(GIT) submodule update --init JWasm.src
	cp -a JWasm.src JWasm.build
	mkdir -p JWasm.build/build/GccUnixR
	$(MAKE) -C JWasm.build -f GccUnix.mak
	cp JWasm.build/build/GccUnixR/jwasm $@.tmp
	mv $@.tmp $@
.PRECIOUS: ./jwasm

# Rules to build JWlink.  JWlink currently only works properly if long is
# 32-bit & pointers are at most 32 bits...
./jwlink : export CC := $(CC) -O2 -static $(shell \
	if (echo '#ifdef __LP64__'; echo '#error'; echo '#endif') | \
	    $(CC) -E -dM -x c - -o /dev/null >/dev/null 2>/dev/null; \
		then :; \
		else echo ' -m32'; \
	fi)

./jwlink:
	$(RM) -r JWlink.build
	$(GIT) submodule update --init JWlink.src
	cp -a JWlink.src JWlink.build
	$(MAKE) -C JWlink.build/dwarf/dw -f GccUnix.mak
	$(MAKE) -C JWlink.build/orl -f GccUnix.mak
	$(MAKE) -C JWlink.build/sdk/rc/wres -f GccUnix.mak
	$(MAKE) -C JWlink.build -f GccUnix.mak
	cp JWlink.build/GccUnixR/jwlink $@.tmp
	mv $@.tmp $@
