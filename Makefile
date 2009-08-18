# $Id$

PACKAGE=tikz-timing
PACKAGE_STY = ${PACKAGE}.sty ${PACKAGE}-*.sty
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

SHELL=/bin/bash

TEXMFDIR = ${HOME}/texmf

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all doc package clean fullclean tds reload

all: package doc example
new: fullclean all

doc: ${PACKAGE}.pdf reload

pdf: one_run reload
	

package: ${PACKAGE}.sty

reload:
	-@pdfreload --file ${PACKAGE}.pdf

example:

one_run: ${PACKAGE}.dtx
	${LATEX} $<

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

CHARS=H L Z X M U D T C ""

ACHARS='N(a)' [] ';' H L Z X M U U{A} D D{A} G T tt C cc E ee

acompare: ${PACKAGE}.sty test2.tex
	for a in ${ACHARS}; do \
		echo "$$a"; \
		pdflatex -jobname "test-$$a" "\\def\\a{$$a}\\input{test2}";\
		compare -density 500 "test-$$a.pdf[0]" "test-$$a.pdf[1]" "diff-$${a}_0x1.png"; \
		compare -density 500 "test-$$a.pdf[0]" "test-$$a.pdf[2]" "diff-$${a}_0x2.png"; \
		compare -density 500 "test-$$a.pdf[0]" "test-$$a.pdf[3]" "diff-$${a}_0x3.png"; \
		compare -density 500 "test-$$a.pdf[1]" "test-$$a.pdf[2]" "diff-$${a}_1x2.png"; \
		compare -density 500 "test-$$a.pdf[1]" "test-$$a.pdf[3]" "diff-$${a}_1x3.png"; \
		compare -density 500 "test-$$a.pdf[2]" "test-$$a.pdf[3]" "diff-$${a}_2x3.png"; \
	done

icompare: ${PACKAGE}.sty test.tex
	rm -f new-*.* old-*.* diff-*.*
	for I in ${CHARS}; do \
		pdflatex -jobname "new-$$I" "\\def\\I{$$I}\\input{test}";\
	  mv ${PACKAGE}.sty ${PACKAGE}.sty.save; \
		pdflatex -jobname "old-$$I" "\\def\\I{$$I}\\input{test}";\
	  mv ${PACKAGE}.sty.save ${PACKAGE}.sty; \
		P=$$(( $$(pdfinfo new-$$I.pdf | grep ^Pages: | cut -d: -f2) - 1 )); \
		for N in $$(seq -w 0 $$P); do \
		  compare -density 500 old-$$I.pdf[$$N] new-$$I.pdf[$$N] diff-$$I-$$N.png; \
	  done; \
	done

compare: ${PACKAGE}.sty test.tex
	rm -f new*.* old*.* diff*.*
	pdflatex test
	pdfcrop test.pdf new.pdf
	mv ${PACKAGE}.sty ${PACKAGE}.sty.save;
	pdflatex test
	pdfcrop test.pdf old.pdf
	mv ${PACKAGE}.sty.save ${PACKAGE}.sty;
	P=$$(( $$(pdfinfo new.pdf | grep ^Pages: | cut -d: -f2) - 1 )); \
	for N in $$(seq -w 0 $$P); do \
		echo -n "$$N: "; \
		compare -density 500 -metric MAE old.pdf[$$N] new.pdf[$$N] diff-$$N.png; \
	done

