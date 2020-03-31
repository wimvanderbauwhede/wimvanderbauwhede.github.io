#!/usr/bin/env perl
use warnings;
use strict;

my $post = $ARGV[0];

my $post_file = `ls articles/$post/index.html`;
chomp $post_file;
#print "<$post_file>";                                     
my @images=`grep images $post_file`;
for my $img (@images) {
chomp $img;
$img=~s/^.*images//;
next unless $img=~/jpg|png/;
$img=~s/jpg.*$/jpg/;
$img=~s/png.*$/png/;

print "git add images$img\n";
system("git add images$img");
}
