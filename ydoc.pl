#!/usr/bin/perl
################################################################################
# Copyright (c) 2009 Martin Scharrer <martin@scharrer-online.de>
# This is open source software under the GPL v3 or later.
#
# $Id$
################################################################################
use strict;
use warnings;

open (my $dtx, "<", "tikz-timing.dtx");
my @first;

while (<$dtx>) {
  last if /^\\usepackage{ydoc}/;
  push @first, $_;
}
my @last = <$dtx>;
close($dtx);

open (my $ydoc, "<", "ydoc.sty") or die;

open ($dtx, ">", "tikz-timing.dtx");
print {$dtx}
    @first,
    "\\makeatletter\n% ydoc.sty: ",
    <$ydoc>,
    "\\makeatother\n",
    @last;
close($dtx);

close($ydoc);

__END__

