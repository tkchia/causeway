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

MAIN =	source/all/cw32.asm
SRCS =	$(MAIN) source/all/raw_vcpi.asm source/all/interrup.asm \
	source/all/ldt.asm source/all/memory.asm source/all/api.asm \
	source/all/int10h.asm source/all/int21h.asm source/all/int33h.asm \
	source/all/decode_c.asm source/all/exceptn.asm \
	source/all/loadle/loadle.asm
INCS =	source/all/strucs.inc source/all/cw.inc
DEPS =	$(SRCS) $(INCS)

# If we already have JWasm &/or JWlink installed, use those.  Otherwise
# download & build JWasm &/or JWlink.
GIT = git
ifneq "" "$(shell jwasm '-?' 2>/dev/null)"
    ASM = jwasm
else
    ASM = ./jwasm
    DEPS += $(ASM)
endif
RM = rm -f

default: cw32.exe
.PHONY: default

clean: mostlyclean
	$(RM) -r JWasm.build JWlink.build jwasm jwlink
.PHONY: clean

mostlyclean:
	$(RM) -r *.obj *.exe *.map *.err *.tmp \
		 *~ source/all/*~ source/all/loadle/*~
.PHONY: mostlyclean

cw32.exe: $(DEPS)
	$(ASM) -mz -DENGLISH=1 -Fo$@.tmp $(MAIN)
	mv $@.tmp $@

./jwasm:
	$(RM) -r JWasm.build
	$(GIT) submodule update
	cp -a JWasm.src JWasm.build
	$(MAKE) -C JWasm.build -f GccUnix.mak
	cp JWasm.build/build/GccUnixR/jwasm $@.tmp
	mv $@.tmp $@
