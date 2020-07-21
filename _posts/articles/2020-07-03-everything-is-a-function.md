---
layout: article
title: "Everything is a function"
date: 2020-07-03
modified: 2020-07-03
tags: [ coding, hacking, programming, haskell ]
excerpt: "Although it might seem that a language like Haskell has a lot of different objects and constructs, they can all be reduced to functions."
current: "Everything is a function"
current_image: everything-is-a-function_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: everything-is-a-function_1600x600.jpg
  teaser: everything-is-a-function_400x150.jpg
  thumb: everything-is-a-function_400x150.jpg
---


This is an article I wrote several years ago. It is part of the ["Functional Programming in Haskell" online course](https://www.futurelearn.com/courses/functional-programming-haskell). It discusses one of the aspects of functional programming that I like in particular, the fact that the entire language can be build starting from the [lambda calculus](https://www.futurelearn.com/courses/functional-programming-haskell/0/steps/27249).

## In a functional language, there are only functions

Although it might seem that a language like Haskell has a lot of different objects and constructs, they can all be reduced to functions. We will demonstrate how variables, tuples, lists, conditionals, Booleans and numbers can all be constructed from lambda functions. The article assumes some familiarity with Haskell, but here is a quick introduction.

### Haskell: a quick introduction

Haskell is whitespace-sensitive like Python, but has a markedly different syntax. Because everything is a function, there is no keyword to mark a function; because there is only lexical scope, there is no need for any special scope identifiers. Function arguments are separated by spaces; anonymous functions are called _lambda functions_ and have a special syntax to identify them: 

```haskell
-- named function
square x = x*x
-- lambda function bound to a named variable
anon_square = \x ->  x*x
```

Several of the examples use the  `let ... in ...`  construct, which behaves as a lexically scoped block:

```haskell
let_square x a b c = let
    x2 = a*x*x
    x1 = b*x
    x0 = c
  in
    x2+x1+x0
```
`x0`, `x1` and `x2` are in scope only in the expression after the `in` keyword.

Haskell is statically typed, and the type of a function or variable is written in a separate annotation, for example:

```haskell
isEmpty :: [a] -> Bool
isEmpty lst = length lst == 0
```

The `isEmpty` function has a type signature, identified by `::`, that reads "`isEmpty` is a function from a list of anything to a Boolean". Types must be written with an initial capital. The `a` is a _type variable_ which can take on any type, as explained in [my post on algebraic data types]({{ site.url }}/articles/everything-is-a-function/). Most of the time, you don't need to write type declarations as Haskell works them out automatically. In the rest of the article, I'm not focusing on the types so I have omitted them.

### Variables and `let`

Haskell uses `let` expressions to define variables used in a final expression, for example:

```haskell
    let
      n = 10
      f x = x+1
    in
      f n
```

We can rewrite this to use only one variable per `let`:

```haskell
    let
      n = 10
    in
      let  
        f x = x+1
      in
        f n
```

Now we rewrite any named functions (`f`) as lambda functions:

```haskell
    let
      n = 10
    in
      let  
        f = \x -> x+1
      in
        f n
```

Then we rewrite the `let` expressions themselves as lambdas, first the inner `let`:

```haskell
    let
      n = 10
    in
      (\f -> f n) (\x -> x+1)  
```

We do this by turning the variable in the `let` part of the expression (`f`) into a parameter of a lambda function (`\f -> ...`). The body of the function is the expression after the `in` (`f n`). Then we apply this lambda function to the expression bound to the variable (`\x -> x+1`).   

Then we rewrite outer `let` in the same way:

```haskell
    ( \n -> ((\f -> f n) ( \x -> x+1 )) ) 10    
```

This expression consists only of lambda expressions, which shows that variables and `let`-expressions are just syntactic sugar for lambda expressions.    

### Tuples

Haskell has _tuples_, also called record types or product types, ordered collections of expressions of potentially different types:

```haskell
    tp = (1,"2",[3])
```

The tuple notation is syntactic sugar for a function application:

```haskell
      tp = mkTup 1 "2" [3]
```

The tuple construction function can again be defined purely using lambdas:


```haskell
          mkTup x y z = \t -> t x y z
```

What we do here is to use the elements of the tuple as the arguments of a lambda function. So what `mkTup` returns is also a lambda function, in other words `mkTup` is a higher-order function. Now we rewrite the `mkTup` named function as lambda function as well:

```haskell
          mkTup = \x y z -> \t -> t x y z
```

So our tuples are now also encoded purely as lambda functions.

The same goes for the tuple accessor functions:          

```haskell
    fst tp = tp (\x y z -> x)
    snd tp = tp (\x y z -> y)
```

Let's see what happens here: the argument `tp` of `fst` is a function: `\t -> t x' y' z'`. We now apply this function to another function, `\x y z -> x`:

```haskell
    (\t -> t x' y' z') (\x y z -> x)
```

Applying the function gives:

```haskell
    (\x y z -> x) x' y' z'
```

And so the result will of course be `x'`, which is indeed the first element of the tuple. 

### Lists

Lists can be defined in terms of the empty lists `[]` and the `cons` operation `(:)`.

```haskell
    ls = [1,2,3]
```
Rewriting this using `:` and `[]`:

```haskell
    ls = 1 : 2 : 3 : []
```

Or using `cons` explicitly:

```haskell
    ls = cons 1 (cons 2 (cons 3 []))
```

#### Defining `cons`    

We can define `cons` using only lambda functions as

```haskell
  cons = \x xs ->
	   \c -> c x xs
```

We've used the same approach as for the tuples: `cons` returns a lambda function. So we can write a list as:

```haskell
    ls = cons 1 (...)
       = \c -> c 1 (...)
```

We can also define `head` and `tail` using only lambdas, similar to what we did for `fst` and `snd` above:

```haskell
    head ls = ls (\x y -> x)
    tail ls = ls (\x y -> y)
```

#### The empty list

We can define the empty list as follows:

```haskell
    [] = \f -> true
```
This is a lambda function which always returns `true`, regardless of its argument. The definitions for `true` and `false` are given below under Booleans.  With this definition we can check if a list is empty or not:

```haskell
    isEmpty lst = lst (\x xs -> false)
```

Let's see how this works. A non-empty list is always defined as:

```haskell
    lst = x:xs
```

which with our definition of `(:)` (i.e. `cons`) is:

```haskell
    lst = (\x xs -> \c -> c x xs) x xs
    = \c -> c x xs
```

And therefore:

```haskell
    isEmpty lst
    = isEmpty (\c -> c x xs)
    =  (\c -> c x xs) (\x xs -> false)
    = false

    isEmpty []
    = isEmpty (\f -> true)
    = (\f->true) (\x xs -> false)
    = true
```

And so we have a pure-lambda definition of lists, including construction, access and testing for empty. 

#### Recursion on lists

Now that we can test for the empty list we can define recursions on lists such as `foldl`, `map` etc.:

```haskell
    foldl f acc lst =
      if isEmpty lst
        then acc
        else foldl f (f (head lst) acc) (tail lst)
```

and

```haskell
    map f lst  =
      let
        map' f lst lst' = 
          if isEmpty lst 
            then (reverse lst') 
            else map' f (tail lst) (head lst: lst')
      in
        map' f lst []
```

with

```haskell
    reverse lst = (foldl (\acc elt -> (elt:acc)) [] lst
```

The definitions of `foldl` and `map` use an if-then-else expression which is defined below under Conditionals.

#### List concatenation

With `foldl` and `reverse` it is easy to express list concatenation:

```haskell
    (++) lst1 lst2 = 
      foldl (\acc elt -> (elt:acc)) lst2 (reverse lst1)
```

#### The length of a list

To compute the length of a list we need integers, they are defined below. We increment the lent counter for every element of the list consumed by the fold.

```haskell
    length lst = foldl calc_length 0 lst
      where
        calc_length _ len = inc len
```

### Conditionals

We have used conditionals in the above expressions:

```haskell
    if cond then if_true_exp else if_false_exp
```

Here `cond` is an expression returning either `true` or `false`, these are defined below.

We can write the if-then-else clause as a pure function:

```haskell
    ifthenelse cond if_true_exp if_false_exp
```

### Booleans

To evaluate the condition we need to define Booleans as lambda functions:

```haskell
    true = \x y -> x
    false = \x y -> y
```

The Boolean is a function selecting the expression corresponding to true or false. With this definition, the if-then-else becomes simply:

```haskell
    ifthenelse cond if_true_exp if_false_exp = 
      cond if_true_exp if_false_exp
```


#### Basic Boolean operations: `and`, `or` and `not`

Using `ifthenelse` we can define `and`, `or` and `not`:

```haskell
    and x y = ifthenelse x (ifthenelse y true) false
    or x y = ifthenelse x true (ifthenelse y true false)
    not x = ifthenelse x false true
```

#### Boolean equality: `xnor`

We note that to test equality of Booleans we can use `xnor`, and we can of course define `xor` in terms of `and`, `or` and `not`:

```haskell
    xor x y = (x or y) and (not x or not y)
```

and 

```haskell
    xnor x y = not (xor x y)
```

### Signed Integers

The common way to define integers in the lambda calculus is as [Church numerals](https://en.wikipedia.org/wiki/Church_encoding). Here we take a different approach, but it is of course equivalent. We define an integer as a list of Booleans, using [thermometer code](https://en.wikipedia.org/wiki/Unary_coding), and with the following definitions:

We define unsigned `0` as a 1-element list containing `false`. To get signed integers we simply define the first bit of the list as the sign bit. We define unsigned and signed versions of `0`:

```haskell
    u0 = false:[]
    0 = +0 = true:u0
    -0 = false:u0
```

For convenience we define also:

```haskell
    isPos n = head n
    isNeg n = not (head n)
    isZero n = not (head (tail n))
    sign n = head n
```

#### Integer equality

The definition of `0` makes the integer equality `(==)` easier:

```haskell
    (==) n1 n2 = let
      s1 = head n1
      s2 = head n2
      b1 = head (tail n1)
      b2 = head (tail n2)
      if (xnor s1 s2) then
        if (and (not b1) (not b2))
          then true
          else
            if (and (not b1) (not b2))
              then  (==) (s1:(tail n1)) (s2:(tail n2))
              else false
        else false
```

#### Negation

We can also easily define negation:

```haskell
    neg n = (not (head n)):(tail n)
```

#### Increment and Decrement

For convenience we define also define increment and decrement operations:

```haskell
    inc n = if isPos n 
      then true:true:(tail n) 
      else if isZero n 
        then 1 
        else false:(tail (tail n))
    dec n = if isZero n 
      then -1 
      else if isNeg n 
        then false:true:(tail n) n 
        else true:(tail (tail n))
```

#### Addition and Subtraction

General addition is quite easy:

```haskell
    add n1 n2 = foldl add_if_true n1 n2
      where
        add_if_true elt n1 = if elt then true:n1 else n1
```

In the same way, subtraction is also straightforward:

```haskell
    sub n1 n2 = foldl sub_if_true n1 n2
      where
        sub_if_true elt n1 = of elt then (tail n1) else n1
```

#### Multiplication

An easy way to define multiplication is by defining the `replicate` and `sum` operations:

```haskell
    replicate n m =
      let
        repl n m lst = if n==0 
          then lst 
          else repl (dec n) m (m:lst)
      in
        repl n m []

    sum lst = foldl add 0 lst
```

Then multiplication simply becomes

```haskell
    mult n m = sum (replicate n m)
```

In a similar way we can define integer division and modulo.

### Floats, Characters and Strings

We note that floating-point numbers and characters use an integer representation, and strings are simply lists of characters. So we don't need to do any additional work to represent them, and the operations on them are analogous to the ones defined above. 

## Conclusion

In this way, we have defined a language with variables, (higher-order) functions, conditionals and recursion. We can manipulate lists and tuples of integers, floats, chars and strings. And yet it consists of nothing more than lambda functions!
