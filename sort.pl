#!/usr/bin/perl
################################################################################
# Copyright (c) 2009 Martin Scharrer <martin@scharrer-online.de>
# This is open source software under the GPL v3 or later.
#
# $Id$
################################################################################
use strict;
use warnings;

my %defs;

open (my $fh, ">", "tikz-timing.dtx.new");

my ($chara,$charb,$charc) = ("","","");

while (<>) {
    if (/^\\tikztimingdef\s*{(.)([^}]?)([^}]*)}/) {
        $charb = $1;
        $chara = $2 || $1;
        $charc = $3;
        $defs{$chara}{$charb}{$charc} .= $_;
       print {$fh} "% Definition '$charb$chara$charc'\n";
        if (/}\s*$/) {
            ($chara,$charb,$charc) = ("","","");
        }
    }
    if (/^\\tikztiminglet\s*{(.)([^}]?)([^}]*)}/) {
        $charb = $1;
        $chara = $2 || $1;
        $charc = $3;
        $defs{$chara}{$charb}{$charc} .= $_;
        print {$fh} "% Definition '$charb$chara$charc'\n";
        ($chara,$charb,$charc) = ("","","");
    }
    elsif (/^\s*}\s*(%.*|\s*)$/) {
        $defs{$chara}{$charb}{$charc} .= $_;
        ($chara,$charb,$charc) = ("","","");
    }
    else {
       if ($chara) {
        $defs{$chara}{$charb}{$charc} .= $_;
       }
       else {
        print {$fh} $_;
      }
    }
}

close ($fh);

my $n = 0;
my %SORT_ORDER = map { $_ => $n++ } qw (@ H L Z X D U M T C E A W ), '';
sub charsort {
    return $SORT_ORDER{$a} <=> $SORT_ORDER{$b};
}

foreach $chara (keys %defs) {
    open (my $fh, ">", "defs-$chara.tex");

    foreach my $charb (sort charsort keys %{$defs{$chara}}) {
        foreach my $charc (sort charsort keys %{$defs{$chara}{$charb}}) {
            print {$fh} $defs{$chara}{$charb}{$charc}, "\n\n";
        }
    }

    close ($fh);
}

__END__

