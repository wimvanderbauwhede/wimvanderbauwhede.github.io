---
layout: article
title: "Embedding a stack-based programming language"
date: 2023-11-27
modified: 2023-11-27
tags: [ computing, functional, uxntal, raku ]
excerpt: "It takes just one custom operator to allow Uxntal-style programming in Raku."
current: ""
current_image: stack-based-programming-in-raku_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: stack-based-programming-in-raku_1600x600.avif
  teaser: stack-based-programming-in-raku_400x150.avif
  thumb: stack-based-programming-in-raku_400x150.avif
---

When [`@lizmat`](https://scholar.social/@lizmat@mastodon.social) asked me to write a post for the [Raku advent calendar](https://raku-advent.blog/category/2023/) I was initially a bit at a loss. I have spent most of the year not writing [Raku](https://raku.org/) but working on my own language [Funktal](https://limited.systems/articles/funktal/), a postfix functional language that compiles to [Uxntal](https://wiki.xxiivv.com/site/uxntal.html), the stack-based assembly language for the tiny [Uxn](https://wiki.xxiivv.com/site/uxn.html) virtual machine.

But as Raku is nothing if not flexible, could we do Uxntal-style stack-based programming in it? Of course I could embed the entire Uxntal language in Raku using [a slang](https://raku.land/zef:lizmat/Slangify). But could we have a more shallow embedding? Let's find out.

## Stack-oriented programming

An example of simple arithmetic in Uxntal is

```perl6
    6 4 3 ADD MUL
```

This should be self-explanatory: it is called postfix, stack-based or reverse Polish notation. In infix notation, that is `6*(4+3)`. In prefix notation, it's `MUL(6, ADD(4,3))`. The integer literals are pushed on a stack, and the primitive operations `ADD` and `MUL` pop the arguments they need off the stack an push the result.

## The mighty `∘` operator, part I: definition

In Raku, we can't redefine the whitespace to act as an operator. I could of course do something like

```perl6
    my \stack-based-code = <6 4 3 ADD MUL>;
```

but I don't want to write an interpreter starting from strings. So instead, I will define an infix operator `∘`. Something like this:

```perl6
    6 ∘ 4 ∘ 3 ∘ ADD ∘ MUL
```

The operator either puts literals on the stack or calls the operation on the values on the stack.

By necessity, `∘` is a binary operator, but it will put only one element on the stack. I chose to have it process its second argument, and ignore the first one,because in that way it is easy to terminate the calculation. However, because of that, the first element of each sequence needs to be handled separately.

## Returning the result

To obtain a chain of calculations, the operator needs to put the result of every computation on the stack. This means that in the example, the result of `MUL` will be on the stack, and not returned to the program. To return the final result to the program, I slightly abuse Uxntal's `BRK` opcode. On encountering this opcode, the value of the computation is returned and the stack is cleared (in native Uxntal, `BRK` simply terminates the program). So a working example of the above code is

```perl6
    my \res = 6 ∘ 4 ∘ 3 ∘ ADD ∘ MUL ∘ BRK
```

## Some abstraction with subroutines

Uxntal allows to define subroutines. They are just blocks of code that you jump to. In my Raku implementation we can simply define custom subroutines and call them using the Uxntal instructions `JSR` (jump and return), `JMP` (jump and don't return, used for tail calls) and `JCN` (conditional jump).

```perl6
my \res =  3 ∘ 2 ∘ 1 ∘ INC ∘ ADD ∘ MUL ∘ 4 ∘ &f ∘ JMP ;

sub f {
    SUB ∘ 5 ∘ MUL ∘ 2 ∘ ADD ∘ RET
}
```

(the instruction `RET` is called `JMP2r` in Uxntal)

## Stack manipulation operations

One of the key features of a stack language is that it allows you to manipulate the stack. In Uxntal, there are several operations to duplicate, remove and reorder items on the stack. Here is a contrived example

    my \res =
        4 ∘ 2 ∘ DUP ∘ INC ∘ # 4 2 3
        OVR ∘  # 4 2 3 2
        ROT ∘ # 4 3 2 2
        ADD ∘ 2 ∘ ADD ∘ MUL ∘ BRK ; # 42

## Keeping it simple

Uxntal has more ALU operations and device IO operations. It also has a second stack (return stack) and operations to move data between stacks. Furthermore, every instruction can take the suffix '2', meaning it will work on two bytes, and 'k', meaning that it will not consume its arguments but leave them on the stack. I am omitting all these for simplicity.

## The mighty `∘` operator, part II: implementation

With the above, we have enough requirements to design and implement the operator. As usual, I will eschew the use of objects. It was my intention to use all kind of fancy Raku features such as introspection but it turns out I don't need them.

We start by defining the Uxntal instructions as enums. I could use a single enum but grouping them makes their purpose clearer.

```perl6
enum StackManipOps is export <POP NIP DUP SWP OVR ROT BRK> ;
enum StackCalcOps is export <ADD SUB MUL INC DIV>;
enum JumpOps is export <JSR JMP JCN RET>;
```

We use a stateful custom operator with the stack `@wst` (working stack) as state. The operator returns the top of the stack and is left-associative. Anything that is not an Uxntal instruction is pushed onto the stack.

```perl6
our sub infix:<∘>(\x, \y)  is export {
    state @wst = ();

    if y ~~ StackManipOps {
        given y {
            when POP { ... }
            ...
        }
    } elsif y ~~ StackCalcOps {
        given y {
            when INC { ... }
            ...
        }
    } elsif y ~~ JumpOps {
        given y {
            when JSR { ... }
            ...
        }
    } else {
        @wst.push(y);
    }

    return @wst[0]
}
```

This is not quite good enough: the operator is binary, but the above implementation ignores the first element. This is only relevant for the first element in a sequence. We handle this using a boolean state `$isFirst`. When `True`, we simply call the operator again with `Nil` as the first element.
The `$isFirst` state is reset on every `BRK`.

```perl6
    state Bool $isFirst = True;
    ...
    if $isFirst {
        @wst.push(x);
        $isFirst = False;
        Nil ∘ x
    }
```

The final complication lies in the need to support conditional jumps. The problem is that in e.g.

```perl6
    &ft ∘ JCN ∘ &ff ∘ JMP
```

depending on the condition, `ft` or `ff` should be called. If `ft` is called, nothing after `JCN` should be executed. I solve this by introducing another boolean state variable, `$skipInstrs`, which is set to `True` when `JCN` is called with a true condition. 

```perl6
    when JCN {
        my &f =  @wst.pop;
        my $cond = @wst.pop;
        if $cond>0 {
            $isFirst = True;
            f();
            $skipInstrs = True;
        }
    }
```

The boolean is cleared on encountering a `JMP` or `RET`:

```perl6
    if $skipInstrs {
        if (y ~~ JMP) or (y ~~ RET) {
            $skipInstrs = False
        }
    } else {
        ...
    }
```

This completes the implementation of the operator `∘`. The final structure is:

```perl6
our sub infix:<∘>(\x, \y)  is export {
    state @wst = ();
    state Bool $isFirst = True;
    state $skipInstrs = False;

    if $skipInstrs {
        if (y ~~ JMP) or (y ~~ RET) {
            $skipInstrs = False
        }
    } else {

        if $isFirst and not (x ~~ Nil) {
            @wst.push(x);
            $isFirst = False;
            Nil ∘ x
        }

        if y ~~ StackManipOps {
            given y {
                when POP { ... }
                ...
            }
        } elsif y ~~ StackCalcOps {
            given y {
                when INC { ... }
                ...
            }
        } elsif y ~~ JumpOps {
            given y {
                when JSR { ... }
                ...
            }
        } else {
            @wst.push(y);
        }
    }
    return @wst[0]
}
```

## Memory and pointers

Like most stack languages, Uxntal also has load and store operations to work with memory. Uxntal does not have a separate instruction memory, so you can mix code and data and even write self-modifying code. There are load and store operations on absolute (`LDA`,`STA`) and relative (`LDR`,`STR`) addresses. In my Raku implementation, I don't distinguish between those. I use arrays as named stretches of memory. So for example the following native Uxntal snippet

    @array #11 #22 #33
    ;array #0001 ADD2 LDA ( puts 0x22 on the stack )

becomes

```perl6
    my @array = 0x11, 0x22, 0x33;
    @array ∘ 0x0001 ∘ ADD ∘ LDA
```

and that would be close enough, were it not that in Uxntal memory is declared after subroutines. So what I actually need to do is

```perl6
    (array) ∘ 0x0001 ∘ ADD ∘ LDA
    sub array { [ 0x11, 0x22, 0x33 ] }
```

The way I handle the pointer arithmetic is by pattern matching on the type. Instructions `ADD`, `SUB` and `INC` can take an integer or a label, which in Raku is an `Array`. The valid argument type for these operations is in pseudo-code for types:

    Pair  = (Fst,Int)
    Fst = Array | (Fst,Int)
    Addr = Int | Array | Pair

In words, it can be an integer, a label or a pair where the second element of the pair must be an integer and the first is either a label or a pair.

For example for the `INC` operation, we do

```perl6
    given (arg) {
        when Int { push @wst,arg+1}
        when Array { push @wst,(arg,1)}
        when List { push @wst,(arg,1)}
    }
```

For `ADD` and `SUB` we do something similar but check if either arg is Int, Array or List. 
If both arguments are Int, we return the result of the operation; if only one of the arguments is an Int, we return the pair of arguments as a List; otherwise we throw an error as it is not a valid type.

The non-integer return values of this kind of arithmetic are used in `LDA` and `STA`. Here, the only valid type is the following:

    Addr = Array | (Addr, Int)

In other words, an address must always be relative to a label. So we will check if the argument is not an integer.

## Hello, Uxntal

With this machinery we can run the following Uxntal "Hello World" program

        |0100

            ;hello JSR2

        BRK

        @hello
            ;hello-word ;print-text JSR2
        JMP2r

        @print-text ( str* -- )
            ;while JSR2
            POP2
        JMP2r

        @while
                ( send ) DUP2 LDA #18 DEO
                ( loop ) INC2 DUP2 LDA ;while JCN2
        JMP2r

        @hello-word "Hello 20 "World! 00

    ( the `#18 DEO` instruction prints a byte on STDOUT )

in Raku as follows:

```perl6
    #|0100
        &hello ∘ JSR2 ∘ 
    BRK;

    sub hello {
        (hello-world) ∘ &print-text ∘ JSR2 ∘ 
        RET
    }

    sub print-text { # str* --
        &loop ∘ JSR2 ∘ 
        RET
    }

    sub loop {
        DUP2 ∘ LDA ∘ 0x18 ∘ DEO ∘ 
        INC2 ∘ DUP2 ∘ LDA ∘ &loop ∘ JCN2 ∘ 
        RET
    }

    sub hello-world { ["Hello,",0x20,"World!", 0x0a,0x00] }
```

As this program has a loop implemented as a tail recursion, it is complete in terms of illustrating the features of a stack-based program in Uxntal.

## Conclusion

So in conclusion, we can easily embed a stack-based programming language such as Uxntal in Raku purely by defining a single binary operator and a few enums for the instructions. This is mainly courtesy of Raku's `state` variables and powerful pattern matching.

The code for this little experiment is available in my [raku-examples](https://github.com/wimvanderbauwhede/raku-examples) repo, with two sample programs [stack-based-programming.raku](https://github.com/wimvanderbauwhede/raku-examples/blob/master/stack-based-programming.raku) and [hello-uxntal.raku](https://github.com/wimvanderbauwhede/raku-examples/blob/master/hello-uxntal.raku) and the module implementing the operator [Uxn.rakumod](https://github.com/wimvanderbauwhede/raku-examples/blob/master/Uxn.rakumod).
