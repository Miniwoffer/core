#!/usr/bin/env perl
use strict;
use warnings;

my @categories;
my $which = shift(@ARGV);
if ($which eq 'boundaries') {
    @categories = qw(CR LF Newline Extend Regional_Indicator Format Katakana Hebrew_Letter ALetter
		    Single_Quote Double_Quote MidNumLet MidLetter MidNum Numeric ExtendNumLet);
} elsif ($which eq 'breaks') {
    @categories = qw(White_Space Dash Quotation_Mark Terminal_Punctuation STerm Pattern_White_Space);
} else {
    die "specify 'boundaries' or 'breaks'";
}

my $catregexp=join('|', @categories);
my %catlists = map { $_ => []; } (@categories);

while(<>) {
    next if (m/^#/ or m/^\s*$/);
    push(@{$catlists{$3}}, defined($2) ? (hex($1)..hex($2)) : hex($1))
	if (m/([[:xdigit:]]+)(?:\.\.([[:xdigit:]]+))?\s+; ($catregexp) #/)
}

print "/* This file is automatically generated by word-properties.pl from $ARGV */\n";
foreach(@categories) {
    my $arref=$catlists{$_};
    print "static const uint32_t ${_}[]= {\n";
    while(scalar(@$arref)) {
	print("\t", join(", ", map { sprintf("0x%05X", $_); } splice(@$arref, 0, 8)));
	print(scalar(@$arref) ? ", \n" : "\n");
    }
    print("};\n");
}
