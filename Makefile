# $Id$

PACKAGE=tikz-timing
PACKAGE_STY = ${PACKAGE}.sty
PACKAGE_DOC = ${PACKAGE}.pdf
PACKAGE_SRC = ${PACKAGE}.dtx ${PACKAGE}.ins README Makefile
PACKFILES = ${PACKAGE_SRC} ${PACKAGE_DOC}
TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb
INSGENERATED = ${PACKAGE}.sty
GENERATED = ${INSGENERATED} ${PACKAGE}.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf
ZIPFILE = ${PACKAGE}-${ZIPVERSION}.zip
TDSZIPFILE = ${PACKAGE}-${ZIPVERSION}.tds.zip
ZIPS = zip tdszip

LATEX_OPTIONS = -interaction=batchmode
LATEX = pdflatex ${LATEX_OPTIONS}

TEXMFDIR = ${HOME}/texmf

RED   = \033[01;31m
GREEN = \033[01;32m
WHITE = \033[00m

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all doc package clean fullclean example testclean tds

all: package doc example
new: fullclean all

doc: ${PACKAGE}.pdf

package: ${PACKAGE}.sty

example:

%.pdf: %.dtx
	${LATEX} $*.dtx
	${LATEX} $*.dtx
	-makeindex -s gind.ist -o $*.ind $*.idx
	-makeindex -s gglo.ist -o $*.gls $*.glo
	${LATEX} $*.dtx
	${LATEX} $*.dtx

%.pdf: %.eps
	epstopdf $<

%.eps: %.dia
	dia -t eps -e $@ $<

${PACKAGE}.pdf: ${PACKAGE}.sty

${INSGENERATED}: *.dtx ${PACKAGE}.ins 
	yes | latex ${PACKAGE}.ins

clean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX})

fullclean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX}) ${GENERATED} *~ *.backup
	rm -f ${PACKAGE}*.zip
	rm -rf tds/


zip: fullclean package doc example ${ZIPFILE}
${PACKAGE}.zip: zip

${ZIPS}: ZIPVERSION=$(shell grep "Package: ${PACKAGE} " ${PACKAGE}.log | \
	sed -e "s/.*Package: ${PACKAGE} ....\/..\/..\s\+\(v\S\+\).*/\1/")

${ZIPFILE}: ${PACKFILES}
	grep -q '\* Checksum passed \*' ${PACKAGE}.log
	-pdfopt ${PACKAGE}.pdf opt_${PACKAGE}.pdf && mv opt_${PACKAGE}.pdf ${PACKAGE}.pdf
	${RM} ${ZIPFILE}
	zip ${ZIPFILE} ${PACKFILES}
	@echo
	@echo "ZIP file ${ZIPFILE} created!"

tar.gz: ${PACKAGE}.tar.gz

${PACKAGE}.tar.gz:
	tar -czf $@ ${PACKFILES}

tds: package doc
	@grep -q '\* Checksum passed \*' ${PACKAGE}.log
	${RMDIR} tds
	${MKDIR} tds
	${MKDIR} tds/tex tds/tex/latex/ tds/tex/latex/${PACKAGE}
	${MKDIR} tds/doc tds/doc/latex/ tds/doc/latex/${PACKAGE}
	${MKDIR} tds/source tds/source/latex/ tds/source/latex/${PACKAGE}
	${CP} ${PACKAGE_STY} tds/tex/latex/${PACKAGE}/
	${CP} ${PACKAGE_DOC} tds/doc/latex/${PACKAGE}/
	${CP} ${PACKAGE_SRC} tds/source/latex/${PACKAGE}/

tdszip: tds
	${RM} ${TDSZIPFILE}
	cd tds && zip -r ../${TDSZIPFILE} .

install: tds
	test -d "${TEXMFDIR}" && ${CP} -a tds/* "${TEXMFDIR}/" && texhash ${TEXMFDIR}

