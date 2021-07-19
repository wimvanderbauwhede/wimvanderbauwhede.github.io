---
layout: article
title: "Reconstructing Raku's Junctions"
date: 2020-10-05
modified: 2020-10-05
tags: [ coding, hacking, programming, raku, haskell ]
excerpt: "A reconstruction of Raku's junctions as an algebraic data with higher-order functions."
current: ""
current_image: reconstructing-raku-junctions_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: reconstructing-raku-junctions_1600x600.jpg
  teaser: reconstructing-raku-junctions_400x150.jpg
  thumb: reconstructing-raku-junctions_400x150.jpg
---

Junctions in Raku are cool but at first glance they do not follow the rules for static typing. I was curious about their formal typing semantics, so I deconstructed and then reconstructed junctions from a functional, static typing perspective.

If you don't know Raku or are unfamiliar with the functional style of programming, I suggest you read my introductory article ["Cleaner code with functional programming"]({{site.url}}/articles/decluttering-with-functional-programming). If you have not heard of algebraic data types before, I suggest my article ["Roles as Algebraic Data Types in Raku"]({{site.url}}/articles/roles-as-adts-in-raku).

## Junctions in Raku	

[Raku](https://raku.org/) has this neat feature called [Junctions](https://docs.raku.org/). A junction is an unordered composite value. When a junction is used instead of a value, the operation is carried out for each junction element, and the result is the junction of the return values of all those operators. Junctions collapse into a single value when used in a Boolean context. Junctions can be of type _all_ (`&`), _any_ (`|`), _one_ (`^`) or _none_ (empty junction).

For example, 

```perl6
my $j = 11|22; # short for any(11,22)
if 33 == $j + 11 {
    say 'yes';
}

say so 3 == (1..30).one;         #=> True 
say so ("a" ^ "b" ^ "c") eq "a"; #=> True
```

The function `so` forces the Boolean context.

Junctions have type _Junction_, and I was curious about the typing rules, because at first sight there is something strange. Let's say we have a function `sq` from _Int_ to _Int_ :

```perl6
sub sq(Int $x --> Int) { $x*$x }

my Int $res = sq(11); # OK
say $res; #=> 121 
```

Now let's define a junction of type _any_ of _Int_ values:

```perl6
my Junction $j = 11 | 22; 
```

When we apply `sq` to `$j`, we do not get a type error, even though the functions has type `:(Int --> Int)` and the junction has type `Junction`. Instead, we get a junction of the results:

```perl6
say sq($j); #=> any(121, 484)
```

If we assign this to a variable of type _Int_ as before, we get a type error:

```perl6
my Int $rj = sq($j); #=> Type check failed in assignment to $rj; expected Int but got Junction (any(121, 484))
```

Instead, the return value is now of type _Junction_:

```
my Junction $rj = sq(11|22); # OK
```

So the _Junction_ type can take the place of any other type but then the operation becomes a junction as well.

On the other hand, junctions are implicitly typed by their constituent values, even though they seem to be of the opaque type _Junction_. For example, if we create a junction of _Str_ values, and try to pass this junction value into `sq`, we get a type error:

```perl6
my $sj = '11' | '22';
say $sj.WHAT; #=>(Junction)

my Junction $svj = sq($sj); #=> Type check failed in binding to parameter 'x'; expected Int but got Str ("11")
```

## Do junctions follow static typing rules?

Although this _kind of_ makes sense (we don't want it to work with _Str_ if the original function expects _Int_), this does flout the rules for static typing, even with subtyping. If an argument is of type _Int_ then any type below it in the type graph can be used instead. But the simplified type graph for _Int_ and _Junction_ is as follows:

        Int -> Cool -> Any -> Mu <- Junction

So a _Junction_ is never a subtype of anything below _Any_. Therefore putting a junction in a slot of type _Any_ or subtype thereof should be a type error.

Furthermore, because the _Junction_ type is opaque (i.e. it is not a parametrised type), it should not hold any information about the type of the values inside the junction. And yet it does type check against these invisible, inaccessible values. 

So what is happening here? 

## A working hypothesis

A working hypothesis is that a _Junction_ type does not really take the place of any other type: it is merely a syntactic sugar that makes it seem so.

## Reconstructing junctions part 1: types 

Let's try and reconstruct this. The aim is to come up with a data type and some actions that will replicate the observed behaviour of Raku's junctions.
First we discuss the types, using Haskell notation for clarity. Then I present the implementation in Raku. This implementation will behave like Raku's native junctions but without the magic syntactic sugar. In this way I show that Raku's junctions do follow proper typing rules after all.

### The Junction type

A _Junction_ is a data structure consisting of a junction type _JType_ and a set of values. 
I restrict this set of values to a single type for convenience and also because a junction of mixed types does actually not make much sense. I use a list to model the set, again for convenience. Because a _Junction_ can contain values of any type, it is a polymorphic algebraic data type:

```haskell
data JType = JAny | JAll | JOne | JNone

data Junction a = Junction JType [a]
```

### Applying junctions

Doing anything with a junction means applying a function to it. We can consider three cases, and I introduce an ad-hoc custom operator for each of them:

- Apply a non-_Junction_ function to a _Junction_ expression

```haskell
    (•￮) :: (a -> b) -> Junction a ->  Junction b
```

- Apply a _Junction_ function to a non-_Junction_ expression

```haskell
    (￮•) ::  Junction (b -> c) -> b -> Junction c
```

- Apply a _Junction_ function to a _Junction_ expression, creating a nested junction

```haskell
    (￮￮) ::  Junction (b -> c) -> Junction b -> Junction (Junction c)
```

For convenience, we can also create custom comparison operators between _Junction a_ and _a_:

```haskell
    -- and similar for /-, >, <, <=,>=
    (￮==•) :: Junction a -> a -> Bool
```

### Collapsing junctions

Then we have `so`, the Boolean coercion function. What it does is to collapse a junction of Booleans into a single Boolean. 

```haskell
so :: Junction Bool -> Bool
```

Finally we have `collapse`, which returns the value from a junction, provided that it is a junction where all stored values are the same. 

```haskell
collapse :: (Show a,Eq a) => Junction a -> a
```

This may seem like a strange function but it is necessary because of the behaviour of junctions. As we will see, the above semantics imply that junctions are greedy: if a single argument of a function is a junction, then all other arguments also become junctions, but all values in the junction are identical. I have discussed this in ["The strange case of the greedy junction"]({{site.url}}/articles/greedy-junctions), but we can now formalise this behaviour.

### Revisiting the strange case of the greedy junction

Suppose we have a function of two arguments `f :: a -> b -> c`, and we apply a junction `j :: Junction a` to the first argument, `f •￮ j`. Then the result is a partially applied function wrapped in a Junction: `fp :: Junction b -> c`. If we now want to apply this function a non-Junction value `v :: b` using `fp ￮• v`, the result is of type `Junction c`. So already we see that the non-Junction value `v` is assimilated into the junction.

Now, let's consider the particular case where the type `c` is `forall d . (a -> b -> d) -> d`, so we have `Junction (forall d . (a->b->d) -> d)`. This is a function which takes a function argument and returns something of the return type of that function. We use the `forall` so that `d` can be anything, but in practice we want it to be either `a` or `b`.

Let's assume we apply this function (call it `p`) to `fst :: a->b->a`, using `p ￮• fst`, then we get `Junction a`. But if we apply it to `snd :: a->b->b`, using `p ￮• snd`, then we get `Junction b`. Recall that we applied the original function `f` to a `Junction a` and a non-Junction `b`. Yet whatever we do, we can't recover the `b`. The result is always wrapped in a junction. 

This is the formal type-based analysis of why we can't return a non-Junction value from a pair as explained in ["The strange case of the greedy junction"]({{site.url}}/articles/greedy-junctions). And this is why we need the `collapse` function.

## Reconstructing junctions part 2: Raku implementation

We start by creating the Junction type, using an enum for the four types of junctions, and a role for the actual _Junction_ data type:

```perl6
# The types of Junctions
enum JType <JAny  JAll  JOne  JNone >;

# The actual Junction type
role Junction[\jt, @vs] {
    has JType $.junction-type=jt;
    has @.values=@vs;
}
```

Next, the constructors for the four types of junctions (underscore to avoid the name conflict with the builtins):

```perl6
our sub all_(@vs) {
    Junction[ JAll, @vs].new;
}

our sub any_(@vs) {
    Junction[ JAny, @vs].new;
}

our sub one_(@vs) {
    Junction[ JOne, @vs].new;
}

our sub none_(@vs) {
    Junction[ JNone, @vs].new;
}
```

To apply a (single-argument) function to a junction argument

```perl6
sub infix:<●○>( &f, \j ) is export {
    my \jt=j.junction-type; 
    my @vs = j.values;
  
    Junction[ jt, map( {&f($_)}, @vs)].new;
}
```

To apply a function inside a junction to a non-junction an argument

```perl6
sub infix:<○●>( \jf, \v ) is export {
    my \jt=jf.junction-type; 
    my @fs = jf.values;

    Junction[ jt, map( {$_( v)}, @fs)].new;
}
```

To apply a function to two junction arguments is equivalent to applying a function inside a junction to a junction. There is a complication here: Raku imposes an ordering on the nesting such that `all` is always the outer nest. Therefore we must check the types of the junctions and swap the maps if required. 

```perl6
sub infix:<○○>( \jf, \jv ) is export {
    my \jft= jf.junction-type; 
    my @fs = jf.values;
    my \jvt = jv.junction-type;
    my @vs = jv.values;
    if (jvt == JAll and jft != JAll) {        
        Junction[ jvt, map( sub (\v){jf ○● v}, @vs)].new;  
    } else {        
        Junction[ jft, map( sub (&f){ &f ●○ jv}, @fs)].new;
    }
}
```

For completeness, here is the definition of `○==●`. Definitions of `○!=●`, `○>●`. etc are analogous.

```perl6
sub infix:< ○==● >( \j, \v ) is export {
    sub (\x){x==v} ●○ j
}
```

Next we have `so`, which turns a junction of Booleans into a Boolean:

```perl6
our sub so (\jv) { 
    my @vs = jv.values;
    given jv.junction-type {
        when JAny { elems(grep {$_},  @vs) >0}
        when JAll { elems(grep {!$_}, @vs)==0}
        when JOne { elems(grep {$_},  @vs)==1}
        when JOne { elems(grep {$_},  @vs)==0}
    }
}
```

And finally we have `collapse`, as defined in [the article on greedy junctions]({{site.url}}/articles/greedy-junctions). `collapse` returns the value form a junction provided they are all the same:

```perl6
our sub collapse( \j ) {
    my \jt=j.junction-type; 
    my @vvs = j.values;
    my $v =  shift @vvs;        
    my @ts = grep {!($_ ~~ $v)}, @vvs;
    if (@ts.elems==0) {  
        $v
    } else {
        die "Can't collapse this Junction: elements are not identical: {$v,@vvs}";
    }
}
```


## Junctions desugared

Let's now look at our working hypothesis again, the interpretation of actions on Raku's junctions as syntactic sugar for the above type and operators.  

```perl6
sub sq(Int $x --> Int) { $x*$x }
my Junction $j = 11 | 22; 
my Junction $rj = sq($j); 
```

Desugared this becomes:

```haskell
my Junction $j = any_ [11,22];
my Junction $rj = &sq ●○ $j;
```

Similarly, 

```perl6
if ($j == 42) {...} 
```

becomes

```
if (so ($j ○==● 42)) {...}
```

and similar for other Boolean contexts. 

If we look closer at [the pair example from the greedy junctions article]({{site.url}}/greedy-junctions), then applying a junction to a function with multiple arguments 

```perl6
my Junction \p1j = pair R,(42^43);
```

is desugared as

```perl6
my Junction \p1j = &pair.assuming(R) ●○ one_ [42,43];
```

We use `.assuming()` because we need partial application. It does not matter whether we apply first the non-junction argument or the junction argument:

```perl6
my \p1jr = ( sub ($y){ &pair.assuming(*,$y) } ●○ one_ [42,43] ) ○● R;
```

Finally, an example where both arguments are junctions. Because of the definition of `○○`, the order of application does not matter.

```perl6
sub m(\x,\y){x*y}

my \p4 = ( sub (\x){ &m.assuming(x) } ●○ any_ [11,22] ) ○○ all_ [33,44];
my \p4r = ( sub (\x){ &m.assuming(*,x) } ●○ all_ [33,44] ) ○○ any_ [11,22];
```


## Conclusion

Starting from the hypothesis that the magic typing behaviour of Raku's junctions is actually syntactic sugar, I have reconstructed the Junction type and its actions using a polymorphic algebraic data type operating on functions via a set of higher-order functions. I have shown that the interpretation of Raku's behaviour as syntactic sugar holds for the presented implementation. In other words, Raku's Junctions do follow static typing rules.