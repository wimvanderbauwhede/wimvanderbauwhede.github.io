---
layout: article
title: "Immutable data structures and reduction in Raku"
date: 2022-11-20
modified: 2022-11-20
tags: [ programming, raku ]
excerpt: "A small library to make it easier to work with immutable maps and lists."
current_image: immutable-datastructures-reduction_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: immutable-datastructures-reduction_1600x600.avif
  teaser: immutable-datastructures-reduction_400x150.avif
  thumb: immutable-datastructures-reduction_400x150.avif
---

For [a little compiler](https://wimvanderbauwhede.github.io/articles/uxntal-to-C/) I've been writing, I felt increasingly the need for immutable data structures to ensure that nothing was passed by references between passes. I love Perl and Raku but I am a functional programmer at heart, so I prefer map and reduce over loops. It bothered me to run reductions on a mutable data structure. So I made [a small library](https://codeberg.org/wimvanderbauwhede/nito/src/branch/main/lib/ImmutableDatastructureHelpers.rakumod) to make it easier to work with immutable maps and lists.

A reduction combines all elements of a list into a result. A typical example is the sum of all elements in a list. According to the Raku docs, `reduce()` has the following signature

```perl6
multi sub reduce (&with, +list)
```

In general, if we have a list of elements of type `T1` and a result of type `T2`, Raku's `reduce()` function takes as first argument a function of the form

```perl6
-> T2 \acc, T1 \elt --> T2 { ... }
```

I use the form of `reduce` that takes three arguments: the reducing function, the accumulator (what the Raku docs call the initial value) and the list.  As explained in the docs, Raku's `reduce` operates from left to right. (In Haskell speak, it is a `foldl :: (b -> a -> b) -> b -> [a]`.)

The use case is the traversal of a role-based datastructure `ParsedProgram` which contains a map and an ordered list of keys. The map itself contains elements of type `ParsedCodeBlock` which is essentially a list of tokens.

```perl6
role ParsedProgram {
    has Map $.blocks = Map.new; # {String => ParsedCodeBlock}
    has List $.blocks-sequence = List.new; # [String]
	...
}

role ParsedCodeBlock {
    has List $.code = List.new; # [Token]
	...
}
```

List and Map are immutable, so we have immutable datastructures. What I want do do is update these datastructures using a nested reduction where I iterate over all the keys in the `blocks-sequence` List and then modify the corresponding ParsedCodeBlock. For that purpose, I wrote a small API, and in the code below, `append` and `insert` are part of that API. What they do is create a fresh List resp. Map rather than updating in place.

I prefer to use sigil-less variables for immutable data, so that sigils in my code show where I have use mutable variables.

The code below is an example of a typical traversal. We iterate over a list of code blocks in a program, `parsed_program.blocks-sequence`; on every iteration, we update the program `parsed_program` (the accumulator).
The `reduce()` call takes a lambda function with the accumulator  (`ppr_`) and a list element (`code_block_label`).

We get the code blocks from the program's map of blocks, and use `reduce()` again to update the tokens in the code block. So we iterate over the original list of tokens (`parsed_block.code`) and build a new list. The lambda function therefore has as accumulator the updated list (`mod_block_code_`) and as element a token (`token_`). 

The inner reduce creates a modified token and puts it in the updated list using `append`. Then the outer reduce updates the block code using `clone` and updates the map of code blocks in the program using `insert`, which updates the entry if it was present. Finally, we update the program using `clone`.

```perl6
reduce(
    -> ParsedProgram \ppr_, String \code_block_label {
        my ParsedCodeBlock \parsed_block =
            ppr_.blocks{code_block_label};

        my List \mod_block_code = reduce(
            -> \mod_block_code_,\token_ {
                my Token \mod_token_ = ...;
                append(mode_block_code_,mod_token_);
            },
            List.new,
            |parsed_block.code
        );
        my ParsedCodeBlock \mod_block_ =
            parsed_block.clone(code=>mode_block_code);
        my Map \blocks_ = insert(
            ppr_glob.blocks,code_block_label,mod_block_);
        ppr_.clone(blocks=>blocks_);
    },
    parsed_program,
    |parsed_program.blocks-sequence
);
```

The entire library is only a handful of functions. The naming of the functions is based on Haskell's, except where Raku already claimed a name as a keyword.

## Map manipulation

Insert, update and remove entries in a Map. Given an existing key, `insert` will update the entry.

```perl6
sub insert(Map \m_, Str \k_, \v_ --> Map )
sub update(Map \m_, Str \k_, \v_ --> Map )
sub remove(Map \m_, Str \k_ --> Map )
```

## List manipulation

There are more list manipulation functions because reductions operate on lists.

### Add/remove an element at the front:

```perl6
# push
sub append(List \l_, \e_ --> List)
# unshift
sub prepend(List \l_, \e_ --> List)
```

### Split a list into its first element and the rest:

```perl6
# return the first element, like shift
sub head(List \l_ --> Any)
# drops the first element
sub tail(List \l_ --> List)

# This is like head:tail in Haskell
sub headTail(List \l_ --> List) # List is a tuple (head, tail)
```

The typical use of `headTail` is something like:

```perl6
my (Str \leaf, List \leaves_) = headTail(leaves);
```

### Similar operations but for the last element:

```perl6
# drop the last element
sub init(List \l_ --> List)
# return the last element, like pop.
sub top(List \l_ --> Any) ,
# Split the list on the last element
sub initLast(List \l_ --> List) # List is a tuple (init, top)
```

The typical use of `initLast` is something like:

```perl6
my (List \leaves_, Str \leaf) = initLast(leaves);
```


