---
layout: article
title: "Compiling stack-based assembly to C"
date: 2022-10-15
modified: 2022-10-15
tags: [ compilers ]
excerpt: "What does it take to bring functional programming to a stack-based assembly language?"
current_image: uxntal-to-C_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: uxntal-to-C_1600x600.jpg
  teaser: uxntal-to-C_400x150.jpg
  thumb: uxntal-to-C_400x150.jpg
---

I wrote a proof-of-concept compiler from [Uxntal](https://wiki.xxiivv.com/site/uxntal.html) to `C`. The generated code is linked with a slightly modified version of the [Uxn VM/Varvara code](https://git.sr.ht/~rabbits/uxn) to provide stand-alone applications.


## Uxntal and Uxn

[`Uxntal`](https://wiki.xxiivv.com/site/uxntal.html) is the programming language for the [`Uxn`](https://wiki.xxiivv.com/site/uxn.html) virtual machine which forms the heart of the [`Varvara`](https://wiki.xxiivv.com/site/varvara.html) clean-slate computing stack. As Uxn is a stack machine, Uxntal is a stack language, similar to e.g. [Forth](https://forth-standard.org/) or [Joy](https://dev.to/palm86/church-encoding-in-the-concatenative-language-joy-3nd8) in that it uses reverse Polish notation (postfix). It is an assembly language with opcodes for 8-bit and 16-bit operations on the stack and memory. To get the most out of this article, it is best if you have basic knowledge of Uxntal, either from the above resources or for example [the great tutorial at Compudanzas](https://compudanzas.net/uxn_tutorial.html).

## An Uxntal-to-C compiler

What I call an Uxntal-to-C compiler is a program that converts an Uxntal program into a C program that, when compiled with a C compiler and executed, has the same functionality as the Uxntal program has when assembled and run on the Uxn emulator. 

Why compile Uxntal to C? Mainly for fun, and out of curiosity. I was curious about the challenges involved and the limitations. Compiling Uxntal programs does result in speed-ups for compute-intensive applications. However, the fact that Uxn is computationally not very efficient is to my mind a bit of a red herring. As the main purpose of Uxn is to create interactive applications, the behaviour of these is dominated by the I/O activity, including the display and audio which are managed by SDL. The effect of the Uxntal code being compiled or interpreted will therefore be small for typical Uxn target, because either the program run time will be dominated by I/O waits or the computations will take place in the SDL layer. And that was another reason behind this experiment: it provides evidence. I verified my assumptions on a number of examples (see below), and the total power saving of the compiled version is negligible.

I initially considered [LLVM](https://llvm.org) and [WASM](https://webassembly.github.io) as targets. WASM seems attractive at first because it is purportedly stack based, but it turns out that loops are not stack based, nor is function argument passing. Both WASM and LLVM are typed assembly languages and assume that code and data are in separate memory spaces and that code is read-only, so they offer no additional benefit as a compilation target for Uxntal over C.

## Limitations

There are two aspects of Uxntal that can't be supported in an ahead-of-time C compiler with static code analysis. 

### Jumps to computed addresses

The first is jumps to computed addresses, because that is a concept that is not supported in C (nor in LLVM or WASM). A jump to a constant relative address can be resolved at compile time and supported, but run-time computed jumps have no equivalent. Fortunately, in practice Uxntal's linter discourages this for jumps longer than one instruction, and the allowed case of a run-time computed binary value is supported.

### Self-modifiable code

The second is self-modifiable code. In C, LLVM and WASM, code and data are separated and a program can't modify its on source. Fortunately, in practice the use of self-modification in Uxntal is limited to storing of local variables through code such as 

    LIT &x $1 
    
and evaluation of instructions from the stack using code such as 

    LIT MUL
    ... 
    #00 STR $1

Run-time evaluation through self-modification of the instructions is only supported for a specific case:

    #06 #07 LIT ADD 
    ...
    #00 STR BRK 

In principle, any store of a byte in the code memory results in self-modification, but the above is the most common pattern used to evaluate a byte on the stack as an instruction. 

Also fundamentally, the compiler expects human-readable Uxntal code, in particular it relies on the mnemonics to identify instructions. So while this is valid Uxntal code, it will not work:

    80 06 80 07 1a

It is in general impossible for a compiler to distinguish between opcodes and data because of Uxntal's dynamic nature. In fact, a value can be used as both depending on a run-time condition. So the compiler needs the meta-information provided by the mnemonic notation.

## Design

The overall approach is to use the runtime data structures used in the Uxn emulator, i.e. arrays that represent the ram, stacks and devices. Rather than reading bytes from the rom file and evaluating them using a case statement, we generate C code with subroutines corresponding to the instructions. The control flow is purely based on subroutine calls.

The design is quite simple. There is a Token sum type for all token variants and some record types for code blocks and the full program. All of these are in [`UxntalTypes`](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalTypes.rakumod). Definitions of the Uxntal operations are in [`UxntalDefs`](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalDefs.rakumod). 

Because of Uxntal's very regular structure, the [tokeniser](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalTokeniser.rakumod) is trivial (split on whitespace and newlines); the [parser](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalParser.rakumod) is using regular expressions and is also straightforward. Because Uxntal programs are simply sequences of instructions, labels and data of one or two bytes, the parser does need only limited context. We parse the code into a data type that reflects the different types of tokens as described on the [Uxntal page of the XXIIVV wiki](https://wiki.xxiivv.com/site/uxntal.html):


<table border="1">
	<tr><th colspan="4">Padding</th><th colspan="4">Literals</th></tr>
	<tr><td><code>|</code></td><td>absolute</td><td><code>$</code></td><td>relative</td><td><code>#</code></td><td colspan="3">literal hex</td></tr>
	<tr><th colspan="4">Labels</th><th colspan="4">Ascii</th></tr>
	<tr><td><code>@</code></td><td>parent</td><td><code>&</code></td><td>child</td><td><code>&quot;</code></td><td>raw word</td><td><code>&#39;</code></td><td>raw char</td></tr>
	<tr><th colspan="4">Addressing</th><th colspan="4">Pre-processor</th></tr>
	<tr><td><code>,</code></td><td>literal relative</td><td>.</td><td>literal zero-page</td><td><code>%</code></td><td>macro-define</td><td><code>~</code></td><td>include</td></tr>
	<tr><td><code>:</code></td><td>raw absolute</td><td><code>;</code></td><td>literal absolute</td></tr>
</table>


Then we perform two transformation passes:

- Replace all relative addressing by absolute addressing. 

    So after this step, only `@`, `.` and `;` remain. 

- Split the code into blocks and identify them as subroutines or data. 

    This is only slightly more complex because we need to add an explicit jump to the next block for blocks that do not end in a jump. Blocks that do not contain operations are considered data, all other blocks are subroutines. 
    
This transformation allows us to create equivalent C subroutines an  store the data in RAM. There are a few special cases, see the [`UxntalParser`](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalParser.rakumod) code for details. 

After this step we [analyse](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalAnalyser.rakumod) the code to determine which labels refer to subroutines and which to data. 

The main advantage of this approach is that it simplifies control flow handling: there is no need for `goto` statements or labels because Uxntal's label-based loops have been turned into recursive subroutines. So all we need to do is generate the code for those subroutines and the code to call them.

The actual [emitter](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalStackBasedCEmitter.rakumod) is straightforward because it relies on [a runtime library](https://codeberg.org/wimvanderbauwhede/nito/uxn-runtime-libs/) which contains a subroutine for every Uxntal instruction. 

In practice there are a few additional complications, specifically to handle the limited use of self-modification, and to handle conditional jumps. Also, the memory allocations and subroutine declarations need to be collected and grouped at the start of the source code, so there is quite a bit of state to be maintained.

Each instruction subroutine takes the required arguments from the stack and pushes its result on the stack, if any. Consequently, all subroutines have a signature `void f(void)`. This means all function pointers are of the same type. Because function pointers in C are machine size, we can't put them directly on the Uxn stack. Instead, we store them in a separate array and put the index into that array on the stack. 

With this approach, we can handle most of the dynamic nature of Uxntal.

## Optimisations 

### Inlining operations

The generated C code at this stage has a very large number of subroutine calls, and disappointingly the C compiler (gcc) does not inline most of them. So we do this ourselves in a [first optimisation pass](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalStackBasedCOpsEmitter.rakumod). This is easy (if cumbersome) because the subroutines don't take or return arguments and are guaranteed non-recursive, so we can simply replace the call with the definition.

### Stack to register 

A [second optimisation](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalStackBasedCOpsEmitter.rakumod) is more complicated but has also a much bigger effect on performance: we replace as much as possible stack operations with register operations. This is a little bit more complicated than at first sight appears. I might write a separate post about the algorithm.

###  Further optimisations

There are a number of further optimisations that could be considered, but all of them are more complex and would not result in a dramatic additional performance improvement. Some of them I have implemented but they are not enabled:

- [Inline subroutines](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalInliner.rakumod). This is only partially implemented. It is rather tricky because recursive subroutines can't be inlined, so we need an analysis to detect recursion. For simple, in-routine recursion that is easy, but recursion can occur through a chain of tail calls, so we need to identify tail calls and follow those through. 

- Use `goto` instead of function call. This is a simple optimisation which does not require a separate pass so it's done directly in the [emitter](https://codeberg.org/wimvanderbauwhede/nito/lib/UxntalStackBasedCEmitter.rakumod).

Both of these optimisations make little or no difference for most applications I tested so I don't enable them. Some other optimisations I have not finished implementing:

- Stack to register for subroutine calls. This is quite complicated, mostly because of recursion, but also because it is (in general) not possible to infer the type of a function called via a function pointers. 

- Stack to register for conditional blocks. This is the case where a condition is created through a computed jump, a typical example would be

    ... EQU JMP [ INC2 ] ...

So if `EQU` returns 0, `ADD2` will be executed, else it will be jumped over. The instruction has to be idempotent, and I think most commonly this is used with `JMP2r`. The effect on performance will generally be minimal.

## Performance

### Code used for testing

I did some limited performance evaluation using five command-line programs: three versions of `fib*`, `primes`, and `stencil`. With `-O=2` (inlined ops and stack-to-reg), the compiled version is up to 12x faster than the original version. With the additional optimisations this might increase a bit, maybe to     15x, but not more. 

The three version of the Fibonacci calculation are a modified version of [`uxn/projects/examples/exercises/fib.tal`](https://git.sr.ht/~rabbits/uxn/tree/main/item/projects/examples/exercises/fib.tal) and the two versions used in [an article](https://applied-langua.ge/posts/i-dont-want-to-go-to-chel-c.html) that criticised Uxn for being inefficient. 

The original [`fib.tal`](https://git.sr.ht/~rabbits/uxn/tree/main/item/projects/examples/exercises/fib.tal) is very terse (ignoring the `print` function):

    |0100 ( -> ) @reset

        #0000 INC2k ADD2k
        &loop
            ( print ) DUP2 ,print JSR
            ( linebreak ) #0a18 DEO
            ADD2k LTH2k ,&loop JCN
        ( halt ) #010f DEO

    BRK

I [modified it](https://codeberg.org/wimvanderbauwhede/nito/src/branch/main/demos/fib.tal) by writing a loop around it to repeat the calculations 2^16 times:

    #ffff #0000 &iterate
    ...
    INC2 GTH2k ,&iterate JCN

What I call `fib2.tal` is taken from the article:

    |0100

    #0020 ;fib JSR2
    #01 #0f DEO BRK

    @fib ( N -- fib[N] )
        DUP2 #0001 GTH2 ,&inductive-case; JCN JMP2r
        &inductive-case;
        DUP2 #0001 SUB2 ;fib JSR2 ( stack now N fib[N-1] )
        SWP2 #0002 SUB2 ;fib JSR2 ( stack now fib[N-1] fib[N-2] )
        ADD2 JMP2r

And `fib32.tal` is a 32-bit version of this code, also from that article:

    |0100

    #0020 ;fib JSR2
    #01 #0f DEO BRK

    @fib ( N -- fib[N] )
    ( not[n < 2] equivalent to n > 1 )
        DUP2 #0001 GTH2 ,&inductive-case; JCN #0000 SWP JMP2r
        &inductive-case;
        DUP2 #0001 SUB2 ;fib JSR2 ( stack now N fib[N-1] )
        ROT2 #0002 SUB2 ;fib JSR2 ( stack now fib[N-1] fib[N-2] )
        ;add32 JSR2 JMP2r

This uses the [32-bit math library](http://plastic-idolatry.com/erik/nxu/math32.tal).

I also tested [`uxn/projects/examples/exercises/primes.tal`](https://git.sr.ht/~rabbits/uxn/tree/main/item/projects/examples/exercises/primes.tal).

    |0100 ( -> ) @reset

        #0000 INC2k
        &loop
            DUP2 ,is-prime JSR #00 EQU ,&skip JCN
                DUP2 DUP2 ;mem STA2
                ,print/short JSR
                ( space ) #2018 DEO
                &skip
            INC2 NEQ2k ,&loop JCN
        POP2 POP2
        ;mem LDA2 ,print/short JSR
        ( halt ) #010f DEO

    BRK

    @is-prime	
        DUP2
        #0001 EQU2 ,&fail JCN
        STH2k
        #01 SFT2 #0002
        &loop
            STH2kr OVR2 ( mod2 ) [ DIV2k MUL2 SUB2 ] ORA ,&continue JCN
                POP2 POP2 POP2r #00 JMP2r
                &continue
            INC2  GTH2k ,&loop JCN
        POP2 POP2 POP2r #01
    JMP2r
        &fail POP2 #00 JMP2r

Finally, I wrote [`stencil.tal`](https://codeberg.org/wimvanderbauwhede/nito/src/branch/main/demos/stencil.tal), which is a 3-D 6-point stencil code, so the value of each point in a 3-D space is calculated based on the values of its six neighbours (i+1,i-1),(j+1,j-1),(k+1,k-1). This is a very common pattern in scientific computing and a good number crunching test. The code is a bit long to list here. It is a quadruple-nested loop: a time loop containing loops over the x, y and z directions of the 3-D space. At each point, the calculation is simply the weighted average of the current value and the sum of the six neighbours:


    .idx LDZ2 #0001 ADD2 LDA2 ( p(x-1,y,z) )
    .idx LDZ2 #0001 SUB2 LDA2 ( p(x+1,y,z) )
    ADD2
    .idx LDZ2 #0010 ADD2 LDA2 ( p(x,y-1,z) )
    .idx LDZ2 #0010 SUB2 LDA2 ( p(x,y+1,z) )
    ADD2
    ADD2
    .idx LDZ2 #0100 ADD2 LDA2 ( p(x,y,z-1) )
    .idx LDZ2 #0100 SUB2 LDA2 ( p(x,y,z+1) )
    ADD2 
    ADD2
    #0003 MUL2 

    .idx LDZ2 LDA2 ( p(x,y,z) ) 
    ADD2
    #0004 DIV2

The time loop repeats this calculation 2^16 times. 

### Performance results

I compiled these example with as optimisations inlining of operations and stack-to-register transformation. I used `time` to obtain the timings.

<table>
	<tr><th>Code</th><th>Emulated (s)</th><th>Compiled (s)</th><th>Speed-up</th></tr>
	<tr><td><code>fib.tal</code></td><td>1.57</td><td>0.96</td><td>1.6x</td></tr>
	<tr><td><code>fib2.tal</code></td><td>0.471</td><td>0.047</td><td>10x</td></tr>
	<tr><td><code>fib32.tal</code></td><td>1.86</td><td>0.151</td><td>12.3x</td></tr>
	<tr><td><code>primes.tal</code></td><td>6.9</td><td>0.93</td><td>7.4x</td></tr>
	<tr><td><code>stencil.tal</code></td><td>96.9</td><td>7.8</td><td>12.4x</td></tr>
</table>

For the examples with low speed-ups, the reason is that a lot of the time spend is I/O activity, which takes the same amount of time for the emulated and compiled versions:

    $ time uxncli fib.rom >/dev/null
    real	0m1.568s
    user	0m0.924s
    sys	0m0.644s

    $ time uxncliprog >/dev/null
    real	0m0.964s
    user	0m0.384s
    sys	0m0.580s

Even if we print to `/dev/null`, that still takes considerable I/O time.

For the tests without I/O (fib2, fib32, stencil), the speed-up is between 10x and 12.4x. I think with the additional optimisations, it might increase to maybe 15x but not more than that.

## Power consumption

Finally, I had a look at the power consumption of a typical GUI-based Uxn app. I used powertop with the [`bunnymark`](https://git.sr.ht/~rabbits/uxn/tree/main/item/projects/examples/demos/bunnymark.tal) benchmark, running 10,000 rabbits. I used `htop` for the CPU utilsation. 

My laptop is nearly three years old, it is a [PCSpecialist](https://www.pcspecialist.co.uk) Fusion IV, which is really a [TongFang](http://www.hk.tongfangpc.com/) PF4MN2F. The CPU is an Intel Core i7-10510U 1.80GHz and it has 16GB DDR4 memory. 

### Baseline

    System baseline power is estimated at 766 mW

    Power est.    Usage     Device name
    564 mW      3.1%        DRAM
    157 mW      3.1%        CPU core
    44.9 mW      3.1%        CPU misc

### Emulated

    15% CPU

    System baseline power is estimated at 7.98 W

    Power est.    Usage     Device name
    5.03 W     57.7%        CPU core
    1.43 W     57.7%        CPU misc
    1.02 W     57.7%        DRAM

### Compiled

    9% CPU

    System baseline power is estimated at 8.17 W

    Power est.    Usage     Device name
    5.09 W     55.4%        CPU core
    1.59 W     55.4%        CPU misc
    978 mW     55.4%        DRAM    

What we see is that most of the power is drawn by the CPU and that there is effectively no difference between the emulated and compiled versions. I measured this a few times and the error margin is about 0.5 W so within that margin the results are identical. I also measured the power consumption for emulated and compiled versions of other applications in the [`demos`](https://git.sr.ht/~rabbits/uxn/tree/main/item/projects/examples/demos) folder. They all consume considerably less power than bunnymark but there was no significant difference between emulated and compiled versions.

## Conclusion

The main takeaway of this experiment of compiling Uxntal to C is that it provides evidence that there is no need to do this for most Uxn applications: it will have no significant effect on performance or power consumption.

On the other hand, if you have to or want to you now can compile Uxntal to C and it can give speed-ups of the order of 10x for compute-heavy applications.

## Code

The compiler code and demos can be found [in my `nito` repo on Codeberg](https://codeberg.org/wimvanderbauwhede/nito). The README has the instructions and a list of the code on which I tested the compiler.

<br>

_The banner picture shows a row of bronze prayer wheels in a temple in Kyoto at night._ 