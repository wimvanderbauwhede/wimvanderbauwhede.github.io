#!/usr/bin/perl
use v5.30;
use warnings;
use strict;

# A trivial script to sunbstitute CSS class attributes from Pygments for style color attributes

my %colours = (
 c => '008000', 
 k => 'AF00DB', 
 ch => '008000', 
 cm => '008000', 
 cp => '0000ff', 
 cpf => '008000', 
 c1 => '008000', 
 cs => '008000',  
 kc => '0000ff', 
 kd => '0000ff', 
 kn => '0000ff', 
 kp => '0000ff', 
 kr => '0000ff', 
 kt => '2b91af', 
 s => 'a31515', 
 nc => '2b91af', 
 ow => '0000ff', 
 sa => 'a31515', 
 sb => 'a31515', 
 sc => 'a31515', 
 dl => 'a31515', 
 sd => 'a31515', 
 s2 => 'a31515', 
 se => 'a31515', 
 sh => 'a31515', 
 si => 'a31515', 
 sx => 'a31515', 
 sr => 'a31515', 
 s1 => 'a31515', 
 ss => 'a31515',
 n => '267f99',
 nb => '000033',
 
 );

my $file =  $ARGV[0] // die "Provide the HTML file generated by Jekyll as argument\n";
my @lines=();
open my $HTML, '<', $file or die $!;
while (my $line = <$HTML>) {
    chomp $line;
    push @lines, $line;
}
close $HTML;

say '<!DOCTYPE html>
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>
';
my $skip = 1;
for my $line (@lines) {
    if ($line=~/body/  ) {$skip = 0;}
    next if $skip;
    while ($line=~/class=\"(\w+)\"/) {
        my $st = $1;
        my $col = $colours{$st} // '000000';
        $line=~s/class=\"$st\"/style=\"color:\ #$col\;\"/;
    }
    say $line;
}
# class="k" 'style="color: #999;"'