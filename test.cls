\LoadClassWithOptions{article}
\usepackage [margin=0cm,paperwidth=\maxdimen,paperheight=\maxdimen] {geometry}

\usepackage[active,tightpage]{preview}
\usepackage{tikz-timing}
\usetikzlibrary {patterns}

\usetikzlibrary{snakes}
\tikzset{timing/every char/.append style={double}}

\ifx\usetikztimingpackage\undefined
  %\usepackage {tikz-timing-either}
  %\tikzset{timing/e/.style={fill=green},timing/e/background/.style={fill=green,draw=none}}
\else
\fi
\usetikztiminglibrary {either,advnodes}
\pagestyle{empty}
\tikzset{%
timing/.append style={orange,semitransparent,},
timing/e/.style={},timing/e/background/.style={fill=green,draw=none,},
timing/d/.style={},timing/d/background/.style={fill=yellow,draw=none,},
timing/u/text/.style={timing/d/text},
tt/.style={timing/initchar=T},
ee/.style={},
}

\sffamily
%\tikzset{timing/lslope=.4}
%\tikzset{timing/dslope=.4}
\tikzset{timing/zslope=0.2}
\tikzset{timing/dslope=0.3}
\tikzset{timing/lslope=.1}
\tikzset{timing/draw grid}
\tikzset{label/.style={opaque,black,anchor=base west,inner sep=0pt,outer sep=0pt}}


%\tikztiming@debug=3
\@tempdima=1.6ex

\def\b{\@backslashchar b}

\newcounter{count}

\tikztimingmetachar{K}{%
  ;
}
% vim: ft=tex
