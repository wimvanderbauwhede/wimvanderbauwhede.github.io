---
layout: article
title: "Function types"
date: 2020-08-07
modified: 2020-08-07
tags: [ coding, hacking, programming, raku ]
excerpt: "A brief introduction into function types, with a way to implement them in Raku and examples in many languages."
current: "Function types"
current_image: function-types_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: function-types_1600x600.avif
  teaser: function-types_400x150.avif
  thumb: function-types_400x150.avif
---

This article builds on my earlier articles on [algebraic data types]({{site.url}}/articles/roles-as-adts-in-raku/) in on [Raku](https://raku.org/) and their use in the practical example of [list-based parser combinators]({{site.url}}/articles/list-based-parser-combinators/). 

In this article I want to look at function types in some detail, and show a way to create well typed functions in Raku. If you are not familiar with functional programming (or with [Raku](https://raku.org/)), I suggest you read my introduction ["Cleaner code with functional programming"]({{site.url}}/articles/decluttering-with-functional-programming/). If you are not familiar with algebraic data types, you might want to read the other two articles as well. For most of the article, I provide examples in Raku, Python, Rust and Haskell. There is also some C and even some Fortran. 

## Type signatures 

A function's type signature consists of the types of each of its arguments and the return type. In most typed languages, the type is part of the function signature. 

For example in C

```c
int sqsum(int,int);

int sqsum(int x, int y) {
    return x*x+y*y
};
```

or in Fortran

```fortran
integer function sqsum(x,y)
    integer :: x,y
    sqsum = x*x+y*y
end function
```

or in Rust

```rust
fn sqsum((x, y): (i32, i32)) -> i32 { x*x+y*y }

let sqsum  = |x : i32, y: i32| -> i32 {x*x+y*y};
```

or in Raku

```perl6
sub sqsum(Int, Int --> Int) {...}
sub sqsum(Int \x, Int \y --> Int) { x*x+y*y }

my &sqsum = sub (Int \x, Int \y --> Int) { x*x+y*y };
```

or in Python, using the `typing` module:

```python
from typing import Callable

def sqsum_(x: int, y: int) -> int:  
    return x*x+y*y

sqsum : Callable[[int,int], int]  = lambda x,y : x*x+y*y
```


## The type of a function of functions

But what happens if we want to provide a function argument that is itself a function, or return a function (so-called _higher-order functions_)?

This is possible in most languages, but what I am interested in is the type information: what is the type signature of such a function of functions?

C supports functions-of-functions indirectly through function pointers, by creating a function type through a `typedef`. 

```C
typedef int (*Fun)(int,int);

int ten_times (Fun f) {...};
```

Maybe surprisingly, venerable old Fortran does support passing functions and subroutines as arguments. Functions are typed by their return type; subroutines are not typed. 

```fortran
program fof 
    external :: sqsum
    call ten_times(sqsum)
end program fof

subroutine ten_times(f)
    integer :: f
    ! ...
end subroutine ten_times
```

In Rust you can provide the complete type of a function-as-argument: 

```rust
fn ten_times<F>(f: F) where F: Fn(i32,i32) -> i32 {
// ...
}

ten_times(sqsum);
```

In Python we can use `Callable`, which also allow for the complete type to be expressed.

```python
from typing import Callable

def ten_times(f: Callable[[int, int],int]) -> None:
# ...
```

The same example in Raku becomes

```perl6
sub ten_times (Sub \f:(Int,Int --> Int)) {
#...
}

ten_times(sqsum);
```

So we can also pass the complete type. An equivalent way to write this is using the `&` sigil [which imposes the `Callable` type constraint](https://docs.raku.org/language/variables#index-entry-sigil_&):

```perl6
sub ten_times (&f:(Int,Int --> Int)) {
#...
}
```

The types can be nested too, e.g. `((Int, Int --> Int), (Int, Int --> Int) --> Int))` is a valid type signature.

<!--


--------
fn main() {
 
    let sqsum  = |x : i32, y: i32| -> i32 {x*x+y*y};
    let res = sqsum(4,3);
 
    fn ten_times<F>(f: F  ) -> i3 where F: Fn(i32,i32) -> i32 {
        for index in 0..10 {
            let res = f(index,index+1);
            println!("{}",res);
        }
    }    
    ten_times(sqsum);
}

--------

from typing import Callable

sqsum : Callable[[int,int], int]  = lambda x,y : x*x+y*y
def sqsum_(x: int, y: int) -> int:  
    return x*x+y*y
res : int = sqsum(4,3)

def ten_times(f: Callable[[int, int],int]) -> int:
    for index in range(0,11):
        res = f(index,index+1)
        print(res)
    
ten_times(sqsum)

--------
-->

## Introducing the arrow

All of the above ways to express function type signatures are perfectly adequate in their respective languages. However, with the exception of Raku, they all share the problem that these function-of-function type signatures don't compose very well: what if we want to write a function-of-function-of-function type? This is less far-fetched than it may seem.
I would like to introduce a notation used in type theory. It is at the same time simple and powerful. If you are familiar with functional languages like Haskell, Idris or Agda, you already know it. 

Instead of mixing the type with the function declaration, it is written separately. The name of the function is followed by a colon and the list types of the arguments and the return value. Each argument is separated by an arrow. The above example of a function of two integer arguments returning an integer would be:

```haskell
sqsum : Int ⟶ Int ⟶ Int 
```

The function-of-a-function introduced above has as type:

```haskell
ten_times : (Int ⟶ Int ⟶ Int) ⟶  Int
```
The parentheses group the type of the function that is the only argument of `ten_times`.

In this notation, the arrow can be interpreted as an operator which creates a function type from the two types that are its arguments. The important property of this operator is that it is right associative. What this means is that for example 

```haskell
f : t1 ⟶ t2 ⟶ t3 ⟶ t4
```

is the same as

```haskell
f : t1 ⟶ t2 ⟶ (t3 ⟶ t4)
```

and as

```haskell
f : t1 ⟶ (t2 ⟶ t3 ⟶ t4)
```

and for completeness

```haskell
f : t1 ⟶ (t2 ⟶ (t3 ⟶ t4))
```

## A detour into partial application 

The above groupings imply that our function `f` can be interpreted in three ways, as a function of:

- 3 arguments of types `t1`,`t2`,`t3`, returning a result of type `t4`;
- 2 arguments of types `t1`,`t2`, returning a result of type `t3 -> t4`; 
- 1 argument of types `t1`, returning a result of type `t2->t3->t4`.

Let's say we have values `v1`,`v2`,`v3` for the arguments and `v4` as the result:

```haskell
v4 : t4
v4 = f v1 v2 v3
```

But suppose we only apply `v1` and `v2`:

```
pf1 : t3 ⟶ t4
pf1 = f v1 v2
```

We get a new function `pf1` which takes a single argument `v3`: 

```haskell
v4 = pf1 v3
```

And in the same way we can create `pf2` and `pf3`:

```haskell
pf2 : t2 ⟶ t3 ⟶t4
pf2 = f v1

pf3 : t3 ⟶ t4
pf3 = pf2 v2

v4 = pf3 v3
```

Because `pf1`, `pf2` and `pf3` are functions and the above is true for all values of `v1`, `v2`, `v3` and `v4`, it follows that

```haskell
pf3 == pf1
```

For completeness, we can also apply `pf2` directly to two arguments:

```haskell
v4 = pf2 v2 v3
```

This concept of creating a new function by not providing values for some of the arguments is called _partial application_, and many languages support it. Here are examples in Haskell, Raku, Python and Rust.

### Haskell

In case you are not familiar with Haskell, this is what you need to know: it is whitespace-sensitive like Python, but has a markedly different syntax. Because everything is a function, there is no keyword to mark a function. Because there is only lexical scope, there is no need for any special scope identifiers. Function arguments are separated by spaces. Lambda functions (anonymous functions) start with a `\`,  chosen because it looks a bit like the Greek letter lambda, λ. 

```haskell
-- named function of 2 arguments
sqsum x y = x*x+y*y
-- lambda function bound to a named variable
sqsum = \x y -> x*x+y*y
```

The type of `sqsum` is 
```haskell
sqsum :: Int -> Int -> Int
```
(Haskell uses `::` rather than `:` for the type signature)

In Haskell, partial application works exactly as in the examples above. So our function `sqsum` can be partially applied like this: 

```haskell
sqsum4 :: Int -> Int
sqsum4 = sqsum 4
```

We can apply `sqsum4` to the remaining argument:

```haskell
sqsum4 3 -- returns 25
```

This is very neat. But suppose you want to apply the second argument, rather than the first one? The Haskell Prelude library provides the function [flip](https://hackage.haskell.org/package/base-4.14.0.0/docs/Prelude.html#v:flip), which simply flips the arguments:

```haskell
flip :: (a -> b -> c) -> b -> a -> c 
flip f = \x y -> f y x
```

That is fine as far as it goes, but let's do a somewhat contrived example. Let's say we have a function of four arguments:

```haskell
g :: t1 -> t2 ->t3 ->t4 ->tr
g x1 x2 x3 x4 = x1*x3-x2*x4
```

and we want to apply the 1st and 4th argument but not the others, something like `g v1 _ _ v4`.

One way to do this is to create yet another function (of course!):

```haskell
apply14 :: (t1 -> t2 -> t3 -> t4 -> tr) -> t1 -> t4 -> (t2 -> t3 -> tr)
apply14 f x1 x4 = \x2 x3 -> f x1 x2 x3 x4
```

And with this function we can partially apply the 1st and 4th argument of `g`:

```haskell
g14 = apply14 g v1 v4
```

This example mainly serves to illustrate the power of the arrow-based function type notation: it lays out the type of `apply14` clearly and concisely. 

### Raku

Raku provides the method [assuming](https://docs.raku.org/routine/assuming), which acts as a generalised version of our `apply14`:

```perl6
my &g14 = &g.assuming( v1, *, *, v4);

g14(v2,v3); 
```

The return type of `assuming` is a `Callable`. This is a role for objects which support calling them. Thus, `g14` can be called as if it was a regular function.

### Python

Python's [functools](https://docs.python.org/2/library/functools.html) provide the `partial` function:

```python
from functools import partial
g14 = partial(g, x1=v1,x4=v4)

g14(v2,v3)
```

The return type of `partial` is a `partial` object, which has an attribute `partial.func`, a callable object or function. Calls to the partial object will be forwarded to func with new arguments and keywords, so you can say `g14(v2,v3)` instead of `g14.func(v2,v3)`.

### Rust

Rust provides the `partial!` macro via its [partial_application](https://docs.rs/partial_application/0.2.1/partial_application/) crate. Its behaviour is very similar to our `apply14`: "`partial!(some_fn => arg0, _, arg2, _)` returns the closure `|x1, x3| some_fn(arg0, x1, arg2, x3)`". 

```rust
#[macro_use]
extern crate partial_application;

fn g(x1: i32, x2: i32, x3: i32, x4: i32) -> i32 {
    x1*x3-x2*x4
}

fn main() {
    let v1=...;
    let v2=...;
    let v3=...;
    let v4=...;
    let g14 = partial!(g => v1, _, _, v4);

    g14(v2,v3)
}
```

## Back to the function types

Suppose we want a type like the one we defined in C using a `typedef`, which encapsulates the function type:

```c
typedef int (*Fun)(int,int);
```

In Haskell, that would be

```haskell
newtype Fun = Fun Int -> Int -> Int
```

and we can generalise this to be a generic function of two arguments by using type variables instead of concrete types:

```haskell
newtype Fun2Args a = Fun2Args a -> a -> a
```

So how would we use this? Let's create an instance

```haskell
ft :: Fun2Args a
ft = Fun2Args (\x y -> x*x+y*y)
```

This is fine, but to apply the function we first must unwrap the type constructor:

```haskell
((\(Fun2Args f) -> f) ft ) 3 4
```
That is not very handy. A better way is to use the record type syntax which gives us an accessor function:

```haskell
newtype Fun2Args a = Fun2Args { unF :: a -> a -> a}
ft = Fun2Args (\x y -> x*x+y*y)
(unF ft) 3 4
```

Now I have applied this to integer, but the type of the function is `Num a => a -> a -> a`, so this works for any type in the `Num` typeclass.

## Named function types for Raku

In Raku, we can follow a similar approach of wrapping a function signature in a type, and it is actually simpler than in Haskell. We create a parametric role which takes the function as a parameter, and has a method with the signature of the function:

```perl6
role Fun2NumArgs[&b] {
    method unF( Numeric \x,  Numeric \y --> Numeric) {
        &b(x,y);
    }
}

my \ft = Fun2NumArgs[ ->\x,\y {x*x+y*y} ].new;

say ft.unF(3,4); 
```

But what is the benefit of doing this? Surely we could just have done

```perl6
my &f =  -> Numeric \x, Numeric \y --> Numeric {x*x+y*y};

say f(3,4);
``` 

For this simple example, that would indeed be enough as we don't have functions of functions. But what we gain is that we can now create a function with arguments of type `Fun2NumArgs`:

```perl6
sub fof (Fun2NumArgs \f1,Fun2NumArgs \f2 --> Fun2NumArgs) {
...
}
```

In other words, we can now have explicitly typed function signatures in Raku. Recall that without this approach, the type of a function would be `Code` or any dependant in [the Code type graph](https://docs.raku.org/type/Code#Type_Graph). With the role-based type, the function must have the type of the method `unF`. Furthermore, these function types can be nested. Let's create another type, for a function with two arguments of any type: 

```perl6
role Fun2Args[&b] {
    method unF( Any \x, Any \y --> Any) {
        &b(x,y);
    }
}
```

We create two instances of `Fun2NumArgs`:

```perl6
my \ft = Fun2NumArgs[ ->\x,\y {x*x+y*y} ].new;
my \ft2 = Fun2NumArgs[ ->\x,\y {x*y+y+x} ].new;
```

And a function of these two functions using `Fun2Args`:

```perl6
my \fof2 = Fun2Args[ 
        sub (Fun2NumArgs \f1,Fun2NumArgs \f2 --> Fun2NumArgs) {
            # returns another function of 2 Numeric arguments
        } 
    ].new;
```

We can now call the returned function like this:

```perl6
say fof2.unF(ft,ft2).unF(3,4);
```

Having to call the `unF` method is not optimal. A better way is to can make the object itself callable instead, by defining [the submethod `CALL-ME`](https://docs.raku.org/routine/CALL-ME) instead of the method `unF`:

```perl6
role Fun2Args[&b] {
    submethod CALL-ME( \x,  \y --> Any) {
        &b(x,y);
    }
}

# And similar for Fun2NumArgs
```

In this way, we can do:

```perl6
say fof2.(ft,ft2)(3,4);
```

This is almost what we want. But we can remove the `.` as well, by making `fof2` of type `Callable`. We can indicate this with the `&` sigil. But with the current definition of `Fun2Args`, this will result in a type error because `Fun2Args` is not callable. However, `Callable` is a role so all we need to do is mix it in:

```perl6
role Fun2ArgsC[&b] does Callable {
    submethod CALL-ME( \x,  \y --> Any) {
        &b(x,y);
    }
}
```

In this way we have created something very similar to a [function object](https://en.wikipedia.org/wiki/Function_object), but using a role rather than a class. And now we can write:

```perl6
my &fof3 = Fun2ArgsC[ 
        sub (Fun2NumArgs \f1,Fun2NumArgs \f2 --> Fun2NumArgs) {
            ...
        } 
    ].new;

say fof3(ft,ft2)(3,4);
```

To summarize, we create a parametric callable role where the parameter is the function to be called, and the signature of the CALL-ME submethod provides the type constraint to that function. Passing a function with a different signature will give a type error. 

I think this is a nice way to have some additional type safety in your functional Raku code.

## Bonus Tracks

* ["Call Me" by Blondie](https://www.youtube.com/watch?v=StKVS0eI85I)
* ["CALL ME" (「コール・ミー」) by Drop's](https://www.youtube.com/watch?v=_04CojexsYw)


<!--
But we can also have    

```haskell
newtype Fun2Args = Fun2Args forall a . a -> a -> a
```


Prelude> newtype Fun2Args = Fun2Args { unF::forall a . Num a => a -> a -> a}
Prelude> ft = Fun2Args (\x y -> x+y)
Prelude> :t ft
ft :: Fun2Args
Prelude> :t unF ft
unF ft :: Num a => a -> a -> a
Prelude> :t unF ft
unF ft :: Num a => a -> a -> a
Prelude> (unF ft) 3 4
7
Prelude> (unF ft) 3.4 4.5
7.9
Prelude> 
--
-->