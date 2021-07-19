---
layout: article
title: "The strange case of the greedy junction"
date: 2020-10-04
modified: 2020-10-04
tags: [ coding, hacking, programming, raku ]
excerpt: "An illustration that Raku's junctions are greedy by design, and a proposal."
current: ""
current_image: greedy-junctions_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: greedy-junctions_1600x600.jpg
  teaser: greedy-junctions_400x150.jpg
  thumb: greedy-junctions_400x150.jpg
---

[Raku](https://raku.org/) has a neat feature called [Junctions](https://docs.raku.org/type/Junction). In this short article I want to highlight a peculiar consequence of the interaction of junctions with functions: they are _greedy_, by which I mean that they inadvertently turn other arguments of functions into junctions. 

If you don't know Raku or are unfamiliar with the functional style of programming, I suggest you read my introductory article ["Cleaner code with functional programming"]({{site.url}}/articles/decluttering-with-functional-programming).


To illustrate the greedy behaviour, let's create a `pair` data structure that can take two values of different types, using a closure.
 
```perl6
# Pair Constructor: the arguments of pair() are captured
# in a closure that is returned
sub pair(\x, \y) {
    sub (&p){ p(x, y) } 
}
```

So `pair` takes two arguments of arbitrary type and returns a closure which takes a function as argument. We will use this function to access the values stored in the pair. I will call these accessor functions `fst` and `snd`:

```perl6
# Accessors to get the values from the closure
my sub fst (&p) {p( sub (\x,\y){x})}
my sub snd (&p) {p( sub (\x,\y){y})}
```

The function that does the actual selection is the anonymous subroutine returned by `fst` and `snd`, this is purely so that I can apply them to the pair rather than have to pass them as an argument. Let's look at an example, a pair of an `Int` and an `enum RGB`:

```perl6
enum RGB <R G B>;

my \p1 = pair 42, R;

if ( 42 == fst p1) {
    say snd p1;	#=> says "R"
}
```

So we create a pair by calling `pair` with two values, and use `fst` and `snd` to access the values in the pair. This is an immutable data structure so updates are not possible.

Now let's use a junction for one of the arguments.

```perl6
# Example instance with a 'one'-type junction
my Junction \p1j = pair (42^43),R;

if ( 42 == fst p1j) {
    say snd p1j; #=> one(R, R)
}
```

What has happened here is that the original argument `R` has been irrevocably turned into a junction with itself. This happens despite the fact that we never explicitly created a junction on `R`. This is a consequence of the application of a junction type to a function, and it is not a bug, simply an effect of junction behaviour. For a more detailed explanation, see my article ["Reconstructing Raku's Junctions"]({{site.url}}/articles/reconstructing-raku-junctions).

The [Raku documentation of junctions](https://docs.raku.org/type/Junction) says that you should not really try to get values out of a junction:

"Junctions are meant to be used as matchers in Boolean context; introspection of junctions is not supported. If you feel the urge to introspect a junction, use a Set or a related type instead."

Luckily, there is a FAQ that [grudgingly shows you how to do it](https://docs.raku.org/language/faq#index-entry-Junction_(FAQ)). The FAQ once again warns against doing this:

"If you want to extract the values (eigenstates) from a Junction, you are probably doing something wrong and should be using a Set instead."

However, as demonstrated by the example I have given, there is a clear use case for recovering values from junctions. It is of course not the intention that one of the values stored in the pair becomes inaccessible simply because the other value happens to be a junction.

I therefore propose the addition of a `collapse` function which will allow to collapse these inadvertent junction values into their original values.

```perl6
if ( 42 == fst p1j) {
    say collapse(snd p1j); #=> says 'R'
}
```

The implementation of this function is taken from [the above-mentioned FAQ](https://docs.raku.org/language/faq#index-entry-Junction_(FAQ)), with the addition of a check to ensure that all values on the junction are identical. 

```perl6
sub collapse(Junction \j) {    
    my @vvs;
    -> Any \s { push @vvs, s }.(j);    
    my $v =  shift @vvs;        
    my @ts = grep {!($_ ~~ $v)}, @vvs;
    if (@ts.elems==0) {  
        $v
    } else {
        die "Can't collapse this Junction: elements are not identical: {$v,@vvs}";
    }
}
```

In the first draft of this article, which I shared as a gist, I wrote that it would be nice if this `collapse` would be added as an additional method to the `Junction` class. And thanks to [Elizabeth Mattijsen](https://twitter.com/liztormato), there is already [a pull request implementing this feature in Rakudo](https://github.com/rakudo/rakudo/pull/3944)!  
I will update the post when it has made it into a release. 

