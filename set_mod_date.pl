#!/usr/bin/env perl
use warnings;
use strict;

my @dirs=qw(
about
lic
);
my @ds = localtime;
my $d = ($ds[3]<10) ? '0'.$ds[3] : $ds[3];
my $m = ($ds[4]<9) ? '0'.($ds[4]+1) : ($ds[4]+1);
my $y = $ds[5]+1900;
my $datestr = $y.'-' .$m.'-'.$d;
#die $datestr;
set_mod_date('.', $datestr);
for my $dir (@dirs) {
	set_mod_date($dir, $datestr);
}
sub set_mod_date { (my $dir, my $datestr)=@_;
	open my $IN, '<', "$dir/index.md" or die $!;
	open my $OUT, '>',"$dir/index_tmp.md" or die $!;
	while (my $line=<$IN>) {
		$line=~/^date:/ && do {
			$line = 'date: ' . $datestr . "\n";
		};
		print $OUT $line;
	}
	close $OUT;
	close $IN;
	rename "$dir/index_tmp.md","$dir/index.md";
}

