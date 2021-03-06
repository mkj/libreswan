# Libreswan library
# Copyright (C) 1998-2001  Henry Spencer.
# Copyright (C) 2003, 2004 Xelerance Corporation
# Copyright (C) 2012 Paul Wouters <pwouters@redhat.com>
# Copyright (C) 2012-2013 Paul Wouters <paul@libreswan.org>
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See <http://www.fsf.org/copyleft/gpl.txt>.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#


LIBRESWANSRCDIR?=$(shell cd ../..; pwd)

include ${LIBRESWANSRCDIR}/Makefile.inc
include ${LIBRESWANSRCDIR}/Makefile.ver


MANDIR=$(MANTREE)/man3

X509LIB=x509dn.c asn1.c oid.c

SRCS=addrtoa.c addrtot.c addrtypeof.c alg_info.c anyaddr.c \
	constants.c datatot.c \
	alloc.c diag.c \
	goodmask.c id.c initaddr.c initsaid.c initsubnet.c \
	iprange.c \
        keyblobtoid.c \
	kernel_alg.c lex.c mpzfuncs.c \
	realtimetoa.c lswconf.c \
	portof.c rangetosubnet.c sameaddr.c \
	satot.c secrets.c subnetof.c subnettoa.c subnettot.c \
	subnettypeof.c ttoaddr.c ttodata.c ttoprotoport.c \
	ttorange.c ttosa.c ttosubnet.c ttoul.c ultot.c \
	$(X509LIB)

ifeq ($(USE_DNSSEC),true)
SRCS+=unbound.c
endif

SRCS+=sanitizestring.c pfkey_print.c pfkey_sock.c pfkey_error.c

ifeq ($(USE_KLIPS),true)
KLIPS_DEFS=-DKLIPS 
endif

ifeq ($(USE_PFKEYv2),true)
PFKEYV2_DEFS=-DPFKEYV2
PFKEYV2_SRCS+=pfkey_v2_build.c pfkey_v2_ext_bits.c pfkey_v2_parse.c
PFKEYV2_SRCS+=pfkey_v2_debug.c 
endif

ifeq ($(USE_LIBCURL),true)
CFLAGS+=-DLIBCURL
endif

ifeq ($(USE_LDAP),true)
CFLAGS+=-DLDAP_VER=3
endif

ifeq ($(USE_FIPSCHECK),true)
CFLAGS+=-DFIPSPRODUCTCHECK=\"${FIPSPRODUCTCHECK}\" -DFIPS_CHECK
endif

CFLAGS+=-DUSE_SHA2 -DUSE_SHA1 -DUSE_MD5
CFLAGS+=-I${LIBRESWANSRCDIR}/lib/libcrypto/libsha2

LOGSRCS=lswlog.c lswid.c


OBJS=${SRCS:.c=.o} ${PFKEYV2_SRCS:.c=.o} version.o
LOGOBJS=${LOGSRCS:.c=.o}

KLIPSSRCDIR?=${LIBRESWANSRCDIR}/linux/net/ipsec
MANSRCDIR=${LIBRESWANSRCDIR}/lib/libswan

VPATH+= ${KLIPSSRCDIR}

HDRS=${KLIPSINC}/libreswan.h internal.h

LIBA=libswan.a
LIBL=liblswlog.a
# Original flags
CFLAGS+=${PORTINCLUDE} -I. -I${KLIPSSRCDIR} -I${KLIPSINC}
CFLAGS+=-I${LIBRESWANSRCDIR}
CFLAGS+=${PFKEYV2_DEFS} ${KLIPS_DEFS} $(NSSFLAGS)
CFLAGS+= -I${LIBRESWANSRCDIR}/include ${PORTINCLUDE} $(USERCOMPILE) ${CROSSFLAGS}
CFLAGS+= ${WERROR}

ifeq ($(USE_SINGLE_CONF_DIR),true)
CFLAGS+= -DSINGLE_CONF_DIR=1
endif

ifeq ($(USE_LABELED_IPSEC),true)
CFLAGS+=-DHAVE_LABELED_IPSEC
endif

ifeq ($(USE_DNSSEC),true)
CFLAGS+=-DDNSSEC
endif

CFLAGS+=-DIPSEC_CONFDIR=\"$(FINALCONFDIR)\"
CFLAGS+=-DIPSEC_CONFDDIR=\"$(FINALCONFDDIR)\"
CFLAGS+=-DIPSEC_CONF=\"$(FINALCONFFILE)\"
CFLAGS+=-DIPSEC_VARDIR=\"$(FINALVARDIR)\"
CFLAGS+=-DIPSEC_EXECDIR=\"$(FINALLIBEXECDIR)\"
CFLAGS+=-DIPSEC_SBINDIR=\"$(FINALSBINDIR)\"

ARFLAGS=crvs
EXTHDRS=des.h
EXTLIBS=libdes.a
MANS=anyaddr.3 atoaddr.3 atoul.3 goodmask.3 \
	initaddr.3 initsubnet.3 portof.3 rangetosubnet.3 \
	sameaddr.3 subnetof.3 ttoaddr.3 ttodata.3 ttosa.3 ttoul.3 

.PHONY:	all install clean l t lt tar check depend checkprograms

