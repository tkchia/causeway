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
	 source/all/loadle/loadle.asm
CWINCS = source/all/strucs.inc source/all/cw.inc
CWDEPS = $(CWSRCS) $(CWINCS)

CWCDEPS =

# If we already have JWasm &/or JWlink installed, use those.  Otherwise
# download & build JWasm &/or JWlink.
GIT = git
ifneq "" "$(shell jwasm '-?' 2>/dev/null)"
    ASM = jwasm
else
    ASM = ./jwasm
    CWDEPS += $(ASM)
    CWCDEPS += $(ASM)
endif
ifneq "" "$(shell jwlink '-?' 2>/dev/null)"
    LINK = jwlink
else
    LINK = ./jwlink
endif
RM = rm -f

default: cwc cwstub.exe
.PHONY: default

install: cwc cwstub.exe
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
	$(RM) -r *.obj *.exe *.com *.gh *.map *.lst *.err *.tmp mkcode cwc \
		 *~ source/all/*~ source/all/loadle/*~
.PHONY: mostlyclean

cw32.exe: $(CWDEPS)
	$(ASM) -mz -DENGLISH=1 -DCONTRIB=1 -Fo$@.tmp -Fl$(@:.exe=.lst) \
	    $(CWMAIN)
	mv $@.tmp $@

# To compress the CauseWay loader stub, use Watcom's cwc.c, rather than
# CauseWay's original source/all/cwc/cwc.asm .  The former is written in C
# and thus is usable even on a non-MS-DOS build machine.
cwstub.exe: cw32.exe cwc
	./cwc $< $@.tmp
	mv $@.tmp $@
.PRECIOUS: cwstub.exe

%.gh: %.com mkcode
	./mkcode -b $< $@.tmp
	mv $@.tmp $@
.PRECIOUS: %.gh

%.com: source/all/cwc/%.asm $(CWCDEPS)
	$(ASM) -bin -DENGLISH=1 -DCONTRIB=1 -Fo$@.tmp -Fl$(@:.com=.lst) $<
	mv $@.tmp $@
.PRECIOUS: %.com

cwc: watcom/cwc.c copystub.gh decstub.gh \
    watcom/watcom.h watcom/bool.h watcom/exedos.h watcom/pushpck1.h \
    watcom/poppck.h
	$(CC) $(CPPFLAGS) -Iwatcom -I. $(CFLAGS) $(LDFLAGS) $< -o $@ $(LDLIBS)
.PRECIOUS: cwc

mkcode: watcom/mkcode.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $< -o $@ $(LDLIBS)
.PRECIOUS: mkcode

./jwasm:
	$(RM) -r JWasm.build
	$(GIT) submodule update
	cp -a JWasm.src JWasm.build
	mkdir -p JWasm.build/build/GccUnixR
	$(MAKE) -C JWasm.build -f GccUnix.mak
	cp JWasm.build/build/GccUnixR/jwasm $@.tmp
	mv $@.tmp $@
.PRECIOUS: ./jwasm

./jwlink:
	$(RM) -r JWlink.build
	$(GIT) submodule update
	cp -a JWlink.src JWlink.build
	$(MAKE) -C JWlink.build/dwarf/dw -f GccUnix.mak
	$(MAKE) -C JWlink.build/orl -f GccUnix.mak
	$(MAKE) -C JWlink.build/sdk/rc/wres -f GccUnix.mak
	$(MAKE) -C JWlink.build -f GccUnix.mak
	cp JWlink.build/GccUnixR/jwlink $@.tmp
	mv $@.tmp $@
.PRECIOUS: ./jwlink
