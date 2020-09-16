---
layout: article
title: "A universal interpreter"
date: 2020-09-13
modified: 2020-09-13
tags: [ coding, hacking, programming, raku ]
excerpt: "The Böhm-Berarducci encoding of a type can be considered as a universal interpreter. We illustrate this in Raku with an evaluator and pretty printer."
current: ""
current_image: universal-interpreter-part-2_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: universal-interpreter-part-2_1600x600.jpg
  teaser: universal-interpreter-part-2_400x150.jpg
  thumb: universal-interpreter-part-2_400x150.jpg
---

In [the previous article]({{site.url}}/articles/universal-interpreter-part-1) I explained the basic idea behind a technique called [Böhm-Berarducci encoding](http://okmij.org/ftp/tagless-final/course/Boehm-Berarducci.html) of algebraic data types, and showed a way to implement this technique in [Raku](https://raku.org/). Unless you are already familiar with this formalism, I recommend you read that article first. 

In this article I want to illustrate how the Böhm-Berarducci (BB) encoding of a data structure based on algebraic data types can be considered as a universal interpreter. What this means is that it is easy to perform computations that turn the data structure into something else. As an example, I will demonstrate how to create an evaluator and pretty-printer for a parsed polynomial expression.


## A parse tree type 

Consider expressions of the form `a*x^2+b*x+c` or `x^3+1` or `x*y^2-x^2*y`. Let's assume we have a parser for such an expression, for example built using [parser combinators]({{site.url}}/articles/list-based-parser-combinators/). Let's also assume that this parser returns the parsed data as an algebraic data type, defined in Haskell as:

```haskell
data Term = 
      Var String
    | Par String 
    | Const Int
    | Pow Term Int
    | Add [Term]
    | Mult [Term]
```
and in Raku:

```perl6
role Term {}
role Var [Str \v] does Term {
    has Str $.var = v;
}
role Par [Str \p] does Term {
    has Str $.par = p;
}
role Const [Int \c] does Term {
    has Int $.const = c;
}
role Pow [Term \t, Int \n] does Term {
    has Term $.term = t;
    has Int $.exp = n;
}
role Add [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}
role Mult [Array[Term] \ts] does Term {
    has Array[Term] $.terms = ts;
}
```

The additional complexity compared to the types discussed in [the previous article]({{site.url}}/articles/universal-interpreter-part-1) is that this type is recursive. 

Before we look at the BB encoding, let's first write a pretty-printer for this type, using `multi sub`s. The routine is recursive because the `Pow`, `Add` and `Mult` constructors are recursive. 

```perl6
# Pretty-print a Term 
multi sub ppTerm(Var \t) { t.var }
multi sub ppTerm(Par \c) { c.par }
multi sub ppTerm(Const \n) { "{n.const}" }
multi sub ppTerm(Pow \pw){ ppTerm(pw.term) ~ '^' ~ "{pw.exp}" }
multi sub ppTerm(Add \t) { 
    my @pts = map {ppTerm($_)}, |t.terms;
    "("~join( " + ", @pts)~")"
}
multi sub ppTerm(Mult \t){ 
    my @pts = map {ppTerm($_)}, |t.terms;
    join( " * ", @pts)
}
```

In the same way we can write an evaluator for this type:

```perl6
# Evaluate a Term 
multi sub evalTerm(%vars,  %pars, Var \t) { %vars{t.var} }
multi sub evalTerm(%vars,  %pars,Par \c) { %pars{c.par} }
multi sub evalTerm(%vars,  %pars,Const \n) { n.const }
multi sub evalTerm(%vars,  %pars,Pow \pw){ evalTerm(%vars,  %pars,pw.term) ** pw.exp }
multi sub evalTerm(%vars,  %pars,Add \t) { 
    my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
    [+] @pts
}
multi sub evalTerm(%vars,  %pars,Mult \t){ 
    my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
    [*] @pts
}
```

### Example parse trees 

As an example, let's create the parse tree for a few expressions using the `Term` type.

```perl6
# a*x^2 + b*x + x
my \qterm1 = Add[ 
    Array[Term].new(
    Mult[ Array[Term].new(Par[ "a"].new, Pow[ Var[ "x"].new, 2].new) 
        ].new,
    Mult[
        Array[Term].new(Par[ "b"].new, Var[ "x"].new) 
        ].new,
    Par[ "c"].new
    )
    ].new;

#   x^3 + 1    
my \qterm2 = Add[ 
    Array[Term].new(
    Pow[ Var[ "x"].new, 3].new, 
    Const[ 1].new
    )
    ].new;

#   qterm1 * qterm2    
my \qterm = Mult[ 
    Array[Term].new(
        qterm1, qterm2
    )
    ].new;
```

Calling the pretty-printer and evaluator on this term: 

```perl6
say ppTerm( qterm); # => (a * x^2 + b * x + c) * (x^3 + 1)

say evalTerm(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qterm
); # => 162
```

## BB encoding of the parse tree type  

The BB encoding of the `Term` algebraic data type in Raku is pleasingly compact:

```perl6
role TermBB[&f] {
    method unTermBB(
        &var:(Str --> Any),
        &par:(Str --> Any),
        &const:(Int --> Any),
        &pow:(Any,Int --> Any),
        &add:([Array[Any] --> Any),
        &mult:([Array[Any] --> Any) 
        --> Any
    ) {
        f(&var,&par,&const,&pow,&add,&mult);
    }
}
```

We could of course use this type directly, but instead I want to look at how we can convert between `Term` and `TermBB`. 

As before, we create our little helpers. Each of the functions below is a constructor wich generates the `TermBB` instance for the corresponding alternative in the `Term` algebraic data type. 
When Raku's macro language is more developed, we will be able to generate these automatically.

```perl6
sub VarBB(Str \s --> TermBB) { 
    mkTermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new;
    }
sub ParBB(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new;
    }
sub ConstBB(Int \i --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { n.(i) }
    ].new;
    }    
sub PowBB( TermBB \t, Int \i --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
sub AddB( Array[TermBB] \ts --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {.unTermBB( v, c, n, p, a, m )}, ts )
    }
    ].new;
}
sub MultBB(  Array[TermBB] \ts --> TermBB) { 
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {.unTermBB( v, c, n, p, a, m )}, ts )
    }
    ].new;
}
```

The interesting generators are `PowBB`, `AddBB` and `MultBB` because they are recursive. In `PowBB`, the function passed as parameter to the `TermBB` role constructor calls `p` which has a signature of `:(Any,Int --> Any)`, but actually requires an argument of the same type as the return value (we need `a -> Int -> a`). The argument `t`  is of type `TermBB` which is a wrapper around a function which, when applied, will return the right type. In the Raku implementation, this function is the method `unTermBB`. So we need to call `t.unTermBB( ... )`.
In `AddBB` and `MultBB`, we have an `Array[TermBB]` so we need to call `unTermBB` on every element, hence the `map` call.

Using these generators we can write a single function to convert the algebraic data type into its BB encoding. Unsurprisingly, it is very similar to the pretty-printer and evaluator we wrote for `Term` instances:

```perl6
# Turn a Term into a BB Term
multi sub termToBB(Var \t  ) { VarBB(t.var)}
multi sub termToBB(Par \c  ) { ParBB( c.par)}
multi sub termToBB(Const \n) {ConstBB(n.const)}
multi sub termToBB(Pow \pw ) { PowBB( termToBB(pw.term), pw.exp)}
multi sub termToBB(Add \t  ) { AddBB( typed-map( TermBB, t.terms, &termToBB ))}
multi sub termToBB(Mult \t ) { MultBB( typed-map( TermBB, t.terms, &termToBB ))}

sub typed-map (\T,\lst,&f) {
    Array[T].new(map {f($_) }, |lst )
}
```

Because `PowBB`, `AddBB` and `MultBB` require a `TermBB`, we need to call `termToBB` on the `Term` fields. And because  `AddBB` and `MultBB` take an array of `Term`,  we need a `map`. However, Raku's `map` returns values of type `Seq`, so we need an explicit conversion into `Array`.


We can now convert any data structure of type `Term` into its BB encoding:

```perl6
my \qtermbb = termToBB( qterm);

say qtermbb.raku; # => TermBB[Sub].new
```

### Interpreter 1: Pretty-printer with BB encoding

To create a pretty-printer for the BB-encoded type, we write implementations for each alternative, and the `unTermBB` call magically combines these.

```perl6
sub ppTermBB(TermBB \t --> Str){ 
    sub var( \x ) { x }
    sub par( \x ) { x }
    sub const(\x ) { "{x}" }
    sub pow( \t, \m ) { t ~ "^{m}" } 
    sub add( \ts ) { "("~join( " + ", ts)~")" }
    sub mult( \ts ) { join( " * ", ts) }
    t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}
```

 Compared with `ppTerm` (copied below for convenience), the main differences are that there is no recursion and no need to `map` anything. We also don't need a `multi sub` to pattern match on the constructors, and there is no need to unpack the values stored in the type using attribute accessors. As a result, the BB version is markedly less cluttered.

```perl6
multi sub ppTerm(Var \t --> Str) { t.var }
multi sub ppTerm(Par \c --> Str) { c.par }
multi sub ppTerm(Const \n --> Str) { "{n.const}" }
multi sub ppTerm(Pow \pw --> Str){ ppTerm(pw.term) ~ '^' ~ "{pw.exp}" }
multi sub ppTerm(Add \t --> Str) { 
    my @pts = map {ppTerm($_)}, |t.terms;
    "("~join( " + ", @pts)~")"
}
multi sub ppTerm(Mult \t --> Str){ 
    my @pts = map {ppTerm($_)}, |t.terms;
    join( " * ", @pts)
}
```

### Interpreter 2: Evaluator with BB encoding

And an evaluator is equally simple:

```perl6
sub evalTermBB( %vars,  %pars, \t) {
    t.unTermBB( 
        -> \x { %vars{x} }, 
        -> \x { %pars{x} },
        -> \x {x},
        -> \t,\m { t ** m},
        -> \ts { [+] ts},
        -> \ts { [*] ts}
    );
}
```

As with `evalTerm` below, we pass hashes for variable and parameter definitions as arguments to provide context for the evaluation. In the BB version we need to do this only once, rather than for every multi variant, so I have written it below using a `given/when`. Even then, the BB version is a lot cleaner, for the same reasons as above. 

```perl6
sub evalTerm(%vars,  %pars, Term \t) {
    given t {
        when Var { %vars{t.var} }
        when Par { %pars{t.par} }
        when Const { t.const }
        when Pow { evalTerm(%vars,  %pars,t.term) ** t.exp }
        when Add {
            my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
            [+] @pts
        }
        when Mult { 
            my @pts = map {evalTerm(%vars,  %pars,$_)}, |t.terms;
            [*] @pts
        }
    }
}
```

### Interpreter 3: Pretty-printer and evaluator combined

Now we can do one better and combine these two interpreters.

```perl6
sub evalAndppTermBB(%vars,  %pars, TermBB \t ){ 
    t.unTermBB( 
        -> \x {[%vars{x},x]}, 
        -> \x {[%pars{x},x]},
        -> \x {[x,"{x}"]},
        -> \t,\m {[t[0] ** m, t[1] ~ "^{m}"] },
        -> \ts { 
            my \p = 
                reduce { [ $^a[0] + $^b[0], $^a[1] ~ " + " ~ $^b[1]] }, ts[0],  |ts[1..*];
            [ p[0], "("~p[1]~")" ]; 
        }, 
        -> \ts { 
            reduce { [ $^a[0] * $^b[0], $^a[1] ~ " * " ~ $^b[1]] }, ts[0],  |ts[1..*]
        }
    )
}

say ppTermBB( qtermbb);
say evalTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
say evalAndppTermBB(
    {"x" => 2}, {"a" =>2,"b"=>3,"c"=>4},  qtermbb
);
```

### Interpreter 4: Converting `TermBB` to `Term`

Because a converter from `TermBB` to `Term` is yet another type of interpreter, we can follow exactly the same approach as before. 

```perl6
sub toTerm(TermBB \t --> Term){ 
        sub var( \x ) { Var[x].new }
        sub par( \x ) { Par[x].new }
        sub const( $x ) { Const[$x].new }
        sub pow( \t, $m ) { Pow[ t, $m].new } 
        sub add( \ts ) { Add[ ts ].new }
        sub mult( \ts ) { Mult[ ts ].new) }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}

say toTerm(qtermbb).raku;
```



### Bonus: parsing the expression



```perl6
# This is for parsing into AST, the link between Term and the TaggedEntry
role TaggedEntry {}
role Val[Str @v] does TaggedEntry {
	has Str @.val=@v;
} 
# valmap :: [(String,TaggedEntry)]
role ValMap [  @vm] does TaggedEntry { #String \k, TaggedEntry \te,
	has @.valmap = @vm; 
}

multi sub taggedEntryToTerm (Var ,\val_strs) { Var[ val_strs.val.head].new }
multi sub taggedEntryToTerm (Par ,\par_strs) { Par[par_strs.val.head].new }
multi sub taggedEntryToTerm (Const ,\const_strs) {Const[ Int(const_strs.val.head)].new } 
# multi sub taggedEntryToTerm (Pow , ValMap [t1,(_,Val [v2])]) { Pow[ taggedEntryToTerm(...,....), Int(...)].new}        
# multi sub taggedEntryToTerm (Add , ValMap hmap) = Add $ map taggedEntryToTerm hmap
# multi sub taggedEntryToTerm (Mult , ValMap hmap) = Mult $ map taggedEntryToTerm hmap
my Str @val_strs = "42";
my \v = taggedEntryToTerm(Const, Val[@val_strs].new);
say v.raku; 
```