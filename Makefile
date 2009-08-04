# $Id$

PACKAGE=tikz-timing
PACKAGE_STY = ${PACKAGE}.sty
PACKAGE_DOC = ${PACKAGE}.pdf
PACKAGE_SRC = ${PACKAGE}.dtx ${PACKAGE}.ins Makefile
PACKFILES = ${PACKAGE_SRC} ${PACKAGE_DOC} README
TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb *.fdb_latexmk
INSGENERATED = ${PACKAGE_STY}
ZIPFILE = ${PACKAGE}-${ZIPVERSION}.zip
TDSZIPFILE = ${PACKAGE}.tds.zip
GENERATED = ${INSGENERATED} ${PACKAGE}.pdf
ZIPS = zip tdszip

LATEX_OPTIONS = -interaction=batchmode
LATEX = pdflatex ${LATEX_OPTIONS}

TEXMFDIR = ${HOME}/texmf

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all doc package clean fullclean tds

all: package doc example
new: fullclean all

doc: ${PACKAGE}.pdf

package: ${PACKAGE}.sty

example:

%.pdf: %.dtx
	${LATEX} $*.dtx
	-makeindex -s gind.ist -o $*.ind $*.idx
	-makeindex -s gglo.ist -o $*.gls $*.glo
	${LATEX} $*.dtx
	${LATEX} $*.dtx

${PACKAGE}.pdf: ${PACKAGE}.sty

${INSGENERATED}: *.dtx ${PACKAGE}.ins 
	yes | latex ${PACKAGE}.ins

clean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX})

fullclean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX}) ${GENERATED} *~ *.backup
	rm -f ${PACKAGE}*.zip
	rm -rf tds/ .tds

${PACKAGE}.zip: zip

zip: ${PACKAGE}.pdf

zip: ZIPVERSION=$(shell grep "Package: ${PACKAGE} " ${PACKAGE}.log | \
	sed -e "s/.*Package: ${PACKAGE} ....\/..\/..\s\+\(v\S\+\).*/\1/")

zip:
	@${MAKE} --no-print-directory ${ZIPFILE}

${PACKAGE}%.zip: ${PACKFILES}
	grep -q '\* Checksum passed \*' ${PACKAGE}.log
	-pdfopt ${PACKAGE}.pdf opt_${PACKAGE}.pdf && mv opt_${PACKAGE}.pdf ${PACKAGE}.pdf
	${RM} $@
	zip $@ ${PACKFILES}
	@echo
	@echo "ZIP file $@ created!"

tds: .tds

.tds: ${PACKAGE_STY} ${PACKAGE_DOC} ${PACKAGE_SRC}
	@grep -q '\* Checksum passed \*' ${PACKAGE}.log
	${RMDIR} tds
	${MKDIR} tds/
	${MKDIR} tds/tex/ tds/tex/latex/ tds/tex/latex/${PACKAGE}/
	${MKDIR} tds/doc/ tds/doc/latex/ tds/doc/latex/${PACKAGE}/
	${MKDIR} tds/source/ tds/source/latex/ tds/source/latex/${PACKAGE}/
	${CP} ${PACKAGE_STY} tds/tex/latex/${PACKAGE}/
	${CP} ${PACKAGE_DOC} tds/doc/latex/${PACKAGE}/
	${CP} ${PACKAGE_SRC} tds/source/latex/${PACKAGE}/
	@touch $@

tdszip: ${TDSZIPFILE}

${TDSZIPFILE}: .tds
	${RM} ${TDSZIPFILE}
	cd tds && zip -r ../${TDSZIPFILE} .

install: .tds
	test -d "${TEXMFDIR}" && ${CP} -a tds/* "${TEXMFDIR}/" && texhash ${TEXMFDIR}

uninstall:
	test -d "${TEXMFDIR}" && ${RM} -rv "${TEXMFDIR}/tex/latex/${PACKAGE}" \
	"${TEXMFDIR}/doc/latex/${PACKAGE}" "${TEXMFDIR}/source/latex/${PACKAGE}" && texhash ${TEXMFDIR}

test: test.pdf

test.pdf: ${PACKAGE}.sty test.tex
	pdflatex test
	pdfcrop test.pdf

compare: ${PACKAGE}.sty test.tex
	pdflatex test
	cp test.pdf new.pdf
	rm ${PACKAGE}.sty
	pdflatex test
	cp test.pdf old.pdf
	convert -density 500 new.pdf new-%02d.png
	convert -density 500 old.pdf old-%02d.png
	for N in `seq -w 00 10`; do compare old-$$N.png new-$$N.png diff-$$N.png; done

