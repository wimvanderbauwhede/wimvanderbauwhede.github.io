#!/usr/bin/env perl
use v5.16;
use warnings;
use strict;

my @posts=glob('*.md');

for my $post (@posts) {
    my @post_lines=();
    open my $IN, '<',$post;
    while(my $line=<$IN>) {
        push @post_lines,$line;
    }
    close $IN;

    open my $OUT, '>',$post;
    for my $line( @post_lines) {
        $line=~/(?:teaser|thumb):/ && do {
            $line=~s/_1600/_400/;
            $line=~s/x500/x125/;
            $line=~s/x600/x150/;
        };
        print $OUT $line;
    }
    close $OUT;
}
