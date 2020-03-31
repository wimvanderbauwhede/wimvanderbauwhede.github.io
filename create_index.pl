#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
my $wd=cwd();

system('cp _config.yml.stage _config.yml');
my $hostname =`hostname`;
chomp $hostname;
if ($hostname=~/HackBook/) {
system('bundle exec jekyll build -d ~/Sites/wv-blog/');
system("cp ~/StaticIndexer/indexer.js ~/Sites/wv-blog");
system("cp -r ~/StaticIndexer/node_modules ~/Sites/wv-blog");

} else {
    
system('jekyll build -d ~/Sites/wv-blog/');
system("cp ../../StaticIndexer/indexer.js ~/Sites/wv-blog");
system("cp -r ../../StaticIndexer/node_modules ~/Sites/wv-blog");

}
chdir "$ENV{HOME}/Sites/wv-blog" or die $!;
print "CWD:",cwd(),"\n";
#system("pwd");
for my $dir (qw(about articles)) {
    system("cp $dir/index.html $dir.html");
}
chdir "$ENV{HOME}/Sites/wv-blog/articles";
my @blog_posts = glob('*');
chdir "$ENV{HOME}/Sites/wv-blog";
print "cp articles\n";
for my $post (@blog_posts) {
    next if $post eq 'index.html';
    system("cp articles/$post/index.html $post.html");
}


print "START indexing: node indexer.js\n";
system("node indexer.js");
print "DONE indexing\n";
chdir $wd;
system("pwd");
open my $IDX_RAW, '<',  "$ENV{HOME}/Sites/wv-blog/tipuesearch_content.js";
open my $IDX, '>',  "tipuesearch/tipuesearch_content.js";

while (my $line = <$IDX_RAW> ){
    $line=~s/\.html/\/index.html/ unless $line=~/index\.html/;
    for my $post (@blog_posts) {
        next if $post eq 'index.html';
        $line=~s/$post/articles\/$post/;
    }
    $line=~s/(\\t)+/ /g;
    $line=~s/(\\n)+/ /g;
    $line=~s/\s+/ /g;
    $line=~s/\s+/ /g;
    $line=~s/\s+•\s+//g;
    print $IDX $line;
}
close $IDX_RAW;
close $IDX;

