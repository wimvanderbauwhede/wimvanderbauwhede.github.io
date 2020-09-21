---
layout: article
#title: "A Universal Interpreter (Part 1)"
title: "Encoding types as functions in Raku"
date: 2020-09-12
modified: 2020-09-12
tags: [ coding, hacking, programming, raku ]
excerpt: "The Böhm-Berarducci encoding is a way to express an algebraic data type as a function type. We show how to do this in Raku using roles."
current: ""
current_image: universal-interpreter-part-1_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: universal-interpreter-part-1_1600x600.jpg
  teaser: universal-interpreter-part-1_400x150.jpg
  thumb: universal-interpreter-part-1_400x150.jpg
---


This is the first part of an article in my series about functional programming in general and algebraic data types and function types in particular in [Raku](https://raku.org/). It builds on my earlier articles on [algebraic data types in Raku]({{site.url}}/articles/roles-as-adts-in-raku/) and their use in the practical example of [list-based parser combinators]({{site.url}}/articles/list-based-parser-combinators/). It also makes heavily use of [function types]({{site.url}}/articles/function-types).

If you are not familiar with functional programming or with Raku, I suggest you read my introduction ["Cleaner code with functional programming"]({{site.url}}/articles/decluttering-with-functional-programming/). If you are not familiar with algebraic data types or function types, you might want to read the other articles as well. 

In this article, I want to explain a technique called [Böhm-Berarducci encoding](http://okmij.org/ftp/tagless-final/course/Boehm-Berarducci.html) of algebraic data types. The link above is to Oleg Kiselyov's explanation, which makes for interesting reading but is not required for what follows. Oleg says:

_"Boehm-Berarducci's paper has many great insights. Alas, the generality of the presentation makes the paper very hard to understand. It has a Zen-like quality: it is incomprehensible unless you already know its results."_

Fortunately, to follow the explanation in this article, you don't need to read either Böhm and Berarducci's  original paper or Oleg's explanation. For the purpose of this article, it is sufficient to say that the Böhm-Berarducci encoding is a way to encode an algebraic data type as a function type. This means that the data itself is also encoded as a function. As a result, the function encoding the data type becomes a "universal interpreter". This makes it is easy to create various interpreters for algebraic data types. 

In this first part, I will explain a way to implement Böhm-Berarducci (BB) encoding using roles in Raku, with basic examples. In [the second part]({{site.url}}/articles/universal-interpreter-part-2) I will show how to use BB encoding to construct a 'universal interpreter' which makes it very easy to create specific interpreters for complex data structures. 

## The basic idea behind the Böhm-Berarducci encoding

The basic idea behind the Böhm-Berarducci (BB) encoding is to create a type which represents a function with an argument for every alternative in a sum type.
Every argument is itself a function which takes as arguments the arguments of each alternative product type, and returns a polymorphic type. Because the return type is polymorphic, we decide what it will be when we use the BB type. In this way a BB-encoded data structure is a generator for whatever type we like, in other words it is a universal interpreter. 

For example, if we define a sum type `S` with three alternatives `A1`, `A2` and `A3`, using the same notation as in the article on [algebraic data types in Raku]({{site.url}}/articles/roles-as-adts-in-raku/):

```haskell
datatype S = A1 Int | A2 String Bool | A3
```

then the corresponding BB type will be

```haskell
datatype S = S ( ∀ a .
    -- A1 Int
    (Int ⟶ a) ⟶ 
    -- A2 String
    (String ⟶ Bool ⟶ a) ⟶ 
    -- A3
    (a) ⟶ 
    -- The return type
    a
    )
```

I have put parentheses to show which part of the type is the function type corresponding to each alterative. 
Because the constructor for `A3` takes no arguments, the corresponding function signature in the BB encoding is simply `a`: a function which takes no arguments and returns something of type `a`. The final `a` is the return value of the top-level function: every type alternative is an argument to the function. When applying the function, it must return a value of a given type. This type is `a` because `a` is the return type of every function representing an alternative. I will explain the `∀ a .` later.

## Some simple examples

Let's look at a few examples to see how this works in practice.

### OpinionatedBool: an enum-style sum type

In a [previous post]({{site.url}}/articles/roles-as-adts-in-raku/) I showed how you can use Raku's _role_ feature to implement algebraic data types. I gave the example of 
`OpinionatedBool`:

```haskell
datatype OpinionatedBool = AbsolutelyTrue | TotallyFalse
```

which in Raku becomes

```perl6
role OpinionatedBool {}
role AbsolutelyTrue does OpinionatedBool {}
role TotallyFalse does OpinionatedBool {}
```

This is a sum type with two alternatives. 

The type declaration of the BB type lists the types of all the arguments representing the alternatives. As in this case the constructors for the alternatives take no arguments, the corresponding functions also take no arguments:

```haskell
datatype OpinionatedBoolBB = OpinionatedBoolBB (
    ∀ a . 
      a -- AbsolutelyTrue
    ⟶ a -- TotallyFalse
    ⟶ a
)
```

In [Haskell](https://haskell.org), we would implement this type as follows:

```haskell
newtype OpinionatedBoolBB = OpinionatedBoolBB {
    unBoolBB :: forall a . 
       a -- AbsolutelyTrue
    -> a -- TotallyFalse
    -> a
}
```

You don't need to know any Haskell for what follows, but as the Raku implementation is closely modeled on the Haskell one, it is worth explaining a bit.
The `newtype` keyword in Haskell is used to declare types with a single constructor. What we have here is a record type with a single field, and this field has the accessor function `unBoolBB`, which is a convenience to allow easy access to the function encoded in the type. The `∀ a`  or `forall a` allows us to introduce a type parameter that is only in scope in the expression on the right-hand side. Because the Haskell notation is so close to the formal notation, I will from now on use the Haskell notation.

In Raku, we can implement this  BB type minimally as a parametric role with a method with a typed signature:

```perl6    
role BoolBB[&b] {
    method unBoolBB(Any \t, Any \f --> Any) {
        b(t,f);
    }
}
```    

This tells us a lot:

- the parameter to the role has an `&` sigil so it of type `Callable` (i.e. it is a function)
- the method's type tells us that there are two arguments of type `Any`. The method itself also returns a value of type `Any`, i.e. there is no constraint on the type of the return value. 

With this implementation, the type safety is not quite as strong as in Haskell, where we guarantee that all these return values will be of the same type. The main purpose for using the types here is to make it provide documentation. We can enforce the type safety at a different point if desired.

Now, the whole idea is that this role `BoolBB` will serve the same purpose as my `OpinionatedBool`. So instead of saying

```perl6
my OpinionatedBool \trueOB = AbsolutelyTrue;
```

I want something like 

```perl6
my BoolBB \trueBB = BBTrue;
```

So in this example, `BBTrue` will be an instance of `BoolBB` with a specific function as parameter. Let's call that function `true`, so we have

```perl6
my \BBTrue = BoolBB[ true ].new;
```

and similar for the `false` case. We can make this a little nicer using a helper function to create `BoolBB` instances:

```perl6
sub bbb(\tf --> BoolBB) { BoolBB[ tf ].new };
```

In this way we can write

```perl6
sub BBTrue { bbb true } 
sub BBFalse { bbb false }
```

In this particular case, because none of the constructors takes any arguments, we can also write this as

```perl6
my BoolBB \BBTrue = bbb true;
my BoolBB \BBFalse = bbb false;
``` 

<!-- ∀ -->
The question is then: what are the functions `true` and `false`? We know they are of type `a ⟶ a ⟶ a`; an obvious choice is:

```perl6
my \true  = -> Any \t, Any \f --> Any { t }
my \false = sub (Any \t,Any \f --> Any ) { f }
```

This is the same choice we made in [the article "Everything is a function"]({{site.url}}/articles/everything-is-a-function/). In fact, these are simply _selector_ functions which select the first or second argument. 

In practice, we often want to convert between BB types and their algebraic counterparts.

- To turn a Bool into a BoolBB:

```perl6
sub boolBB (Bool \tf --> BoolBB){ tf ?? BBTrue !! BBFalse }
```

- To turn the BB Boolean into an actual Boolean:

```perl6
sub bool(BoolBB \b --> Bool) { 
    b.unBoolBB( True, False) 
}
```

So we have:

```perl6
say bool BBTrue; # => True
say bool BBFalse; # => False
say bool boolBB( bool BBTrue); # => True
say bool boolBB( bool BBFalse); # => False
```

(Note that this works with either way of defining `BBTrue` and `BBFalse` because calling a function without arguments in Raku does not require parentheses.)

We can do this more OO-like by making `bool` a method of `BoolBB`:

```perl6    
role BoolBB[&b] {
    method unBoolBB(Any \t, Any \f --> Any) {
        b(t,f);
    }

    method bool() { 
        self.unBoolBB( True, False) 
    }
}
```    
Then we can say

```perl6
say  BBTrue.bool; # => True
say  BBFalse.bool; # => False
say  boolBB( bool BBTrue).bool; # => True
say  boolBB( bool BBFalse).bool; # => False
```

and I'm sure those dots will make some people happy.

Note however that we do not really need the `bool` method, instead we can simply compare the types:

```perl6
say  trueBB ~~ BBTrue; # => True
say  BBFalse ~~ trueBB; # => False
```

We can generalise this approach as an alternative to arbitrary enums. For example, and `RGB` enum can be written very easily as a BB type:

```perl6    
role RGB[&b] {
    method unRGB(Any \r, Any \g, Any \b --> Any) {
        b(r,g,b);
    }
}
```

with selector functions 

```perl6
my \red  = -> \r,\g,\b { r }
my \green = -> \r,\g,\b { g }
my \blue = -> \r,\g,\b { b }
```

However, the main reason for using BB types is to make it easier to perform computations on the data structure encoded in the type. Constant sum types like `Bool` and `RGB` don't store data to compute on, except in the most trivial way, and are therefore not the main target of this encoding. I presented them only because they are the easiest ones to explain.

The [second part]({{site.url}}/articles/universal-interpreter-part-2) of the article presents a worked example. But first, let's look at a few more simple examples explaining more features of the BB approach.

### The `Maybe` type: a sum type with a polymorphic argument

The Boolean type above had two constructors without arguments. A simple algebraic data type where one of the constructors has an argument is the `Maybe` type:

```haskell
data Maybe b = Just b | Nothing
```

This type is used to express that a function does not always return a value of a given type. For example, if we look up a key in a map, it is possible that there is no entry for that key. So using `Maybe` we could write a safe lookup function:

```perl6
sub safeLookup(%v,$k --> Maybe) {
    if  (%v{$k}:exists) {
        Just[%v{$k}].new;
    } else {
        Nothing;
    }
}
```

The `Maybe` type is polymorphic, so we have instances of `Maybe` for any type we like.  In Haskell:

```haskell
newtype MayBB b = MayBB {
unMayBB :: forall a .  
(b -> a) -- Just b 
-> a -- Nothing 
-> a
```

and in Raku:

```perl6
role MayBB[ &mb ] {
    method unMayBB(
        &j:(Any --> Any),
        Any \n 
        --> Any
    ) {
        mb(&j,n);
    }
}
```

We use a `Callable` (`&j`) for the `Just` variant but a (sigil-less) scalar (`\n`) for the `Nothing` as it is a constant.

As before for the BB Boolean, we create some helper functions. 

- First we have the _selectors_:

```perl6
# selectors
sub bbj( \x ) { -> &j:(Any --> Any), Any \n --> Any { &j(x)} }
sub bbn { -> &j:(Any --> Any),Any \n --> Any {n} }
```

- Then we have a wrapper to make role construction nicer:

```perl6
sub mbb (&jm --> MayBB) {
    MayBB[ &jm ].new;
}
```

- With these we can easily write the final BB type constructors:

```perl6
sub Just(\v) { mbb bbj(v) }
sub Nothing { mbb bbn }
```

Now we can create values of our `MayBB` type, e.g.

```perl6
my MayBB \mbb = Just 42;
my MayBB \mbbn = Nothing;
```

As you can see, the BB type now functions exactly as an ordinary algebraic data type.

Let's make a simple printer for this type:

```perl6
sub printMayBB(MayBB \mb --> Str) {
    mb.unMayBB( sub (Any \x --> Str) { "{x}" }, 'NaN' );
}

say printMayBB mbb; # => 42
say printMayBB mbbn; # => NaN
```

As before, this function could be made a method of the `MayBB` role if desired. The point to note however is that to create this printer, all we had to do was provide the right arguments to `unMayBB`. We chose the concrete type `Str` for the type parameter in the BB type. Recall that to turn the BB Boolean into an actual Boolean, all we had to do was to provide arguments of type `Bool` to `unBoolBB`. These are simple examples that already illustrate some of the power of the BB encoding.

### A pair, the simplest product type

The two previous examples were for sum types. Let's look at a simple product type, a pair of two values also known as a tuple. Assuming the tuple is polymorphic with type parameters `t1` and `t2`, the BB type is in Haskell:

```haskell
newtype PairBB t1 t2 = PairBB {
    unPairBB :: forall a . (t1 -> t2 -> a) -> a
}
```

and in Raku:

```perl6
role PairBB[ &p ] {
    method unPairBB(&p_:(Any,Any --> Any)  --> Any) {
        p(&p_);
    }
}
```

The selectors (for convenience we reuse the `true` and `false` functions used for the `BoolBB`):

```perl6
# To get the elements out of the pair
sub fst( \p ){ p.unPairBB(true) }
sub snd( \p ){ p.unPairBB(false) }
```

The pair constructor takes the values `x` and `y` to be put in the pair, and uses them in an anonymous function used as the parameter for the role. The single argument of this anonymous function is a selector function `&p`, which is applied to `x` and `y` in its body. 

```perl6
# Final pair constructor
sub Pair(\x,\y --> PairBB) {
    PairBB[ -> &p { p(x, y) } ].new;
}
```
We can use this to build pairs e.g.

```perl6
my PairBB \bbp = Pair 42,"forty-two";

# print it
say "({fst bbp},{snd bbp})"; # => (42,forty-two)
```

As with the Boolean, we can do this a bit more OO-like if you prefer by making `fst` and `snd` methods of the `PairBB` role:

```perl6
role PairBB[ &p ] {
    method unPairBB(&p_:(Any,Any --> Any)  --> Any) {
        p(&p_);
    }

    # To get the elements out of the pair
    method fst( ){ self.unPairBB(true) }
    method snd( ){ self.unPairBB(false) }
}
```

Thus we can say

```perl6
say "({bbp.fst },{bbp.snd})"; # => (42,forty-two)
```

An important point is that the BB-encoded data structures are immutable, so you can't update a field. Instead, you create a new variable:

```perl6
my PairBB \pbb2 = Pair fst(pbb) + 1, 'forty-three';
```

Now, let's assume for a moment that our `PairBB` represents a complex number and we want to convert it from (Real, Imaginary) into polar form (Modulus, Phase). Again we can use the same approach:

```perl6
sub toPolar(PairBB \mb --> PairBB) {
    mb.unPairBB( sub (Any \x,Any \y --> PairBB) {
        Pair sqrt(x*x+y*y),atan2(x,y);
    } );
}
```

## Summary

What we have learned so far is how to create sum (alternative) and product (record) types in Raku using a formalism called Böhm-Berarducci (BB) encoding, which uses functions to create data structures. We use Raku's roles to implement BB types, and I have illustrated this with three simple examples: a sum type with two alternative constructors that do not take arguments (a Boolean), a sum type with two alternative constructors where one of them takes an argument (the Maybe type) and a product type for a pair of two values. 

In [the next part]({{site.url}}/articles/universal--part-2), we will see how BB types make it easy tointerpreter create interpreters for complex data structures.

The complete code for both articles is in [universal-interpreter.raku](https://github.com/wimvanderbauwhede/raku-examples/blob/master/universal-interpreter.raku).