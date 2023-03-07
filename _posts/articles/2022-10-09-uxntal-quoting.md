---
layout: article
title: "Functional programming in stack-based assembly"
date: 2022-10-09
modified: 2022-10-09
tags: [ programming ]
excerpt: "What does it take to bring functional programming to a stack-based assembly language?"
current_image: uxntal-quoting_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: uxntal-quoting_1600x600.jpg
  teaser: uxntal-quoting_400x150.jpg
  thumb: uxntal-quoting_400x150.jpg
---

## Quoting in Uxntal: lambda functions, tuples and lists for free

What does it take to bring functional programming to a stack-based assembly language? _tl;dr_: not all that much. Uxntal has everything it takes to build a basic mechanism ("quoting") that lets us create lambda functions, tuples, cons lists and more.

## Uxntal and Uxn

[`Uxntal`](https://wiki.xxiivv.com/site/uxntal.html) is the programming language for the [`Uxn`](https://wiki.xxiivv.com/site/uxn.html) virtual machine. As Uxn is a stack machine, Uxntal is a stack language, similar to e.g. [Forth](https://forth-standard.org/) or [Joy](https://dev.to/palm86/church-encoding-in-the-concatenative-language-joy-3nd8) in that it uses reverse Polish notation (postfix). It is an assembly language with opcodes for 8-bit and 16-bit operations on the stack and memory. To get the most out of this article, it is best if you have basic knowledge of Uxntal, either from the above resources or for example [the great tutorial at Compudanzas](https://compudanzas.net/uxn_tutorial.html).

Concepts such as lambda functions, quoting, partial application and closures are common in functional programming languages, but if you are not familiar with these you should still be able to follow most of the explanation. My article ["Cleaner code with functional programming"]({{ site.url }}/articles/decluttering-with-functional-programming/), explains the basics of functional programming.

Although Uxn is a stack machine and Uxntal a stack language, it is quite easy to do register based programming by using labels as variables: the purely stack based

    |0100
    #06 #07 MUL

can be written as

    |0000
    @r1 $1 @r2 $1 @r3 $1
    |0100
    #06 .r1 STZ
    #07 .r2 STZ
    .r1 LDZ .r2 LDZ MUL .r3 STZ

where we store the values in memory and load them when needed. My implementation of lambda functions makes use of this approach.

Uxntal also has a simple but powerful macro mechanism which just creates short names for groups of tokens. I make heavy use of macros in what follows.

Because of the conciseness of its syntax, I use the venerable functional language [Haskell](https://haskell.org/) for some of the examples below. A short primer on Haskell is my article ["Everything is a function"]({{site.url}}/articles/everything-is-a-function/).

## Anonymous functions

Uxntal supports variables and named function calls through labels. And as the program is stored in writeable memory, it can be overwritten or modified in place.

I wanted to see if I could implement or emulate the behaviour of anonymous functions (called "lambda functions" in functional programming). For example, I'd like to be able to write something similar to the following Haskell code:

```haskell
    map (\x -> x*x ) lst
```

or equivalent in Python:

```python
    map( (lambda x: x*x), lst)
```

which would square all elements in the list `lst`. And I would like to be able to use lambda functions as arguments and as return values:

```haskell
    (\f -> f) (\x -> 2*x) 3
```

and

```haskell
    (\x -> (\y -> x+y)) 2 3
```

I also want to be able to combine lambdas and named functions:

```haskell
    ( \x y -> (sum-sq x y) + 2*x*y ) 3
```

The reason I want to do this is mostly curiosity, but there are some practical advantages because the lambda functions can be generated dynamically based on runtime values. Also, the "quoting" mechanism used to build lambdas is more general and allows for "lazy" or delayed evaluation.

From the above examples, the clear feature of a lambda function is that it identifies by name the variables used as its arguments. I want to reflect this closely in Uxntal. The other key feature is that the lambda functions are values, and we need to apply them to an argument to get a computation. That is very similar to calling a function in Uxntal. Suppose we have

    |0100
    #0003 #0004 ;f JSR2
    BRK
    @f
        .x STZ2
        .y STZ2
        .x LDZ2 .x LDZ2 MUL2 .y LDZ2 .y LDZ2 MUL2 ADD2
        .x LDZ2 .y LDZ2 MUL2 #0002 MUL2 ADD2
        JMP2r

Using some macros I have defined for convenience, I can write this as

    |0100
    3 4 ;f call
    BRK
    @f
        ->x
        ->y
        x x * y y * +
        x y * 2 * +
        return

With a lambda notation, this would become

    |0100
    3 4  [' \x. \y.
            x' x' *' y' y' *' +'
            x' y' *' 2' *' +'
        ]' apply
    BRK

The nested example `(\x -> (\y -> x+y)) 2 3` would be with named functions:

    |0100
    3 2 ;f call
    BRK
    @f
        ->x
        ;g call
        return
    @g
        ->y
        x y +
        return

and with lambdas

    |0100
    3 2 [' \x.
            [' \y.
                x' y' +'
            ]'
        ]' apply
        apply
    BRK

In other words, the function is defined inside the quoted brackets and called using `apply` rather than `call`.

## Implementation

So how do we do this? There are several components than need to be brought together to have named variables, nesting, and functions as values.

### Uxntal quoting and unquoting

#### Quoting

First of all, we need some mechanism to defer evaluation of an operation, which I call "quoting" for short.
Luckily, Uxntal has the essential feature: it is possible to quote an operation and unquote it later. For example:

    #06 #07 ADD

would immediately compute 6*7; but if we write

    #06 #07 LIT ADD

then we have the ADD operation as a symbol on the stack. This is what I call "quoting" for opcodes.

#### Unquoting through self-modification

To unquote the symbol and so evaluate the expression, we can do

    #00 STR $1

which is a bit of Uxn magic: it is a relative store with a relative address of 0, and effectively it takes the symbol from the stack and puts it as the next instruction to be executed. The `$1` is just a placeholder on the stack to create the space for the store. So the following would calculate `6*7` and print out `*`.

    |0100
        #06 #07 LIT ADD
        #00 STR $1
        #18 DEO ( prints the character to stdout )
    BRK

There isn't really anything magical going on here: an equivalent program would be

    |0100
        #06 #07 LIT ADD
        ;eval STA @eval $1
        #18 DEO ( prints the character to stdout )
    BRK

or even

    |0100
        #06 #07 LIT ADD
        ;eval STA ;eval JSR2
        #18 DEO ( prints the character to stdout )
    BRK

    @eval $1
    JMP2r

The key mechanism is that Uxntal allows to overwrite the program code, so the `$1` placeholder can at runtim be replaced by any byte, and all bytes are valid instructions.

#### Unquoting without self-modification

Even if Uxntal did not have modifiable code, we could still quote and unquote. After all, e.g. `LIT MUL` is exactly the same as `LIT 1a` or `#1a` so we can always put opcodes on the stack, they are just bytes. And to unquote them, we could use conditional jumps, for example:

    #06 #07 LIT MUL
    ( opcode on the stack )
    #1a EQU ,&eval-mul JCN
    ...
    &eval-mul
    MUL
    ...

So the self-modification is purely a more efficient way of unquoting.

### Kinds of symbols

Apart from the opcodes, there are several other types of symbols we need to be able to quote and unquote: variables, constants and function calls.

For the variables, we need to handle declaration and use: the declaration results in the argument being stored at the location referenced by the variable, and the use results in the value stored at the referenced location being read. I store the variables in the zero-page memory:

    @x $2 @y $2 @z $2

The declaration macro `\x.` should when unquoted result in

    .x STZ2

Using a variable macro `x'` should when unquoted result in

    .x LDZ2

Unquoting a constant simply means putting it on the stack.

Finally, named function call should when unquoted result in

    ;f JSR2

### Grouping symbols

As we want to be able to nest lambdas, we need some delimiters to group the quoted symbols. That is what the `['` and `]'` bracket macros do.  A quoted sequence returns its address onto the working stack. In this way we can pass lambdas around as values.

### Building the lambda

To build the lambda function, I need to store the quoted symbols. Crucially, I need to be able to identify the kind of each symbol. I encode each symbol using three bytes, the third byte is a label to identify the kind of symbol. The opening and closing brackets are also labelled and stored in this way. The opening bracket symbol contains the size of the lambda; the closing bracket is only there as a jump target. For example,

    [' \x. x' 1' +' ;f call' ]'

is encoded as

    Value   Label
    ------  ------
    00 07   LAMBDA
    .x __  BIND
    .x __  ARG
    00 01   CONST
    ADD __  OPCODE
    ;f      CALL
    __ __   END

The `__` are unused slots because for simplicity I have currently made all symbols the same size (this will probably change as I don't like inefficiency). For an 8-bit version, it would be possible to encode everything in two bytes.

Each quoting operation is implemented as a function and those functions keep track of where to write the symbols in memory. The memory for the lambdas starts from `|0100`, so I effectively overwrite the program. This is OK because the lambda definition in the program takes up more space than the encoding of the lambda, so there is no risk of overwriting named functions.

### The lambda stack

Because I want to be able to nest lambdas, I need a stack. I could abuse the return stack for this purpose, but I don't think using either of the Uxn stacks for persistent state is a good idea. So I build a stack in the second half of the zero-page memory. This stack stores tuples of the starting address and the size (in 3-byte words) of each lambda. Each quoting operation manipulates that stack to create the memory encoding for each lambda.

### Applying the lambda

The unquoting operation (the `apply` call) uses the same lambda stack. It takes the address of the lambda as argument, and loops over all symbols in the stored representation. The interesting case is that of nested lambdas: when the symbol represents an opening bracket, the evaluator puts the address of the nested lambda on the stack and jumps to the closing bracket, which acts as a no-op. For non-nested lambdas, the closing bracket returns the lambda's address. In this way I can evaluate nested lambdas as part of an `apply` call, and I can also return lambdas.

## More uses of quoting

The quoting mechanism can be used for other purposes than creating lambda functions. Or to look at it another way, lambda functions that take no arguments ("blocks") are valid:

    [' ;f call' ]'

This gives us an option to have deferred calls.

### A lazy `if`

Lazy means here that we will only evaluate the true or false branch after evaluating the condition, instead of evaluating both and returning the result based on the condition. We can create a `lazy-if` function using quoting as follows:

    [' <false-expr>' ]' [' <true-expr>' ]' <cond>  ;lazy-if call

The `lazy-if` function is quite simple:

    @lazy-if
        ,&if-true JCN
        ( if-false )
        POP2 apply-tc
        &if-true
        NIP2 apply-tc

Here, `apply-tc` is a tail call version of `apply`, so equivalent to `apply return`. We could of course create a `case` expression in this way too.

### Tuples

The quoting mechanism can also be used to create immutable lists, or actually tuples (a tuple is a generalisation of a pair, can have any number of values of any type but can't be modified):

    [' 2 4 + \' 3 5 + \' ]' ( a tuple (6,8) )
    [' 1 2 + \' 4 \' ]'  ( a tuple (3,4) )
    SWP2
    apply * apply * / ( 4 )

In this example, `[' ... ]'` first creates two tuples and stores it somewhere;
then `apply` puts the values on the stack. It would be quite easy to write an indexing function to access element by index.

    [' 2 4 + \' 3 5 + \' ]'  ( creates (6,8) )
    [' 1 2 + \' 4 2 /  2' ]'  ( creates (3,2,2) )
    SWP2
    apply * ( 6*8 )
    SWP2
    apply [ * * ]  ( 3*2*2 )
    / ( 48/12 )

Another example to illustrate the functions to work on tuples:

    [' [ 1 2 + ] \' [ 3 4 * ] \' 5' ]' ->l ( store the tuple in l )
    l fst  print16-nl ( first element )
    l snd print16-nl ( second element )
    l 2 at print16-nl ( at takes the index (base 0) and returns the element )
    [  + + ] POP2
    l empty print8-nl ( test if the tuple is empty, returns #00 here )
    [' ]' empty print8-nl ( test if the tuple is empty, returns #01 here )
    l size print16-nl ( returns the number of elements in the tuple, i.e. 3 )

Because Uxntal is not statically typed, there is no difference between immutable lists and tuples.

### Cons lists

What I call a "cons list" is a list constructed starting from an empty list by adding a single element. The function to construct such a list is typically called `cons` in functional programming languages, and in Haskell it has a corresponding operator `:`. So the list

    [ 1 2 3 4 ]

is really syntactic sugar for

    1:2:3:4:()

which is a shorter notation for

    (cons 1 (cons 2 (cons 3 (cons 4 ()))))

We can use the tuples in combination with a `cons` function in Uxntal to create cons lists:

    [' ]' 7 cons 6 cons 5 cons ( [ 5 6 7 ] )

There are a few functions to manipulate such lists, the most common ones are `head` which returns the first element and `tail` which returns the rest of the list (`car` and `cdr` in Scheme).

    [' ]' 7 cons 6 cons 5 cons ->l ( (5:6:(7:[])) )
    l tail tail head ( )
    l tail head
    *

There is of course also a `length` function, and a function `null` to check if the list is empty:

    [' ]' 7 cons 6 cons 5 cons ->l ( (5:6:(7:[])) )
    l 4 cons length ( 4 )
    l tail tail tail null  ( #01 )

### Partial application and closures

The nested lambdas allow partial application:

    5 [' \x.  [' \y. x' y' +' ]'  ]' lambda-call

This means that we don't have to provide values for all arguments, and what we return is a function that has been specialised with the arguments that have been provided. In the example, we will effective obtain a function that will calculate `y+5`. This is a technique that can be used to generate specialised functions from a template.

This looks a lot like a proper [closure](https://en.wikipedia.org/wiki/Closure_(computer_programming)) but while it seems to work, the value is not really captured. We simply store 5 in `@x`; if I modify `x` between the lambda calls, it will use the modified value. With a proper closure, once it has been created, it does not matter that the original value gets modified. This is not the case in my approach because x and y are globals, not locals. It is possible to address this but it would be very expensive:

- In `\x.`, we store the address of `.x` somewhere;
- Then we check the entire downstream lambda definition for occurrences of that address;
- We need to take into account that any further occurrence of `\x.` resets this;
- Then we could replace `.x LIT LDZ2 OPCODE'` with `.x LDZ2 CONST'`, so the value would become embedded in the lambda.

If you want to address this issue, please let me know.

### Desugaring

For example:

    5 \[ \x. x' x' *' \[ \y. y' 1' +' \] lambda-call' \] lambda-call ( returns #001a )

The `\[` ... `\]` brackets indicate the start and end of a quoting region. Within a quoting region, all quote symbols make up the anonymous function. I use macros to make it a bit nicer. Desugaring the example one layer, we get the following:

    #0033
    ['
        .x bind'
        .x arg'
        .x arg'
        LIT MUL2 opcode'
        ['
            .y bind'
            .y arg'
            #0001 const'
            LIT ADD2 opcode'
        ]'
        ;lambda-call call'
    ]'
    ;lambda-call call

## Conclusion

Although it may seem at first sight that a stack-based assembly language is quite far removed from a high-level functional language, in Uxntal we can implement many fundamental functional programming concepts such as lambdas, lazy conditionals, tuples and lists and concepts such as partial application and closures, simply by introducing the concept of quoting and unquoting symbols. Uxntal's simple macro mechanism provides sufficient abstraction to create readable functional programs.

## Code

The code implementing the constructs described in this article is available [in my `hyakuwa` repo on Codeberg](https://codeberg.org/wimvanderbauwhede/hyakuwa/src/branch/main/quoting-lambdas).

### 8-bit vs 16-bit

By default, my implementation uses 16-bit words as values. It is possible to use 8-bit constants, arguments and operations. The macro files  `quote-lambda_macros_8bit.tal` and `lambda_decls_8bit.tal` have the appropriate definitions, or with less sugar you can use `bind8'`,`arg8'` and `const8'`.

## What's next?

As is the nature of such projects, there is always a lot more that could be done. There are two main drawbacks to the current approach: the macro mechanism is not expressive enough and the computational overhead is very high.

To address the former we could create a custom assembler, which effectively means we have a new functional language that assembles into Uxntal, either source or rom. If we did that, we could write

    5 \[ \x. x' x' *' \[ \y. y' 1' +' \] lambda-call' \] lambda-call

as, for example,

    5 (\x -> x x * (\y -> y 1 +))

This would be a lot more readable and it would also allow to tailor the memory allocation for variables.

We can't fundamentally address the computational overhead. It can definitely be reduced as the current implementation is not optimised. But effectively, the quoting mechanism is a kind of interpreter, so it always incurs the read-eval-write overhead. What we could do instead is compile the Uxntal code itself, rather than emulating it. But that will be the topic of another article.

<br>

_The banner picture shows a row of small rabbit status at a Shinto shrine in Kyoto._