#!/usr/bin/env perl
use warnings;
use strict;
use Carp;
use Data::Dumper;
my $post = $ARGV[0];

my $post_file = `ls articles/$post/index.html`;
chomp $post_file;
#print "<$post_file>";                                     
my @images=`grep images $post_file`;
my @image_names = ();
#chdir '../quick-tasty';

for my $img (@images) {
    next unless $img=~/images\/\w+/;
    chomp $img;
    $img=~s/^.*images//;
    $img=~s/jpg.*$/jpg/;
    $img=~s/png.*$/png/;
    $img=~s/avif.*$/avif/;
    $img=~s/\.ico.*$/.ico/;
    push @image_names,$img;
}
for my $img (@image_names) {
    print "git add images$img\n";
    system("git add images$img");
}