# we can't do tests with two conditions, but we can concatenate the strings
SHOULDWERESTART=${USE_OBJDIR}$(wildcard ttodata.3.xml)
ifeq ($(SHOULDWERESTART),truettodata.3.xml)
all programs clean install:
	cd ${LIBRESWANSRCDIR} && cd ${OBJDIRTOP}/lib/libswan && make $@
else
all:	$(LIBA) ${LIBL}
programs: $(LIBA) ${LIBL}
clean:	cleanall
install: doinstall

endif


doinstall:
	@mkdir -p $(MANDIR)
	@for f in $(MANS) ; \
	do \
		$(INSTALL) $(INSTMANFLAGS) $(MANSRCDIR)/$$f $(MANDIR)/ipsec_$$f || exit 1 ; \
	done
	@$(LIBRESWANSRCDIR)/packaging/utils/manlink $(foreach man, $(MANS), ${MANSRCDIR}/$(man)) | \
	while read from to; \
	do \
		ln -s -f ipsec_$$from $(MANDIR)/$$to; \
	done


install_file_list:
	@for f in $(MANS) ; \
	do \
		echo $(MANDIR)/ipsec_$$f;\
	done;
	@$(LIBRESWANSRCDIR)/packaging/utils/manlink $(foreach man, $(MANS), ${MANSRCDIR}/$(man)) | \
	while read from to; \
	do \
		echo $(MANDIR)/$$to; \
	done

$(LIBA): $(OBJS)
	$(AR) $(ARFLAGS) $(LIBA) $(OBJS)

$(LIBL): $(LOGOBJS)
	$(AR) $(ARFLAGS) $(LIBL) $(LOGOBJS)

$(OBJS):	$(HDRS)

$(LOGOBJS):	$(HDRS)

# build version.c using version number from Makefile.ver
version.c:	version.in.c ${LIBRESWANSRCDIR}/Makefile.ver
	sed -e '/"/s/@IPSECVERSION@/$(IPSECVERSION)/' -e '/"/s/@IPSECVIDVERSION@/$(IPSECVIDVERSION)/' ${KLIPSSRCDIR}/version.in.c >$@

#libdes.a:	../libdes/libdes.a
#	ln -f -s ../libdes/libdes.a
#
# yes, that's CFLAG=, not CFLAGS=
#../libdes/libdes.a:
#	cd ../libdes ; \
#	if test " `arch | sed 's/^i[3456]/x/'`" = " x86" ; \
#	then $(MAKE) CC='$(CC)' CFLAG='$(CFLAGS)' TESTING='' x86-elf ; \
#	else $(MAKE) CC='$(CC)' CFLAG='$(CFLAGS)' libdes.a ; \
#	fi

test-%: %.c
	${CC} ${CFLAGS} -D`echo $* | tr 'a-z' 'A-Z'`_MAIN $*.c -o test-$*

cleanall:
	rm -f $(LIBA) $(LIBL) *.o try* core *.core $(EXTHDRS) $(EXTLIBS) version.c Makefile.depend


# developer-only stuff
l:
	$(MAKE) $(LIB) ARFLAGS=crv CFLAGS=-O
	$(RANLIB) $(LIB)

t:	$(LIB) 
	ln -f -s ${KLIPSSRCDIR}/ttosubnet.c try1a.c
	${CC} ${CFLAGS} -DTTOSUBNET_MAIN try1a.c $(LIB) -o try1a
	./try1a -r
	ln -f -s ${KLIPSSRCDIR}/ttodata.c try2.c
	${CC} ${CFLAGS} -DTTODATA_MAIN try2.c $(LIB) -o try2
	./try2 -r
	ln -f -s ${KLIPSSRCDIR}/ttosa.c try4a.c
	${CC} ${CFLAGS} -DTTOSA_MAIN try4a.c $(LIB) -o try4a
	./try4a -r
	ln -f -s ${KLIPSSRCDIR}/rangetosubnet.c try6.c
	${CC} ${CFLAGS} -DRANGETOSUBNET_MAIN try6.c $(LIB) -o try6
	./try6 -r
	ln -f -s ${KLIPSSRCDIR}/addrtot.c try7.c
	${CC} ${CFLAGS} -DADDRTOT_MAIN try7.c $(LIB) -o try7
	./try7 -r

tar:	clean
	tar -cvf /tmp/lib.tar Makefile [a-z]*

check:
	echo no checks in lib right now.

checkprograms:

# ??? does $(SRCS) work, given the files could be in different directories?
Makefile.depend: $(SRCS) $(LOGSRCS) ${LIBRESWANSRCDIR}/lib/libswan/Makefile
	# note: files listed in SRCS may be in ${LIBRESWANSRCDIR}/lib/libswan/ or ${KLIPSSRCDIR}/
	# This construction looks in both.  The wildcard function weeds out the wrong choices.
	# The grep could be replaced by the GNU Make "filter" function.
	(ls $(wildcard $(addprefix ${LIBRESWANSRCDIR}/lib/libswan/,$(SRCS))) \
	    $(wildcard $(addprefix ${KLIPSSRCDIR}/,$(SRCS))) \
	    $(wildcard $(addprefix ${LIBRESWANSRCDIR}/lib/libswan/,$(LOGSRCS))) \
	| grep '\.c' | xargs ${CC} -MM ${CFLAGS} ${PORTINCLUDE} ${ALLFLAGS}) >Makefile.depend

-include Makefile.depend
