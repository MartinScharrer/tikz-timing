#!/usr/bin/perl
################################################################################
# Copyright (c) 2009 Martin Scharrer <martin@scharrer-online.de>
# This is open source software under the GPL v3 or later.
#
# $Id$
################################################################################
use strict;
use warnings;

my @CHARS = qw/H L Z X M D D{A} U S G [green] N(a)/;
my %NONUM = map { $_ => 1 } qw/[green] N(a)/;

sub rchar {
   my $char = $CHARS[ int rand scalar @CHARS ];
   my $num = (exists $NONUM{$char}) ? "" : sprintf("%2.1f", 0.5 + rand 2.5);
   return $num . $char;
}


print << 'EOT';
%&pdflatex
% Auto-generated test file with random sequences

\documentclass{article}
\pagestyle{empty}
\usepackage{tikz-timing}

\parindent=0pt
\usepackage[active,tightpage]{preview}

\let\fromchar\empty
\let\tochar\empty

\makeatletter
\def\asis#1{%
   \def\temp{#1}%
   \@onelevel@sanitize\temp
   {\ttfamily\tiny\temp}%
}

\def\test#1{%
 \begin{preview}
  \asis{#1}\\
  \texttiming{#1}
 \end{preview}
}
\let\texttimingbefore\texttiminggrid

\begin{document}

EOT

my $num = $ARGV[0] || 100;
for my $n (1 .. $num) {
    my $chars = "";
    for (0 .. rand(15)) {
        $chars .= rchar . ' ';
    }
    print "% $n\n";
    print "\\test{$chars}\n\n";
}

print << 'EOT';
\end{document}

EOT

__END__

