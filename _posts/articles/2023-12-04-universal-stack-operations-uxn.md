---
layout: article
title: "Universal stack operations using Uxn primitives"
date: 2023-12-04
modified: 2023-12-04
tags: [ computing, functional, uxntal ]
excerpt: "What is the minimal set of Uxntal primitives required to cover the stack?"
current: ""
current_image: universal-stack-operations-uxn_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: universal-stack-operations-uxn_1600x600.avif
  teaser: universal-stack-operations-uxn_400x150.avif
  thumb: universal-stack-operations-uxn_400x150.avif
---

I wanted to know if the [`Uxntal`](https://wiki.xxiivv.com/site/uxntal.html) primitives are complete, in the sense that they allow access to all elements on the stack (what I call "covering the stack"). And if so, what the minimum set of Uxntal primitives is required to move an element to or from any location on the working stack.

The proof of these claims is by construction of a recursive algorithm, so it is a proof by induction. I have written this in Haskell notation because I think it is most clear. For completeness, I also looked at duplication and deletion. As the set of primitives is Uxn-specific, I assume the presence of a return stack.

tl;dr:

- The Uxn primitives are complete (no surprise there)
- The instructions `SWP`, `ROT`, `STH` and `STHr` are sufficient to cover the entire stack.
- Adding `DUP`, we can replicate arbitrary sequences.
- Adding `POP` we can remove arbitrary sequences.


## Uxntal and Uxn

[`Uxntal`](https://wiki.xxiivv.com/site/uxntal.html) is the programming language for the [`Uxn`](https://wiki.xxiivv.com/site/uxn.html) virtual machine. As Uxn is a stack machine, Uxntal is a stack language, similar to e.g. [Forth](https://forth-standard.org/) or [Joy](https://dev.to/palm86/church-encoding-in-the-concatenative-language-joy-3nd8) in that it uses reverse Polish notation (postfix). It is an assembly language with opcodes for 8-bit and 16-bit operations on the stack and memory. To get the most out of this article, it is best if you have basic knowledge of Uxntal, either from the above resources or for example [the great tutorial at Compudanzas](https://compudanzas.net/uxn_tutorial.html).

##  A brief overview of used Haskell syntax

In Haskell, for example a function `f` of `x` and `y` is written as `f x y`, so no parentheses. Parentheses are only used to enforce precedence, for example `f (x+1)`

Also, a recursive function can be defined as

```haskell
    f 1 = ...
    f n = ... f (n-1) ...
```

So there is no need for an `if` or `case` or similar constructs. Also, if a function argument is used in final position on both sides of the definition, it can be omitted, for example

```haskell
    f x = id x
```
can be written as

```haskell
    f = id
```

(In this example, `id` is the identity function, which returns its argument)

Finally, composing functions is done using the `.` operators. For example, `f1 (f2 (f3 x))` can be written as `(f1 . f2 . f3) x`. Combining both features, we can write for example

```haskell
    f = f1 . f2 . f3
```

## Minimal set of primitives

The type for all primitives is

```haskell
    prim :: ([Byte],[Byte]) -> ([Byte],[Byte])
```

The primitive `prim` takes a tuple (pair) of two lists of bytes and returns a tuple of two lists of bytes. (You can read the arrow as "from ... to".) For this discussion, the stacks don't have to be of fixed size, so using lists is fine.

The notation `x:xs` means that `x` is the first element of a list and `xs` is the rest of the list.

* The following Uxn primitives allow access to the entire stack

```haskell
        swp (x:y:wst',rst) = (y:x:wst',rst) -- swap in Forth
        rot (x:y:z:wst',rst) = (z:x:y:wst',rst)
        sth (x:wst',rst) = (wst',x:rst)
        sthr (wst,x:rst') = (x:wst,rst')
``` 
* For replication and deletion, we also need

```haskell
        dup (x:wst',rst) = (x:x:wst',rst)
        pop (x:wst',rst) = (wst',rst) -- drop in Forth
```

## Accessing the stack

I define two functions, one to move the kth element on the stack to the 1st position, the other its inverse.

### Put the kth element of the stack at position 1

In Forth terminology this is called `roll`.

```haskell
    -- ( x a b -- a b x )

    k_to_top 1 = id
    k_to_top 2 = swp
    k_to_top 3 = rot
    k_to_top k = swp . sthr . (k_to_top (k-1)) . sth
```

### Put the 1st element of the stack at position k

Somewhat to my surprise, Forth does not define an inverse for `roll`. Of course it is not necessary, as we can apply `roll k` k-1 times. But that means quadratic complexity; and I like to have an inverse for every primitive.

```haskell
    -- ( a b x -- x a b )

    top_to_k 1 = id -- k==1, do nothing
    top_to_k 2 = swp
    top_to_k 3 = rot . rot
    top_to_k k = sthr . (top_to_k (k-1)) . sth . swp

    id = (top_to_k k) .  (k_to_top k)
```

With these two functions, any element on the stack can be moved between two arbitrary position k1 and k2:

```haskell
    (top_to_k k2) .  (k_to_top k1)
```

This proves that the four primitives are sufficient to cover the entire stack.

## Growing the stack

Variants that keep the original element in place and so grow the stack are easily defined based on these two:

### Put the kth element of the stack at position 1, keep the original element

This function grows the stack by duplication of the element. In Forth terms, this is called `pick`.

```haskell
    -- ( x a b -- x a b x )

    k_to_top_keep 1 = dup
    k_to_top_keep k = swp . sthr . (k_to_top_keep (k-1)) . sth
```

The inverse of this is simply `pop` (`drop` in Forth).

```haskell
    id = pop . (k_to_top_keep k)
```

### Put the 1st element of the stack at position k, keep the original element

This function also grows the stack by duplication of the element:

```haskell
    -- ( a b x -- x a b x )

    top_to_k_keep 1 = id
    top_to_k_keep k = sthr . (top_to_k k) . sth . dup
```

The inverse of this requires the ability to delete a value at a given position of the stack:

## Shrinking the stack

This function deletes an element from an arbitrary position on the stack.

```haskell
    -- ( x a b -- a b )

    delete_k 1 = pop
    delete_k k = sthr . (delete_k (k-1)) . sth
```

With this function, the inverse of `top_to_k_keep` is `delete_k (k+1)`:

```haskell
    id = (delete_k (k+1)) . (top_to_k_keep k)
```

The [Haskell code](https://codeberg.org/wimvanderbauwhede/funktal/src/branch/devel/stack-manipulation-universal-uxn.hs) shows these functions at work and demonstrates the inverses. It is straightforward to implement the above functions in Uxntal, I leave that to the reader as an exercise.
