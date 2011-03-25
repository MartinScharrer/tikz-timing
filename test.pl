#!/usr/bin/env perl
use strict;
use warnings;

my @ICHARS = ('','K');
my @ACHARS = qw/ N(a) [] ; H L Z X M U U{A} D D{A} G T tt C cc /;
my @CCHARS = qw/ H L Z X M U U{B} D D{B} G S T tt C cc E ee /;
my @BCHARS = qw/ H L Z X M U U{B} D D{B} G S T tt C cc E ee /;

foreach my $ACHAR (@ACHARS) {
my $filename = "test-${ACHAR}.tex";
print STDOUT "$filename\n";
open(OUT, '>', $filename);

print OUT <<'EOT';
\documentclass{test}
\begin{document}
EOT

foreach my $ICHAR (@ICHARS) {

print OUT <<'EOT';
\begin{preview}%
\begin{tikzpicture}[timing/picture,y=.5cm,x=1cm]
EOT

print OUT "\\node [label] at (0,0) {\\hbox to 4.8ex{\\hss\\verb|$ICHAR$ACHAR$ICHAR|\\hss}};\n";

my $x = 0;
my $y = 0;
foreach my $CCHAR (@CCHARS) {
    $y--;
    print OUT "\\node [label] at (0,$y) {\\hbox to 4.8ex{\\hss\\verb|$CCHAR|\\hss}};\n";
}
foreach my $BCHAR (@BCHARS) {
    $x++;
    $y=0;
    print OUT "\\node [label] at ($x,0) {\\hbox to 4.8ex{\\hss\\verb|$BCHAR|\\hss}};\n";
    foreach my $CCHAR (@CCHARS) {
        $y--;
        print OUT "\\timing at ($x,$y) {${BCHAR}${ICHAR}${ACHAR}${ICHAR}${CCHAR}};\n";
    }
}
print OUT "\\useasboundingbox ($x,$y) ++(1,-.5) rectangle (-.25,1);\n";
print OUT <<'EOT';
\end{tikzpicture}%
\end{preview}%
EOT
}

print OUT <<'EOT';
\end{document}
EOT

close(OUT);
}
