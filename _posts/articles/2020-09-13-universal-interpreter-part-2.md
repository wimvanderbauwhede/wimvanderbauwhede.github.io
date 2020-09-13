---
layout: article
title: "A Universal Interpreter (Part 2)"
date: 2020-09-13
modified: 2020-09-13
tags: [ coding, hacking, programming, raku ]
excerpt: ""
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



## An interpreter and pretty printer for a polynomial expression

Now that we have seen how simple sum and product types are BB-encoded, let's try something more complex: a parser and interpreter for expressions of the form `a*x^2+b*x+c`. 

### Parse tree algebraic data type 

The algebraic data type for the parse tree for expressions like this in Haskell:

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

We can write a pretty-printer for this type using `multi sub`s. The routine is recursive because the `Pow`, `Add` and `Mult` constructors take arguments of type  `Term`, i.e. the algebraic data type itself is recursive. 

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

### Parse tree BB encoding 

The BB encoding of `Term` in Raku is pleasingly compact:

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

We could of course use this type directly, but let's look at how we can convert between `Term` and `TermBB`

As before, we create our little helpers. Each of the functions below generates the `TermBB` instance for the corresponding alternative in the `Term` algebraic data type. 
When Raku's macro language is more developed, we will be able to generate these automatically.

```perl6
sub _var(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { v.(s) }
    ].new;
    }
sub _par(Str \s --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { c.(s) }
    ].new;
    }
sub _cons(Int \i --> TermBB) { 
    TermBB[ 
        sub (\v, \c, \n, \p, \a, \m) { n.(i) }
    ].new;
    }    
sub _pow( TermBB \t, Int \i --> TermBB) {
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        p.( t.unTermBB( v, c, n, p, a, m ), i);
    }
    ].new;
}
sub _add( @ts --> TermBB) { # Note about why @ and not Array[TermBB] \ ?? Or better, do this right and use typed-map after all!
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        a.( map {$_.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}
sub _mult(  @ts --> TermBB) { 
    TermBB[  sub (\v, \c, \n, \p, \a, \m) { 
        m.( map {$_.unTermBB( v, c, n, p, a, m )}, @ts )
    }
    ].new;
}
```

The interesting generators are `_pow`, `_add` and `_mult` because they are recursive. In `_pow`, the function passed as parameter to the TermBB role constructor calls `p` which has a signature of `:(Any,Int --> Any)`, but actually requires an argument of the same type as the return value. Using Haskell notation, we need `a -> Int -> a`. The argument `t`  is of type `TermBB` which is a wrapper around a function which, when applied, will return the right type. In the Raku implementation, this function is the method `unTermBB`. So we need to call `t.unTermBB( ... )`.
In `_add` and `_mult`, we have an `Array[TermBB]` so we need to call `unTermBB` on every element, hence the `map` call.

Using these generators we can write a single function to convert the algebraic data type into its BB encoding. Unsurprisingly, it is very similar to the pretty-printer and evaluator we wrote for `Term` instances:

```perl6
# Turn a Term into a BB Term
multi sub termToBB(Var \t) { _var(t.var)}
multi sub termToBB(Par \c) { _par( c.par)}
multi sub termToBB(Const \n) {_cons(n.const)}
multi sub termToBB(Pow \pw){ _pow( termToBB(pw.term), pw.exp)}
multi sub termToBB(Add \t) { _add( map {termToBB($_)}, |t.terms)}
multi sub termToBB(Mult \t){ _mult(map {termToBB($_)}, |t.terms)}
```

Because `_pow`, `_add` and `_mult` require a `TermBB`, we need to call `termToBB` on the `Term` fields. And because  `_add` and `_mult` take an array of `Term`,  we need a `map`.


### Example parse trees 

As an example, let's create the parse tree for a few expressions. Each of them uses the role-based algebraic data type `Term` defined above.

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

say qterm.raku;
```

Now convert this into the BB encoding:

```perl6
my \qtermbb = termToBB( qterm);

say qtermbb.raku;
```

### Interpreter 1: Pretty-printer with BB encoding

To create a pretty-printer for the BB-encoded type, we write very simple implementations for each alternative, and the `unTermBB` call magically combines these. There is no explicit recursion because that is handled in the type itself.

```perl6
# A pretty-printer
sto ppTmBB(TermBB \t --> Str){ 
        sub var( \x ) { x }
        sub par( \x ) { x }
        sub const( $x ) { "$x" }
        sub pow( \t, $m ) { t ~ "^$m" } 
        sub add( \ts ) { "("~join( " + ", ts)~")" }
        sub mult( \ts ) { join( " * ", ts) }
        t.unTermBB( &var, &par, &const, &pow, &add, &mult);
}
```

### Interpreter 2: Evaluator with BB encoding

And an evaluator is equally simple:

```perl6
# evalTermBB :: H.Map String Int -> H.Map String Int -> TermBB -> Int
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

### Interpreter 3: Pretty-printer and evaluator combined

Now we can do one better and combine these two interpreters. 

```perl6
sub evaltodppTmBB(%vars,  %pars, TermBB \t ){ 
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

Because a converter from `TermBB` to `Term` is yet another type of interpreter, we can follow exactly the same approach as  before. The only slight complication is that the type of `ts` is not 

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