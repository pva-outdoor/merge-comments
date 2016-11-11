#!/usr/bin/perl -w
# use warnings;
# use strict;

# installation:
#
#  1. ensure 'merge-comments.pl' is executable
#     chmod a+x merge-comments.pl
#    
#  2. put 'merge-comments.pl' to your $PATH
#     cp merge-comments.pl /usr/local/bin
#
#  3. create it's temporary directory:
#     mkdir ~/.merge-comments.pl
#
# usage:
#
#   1. do git-merge what issues a conflict
#   2. run merge-comments.pl <conflicted-file> [<comment-regexp>]
#
# This will find all conflicts in the file and test if replacing
# 'theirs' changes with 'yours' looses only spaces or comments (that is
# lines what matches <comment-regexp>).
#
# When all replaces of a conflict contains only comments, the conflict
# will be resolved to 'mine' side.
#
# All unresolved conflicts will be reported to STDERR.

my $file = $ARGV[0] or die "1st argument must be a conflicted file";
my $ignore = $ARGV[1] || '^\s*#';

my $fprefix = "$ENV{HOME}/.merge-comments.pl";
my $ftheir = "$fprefix/their.txt";
my $fmine = "$fprefix/mine.txt";
my $fdiff = "$fprefix/diff.txt";
my $fsed = "$fprefix/sed.txt";

open(FILE, '<', $file) or die "can't read '$file'";

sub save_side {
    my ($close,$fname) = @_;
    open (SIDE, '>', $fname) or die "can't write '$fname'";
    while (<FILE>) {
	last if $_=~/^$close/;
	print SIDE $_;
    }
    close SIDE;
}

open(ED, '>', $fsed) or die "can't write '$fsed'";
while(<FILE>) {
    chomp($_);
    if ($_=~/^[<]{7} /) {
	my $block_beg = $.;
	save_side('[=]{7}$', $ftheir);
	save_side('[>]{7} ', $fmine);
	my $block_end = $.;

	`diff $fmine $ftheir > $fdiff`;
	open (DIFF, '<', $fdiff) or die "can't read generated '$fdiff'";
	eval {
	    # check diff if we can resolve
	    while (<DIFF>) {
		if ($_=~/^-(.+)/) {
		    my $old = $1;
		    die "$file:$block_beg: you should merge manually" unless ($old=~/\S/ || $old=~/$ignore/);
		}
	    }

	    # resolve to 'mine'
	    open(MINE, '<', $fmine);
	    print ED "${block_beg},${block_end}c";
	    while (<MINE>) {
		chomp;
		$_ =~ s/\\/\\\\/g;
		print ED "\\\n", $_;
	    }
	    close MINE;
	    print ED "\n";
	};
	if ($@) {
	    print STDERR $@;	    
	}
	close DIFF;
    }
}
close ED;
close FILE;

`sed -i -f $fsed $file`;
`rm -f $ftheir $fmine $fdiff $fsed`;
