---
layout: article
title: "Writing faster Raku code"
date: 2020-12-02
modified: 2020-12-02
tags: [ coding, hacking, programming, raku, perl ]
excerpt: "Sometimes you want your Raku code to be faster. What does it take?"
current: "Writing faster Raku code"
current_image: writing-faster-raku_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: writing-faster-raku_1600x600.jpg
  teaser: writing-faster-raku_400x150.jpg
  thumb: writing-faster-raku_400x150.jpg
---

In [an earlier article]({{site.url}}/articles/writing-faster-perl), I discussed the result of my attempts to optimize the performance of an expression parser which is part of my Perl-based [Fortran source-to-source compiler](https://github.com/wimvanderbauwhede/RefactorF4Acc). An expression parser takes strings representing expressions in a programming language (in my case Fortran) and turns it into a data structure called a parse tree, which the compiler uses for further analysis and code generation.

I have recently been writing quite a bit of [Raku](https://raku.org/) code but so far I had not looked at its performance. Out of curiosity I decided to rewrite and optimise this Fortran expression parser in Raku.  

## Expression parsing

What I loosely call an expression parser is actually a combination of a [lexer](https://en.wikipedia.org/wiki/Lexical_analysis) and a [parser](https://en.wikipedia.org/wiki/Parsing#Parser): it turns a string of source code into a tree-like data structure which expresses the structure of the expression and the purpose of its constituents. For example if the expression is `2*v+1`, the result of the expression parser will be a data structure which identifies the top-level expression as a sum of a multiplication with  the integer constant `1`, and the multiplication of an integer constant `2` with a variable `v`. 

So how do we build a fast expression parser in Raku? It is not my intention to go into the computing science details, but instead to discuss the choices and trade-offs to be considered.

## Raku performance testing

An easily-made argument is that if you want performance, you should not write your code in Raku but in C/C++. And it is of course true that compiled code will almost always be faster. However, often, rewriting in a compiled language is not an option, so it is important to know how to get the best possible performance in Raku. 

The Raku documentation has [a page on performance](https://docs.raku.org/language/performance) which offers good advice in general terms. But for my needs I did not find the answers about the specific trade-offs that I might have to make. So I created some simple test cases to find out more. I used Raku version  `2020.09` built on MoarVM version `2020.09`, the most recent one when I ran the tests, but the results should be quite similar for slightly earlier and later versions.

I test the performance using a series of small test benches with different cases, controlled by a command line argument, using the `time` command to obtain the wall clock time, and taking the average over 5 runs. For example,

```bash
$ time raku test_hash_vs_regex.raku 1
```

## There is more than one way to do it, but only one will be the fastest

Parsing involves taking strings and turning them into other data structures, so there are many decisions to be made about the data structures and the ways to turn strings into them and manipulate them. Here are some results of performance comparisons that influenced design decisions for the compiler. I was curious to see if they would turn out different in Raku. 

### Hash key testing is faster than regexp matching

Fortran code essentially consists of a list of statements which can contain expressions, and in my compiler the statement parser labels each of the statements once using a hashmap. Every parsed line of code is stored as a pair of the original string `$src_line` with this hashmap, called `$info`:

```perl    
my $parsed_line = [ $src_line, $info ];
```

The labels and values stored in `$info` depend on the type of statement. It is not _a priori_ clear if matching a pattern in `$src_line` using a regex is faster or slower than looking up the corresponding label in `$info`. So I tested the performance of hash key testing versus regexp matching, using some genuine FORTRAN 77 code, a `READ` I/O call, labelled in `$info` as `ReadCall`:

```perl6
my $str = lc('READ( 1, 2, ERR=8, END=9, IOSTAT=N ) X');
my $info = {};   
if ($str~~/read/) {
    $info<ReadCall> = 1;
}
my $count=0;

constant NITERS = 10_000_000;
if CASE==1 {
    for 1..NITERS -> $i {
# regexp        
        if ($str~~/read/) { 
            $count+=$i;
        }
    }
} elsif CASE==2 {
    for 1..NITERS -> $i {
# hash lookup        
            if ($info<ReadCall>:exists) {
                $count+=$i;
            }
    }   
} elsif CASE==3 {
    for 1..NITERS -> $i {
# overhead        
                $count+=$i;
    }    
}
```

Without the `if`-condition in its body (CASE==3), the `for 1..NITERS` loop takes 3 s on my laptop. The loop with with the hash key existence test takes 5 s; the regexp match condition takes 53 s. So the actual condition evaluation takes 2 s for hash key existence check and 50 s for regexp match. So testing hash keys is 25 times faster than simple regexp matching. So we trade some memory for computation: we identify the statement once using a regexp, an store the identifying label in `$info` for subsequent passes.

<b>Result:</b> Testing hash keys is 25 times faster than simple regexp matching. So we trade some memory for computation: we identify the statement once using a regexp, an store the identifying label in `$info` for subsequent passes.

### A fast data structure for the parse tree: integer versus string comparison

The choice of the data structure for the parsed expression matters. As we need a tree-like ordered data structure, it would have to either an object or a list-like data structure. But objects in are slow, so I use a nested array.

```perl6
['+',
    ['*',
        2,
        ['$','v']
    ],
    1
]
```

<!-- ### Integer comparison is faster than string comparison -->

This data structure is fine if you don't need to do a lot of work on it. However, because every node is labelled with a string, testing against the node type is a string comparison. Simply testing against a constant string or integer is not good enough as the compiler might optimise this away. So I tested this as follows to make sure `$str` and `$c` get a new value on every iteration: 

```perl6
if CASE==1 { # 7.3 - 5.3 = 2 s net
    for 1 .. NITERS -> $i {
# string equality        
        my $str = chr($i % 43);
        if $str eq '*' {
            $count+=$i;
        }
    }
} 
elsif CASE==2 { # 3.3 - 3.1 = 0.3
    for 1..NITERS -> $i {
# int equality        
        my $c = $i % 43;
        if $c == 42 {
            $count+=$i;
        }
    }
} elsif CASE==3 { # 5.3
    for 1..NITERS -> $i {
# string equality overhead        
        my $str = chr($i % 43);
    }
} elsif CASE==4 { # 3.1
    for 1..NITERS -> $i {
# int equality overhead
        my $c = $i % 43;
    }
}
```

I populate the string or integer based on the loop iterator and then perform a comparison to a constant string or integer. By subtracting the time taken for the assignment (cases 3 and 4) I obtain the actual time for the comparison. 

On my laptop, the version with string comparison takes 2 s net, the integer comparison 0.3 s. So doing string comparisons is at least 5 times slower than doing integer comparisons. Therefore my data structure uses integer labels. Also, I label the constants so that I can have different labels for string, integer and real constants, and because in this way all nodes are arrays. This avoids having to test if a node is an array or a scalar, which is a slow operation.

So the example becomes :

```perl
[ 3,
  [ 5,
    [ 29, '2' ],
    [ 2, 'v' ]
  ],
  [ 29, '1' ]
]
```

Less readable, but faster and easier to extend. In what follows, what I call the _parse tree_ is this data structure.

<b>Result:</b> String comparisons is at least 5 times slower than doing integer comparisons.

### Custom tree traversals are faster

I tested the cost of using higher-order functions for parse tree traversal (recursive descent). Basically, this is the choice between a generic traversal using a higher-order function which takes an arbitrary function that operates on the parse tree nodes: 

```perl6
sub _traverse_ast_with_action($ast_, $acc_, &f) {
    my $ast=$ast_; my $acc=$acc_;
    if <cond> { 
        $acc=&f($ast,$acc);
    } else { 
        $acc=&f($ast,$acc);
        for  1 .. $ast.elems - 1  -> $idx {
            (my $entry, $acc) = 
                _traverse_ast_with_action($ast[$idx],$acc, &f);
            $ast[$idx] = $entry;
        }
    }
    return ($ast, $acc);
} 
```

or a custom traversal:

```perl6
sub _traverse_ast_custom($ast_, $acc_) {
    my $ast=$ast_; my $acc=$acc_;
    if <cond> { 
        $acc=< custom code acting on $ast and $acc>;
    } else { 
    $acc=< custom code acting on $ast and $acc>;
        for 1 .. $ast.elems - 1  -> $idx {
            (my $entry, $acc) = 
                _traverse_ast_custom($ast[$idx],$acc);
            $ast[$idx] = $entry;
        }
    }
    return ($ast, $acc);
} 

```


For the case of the parse tree data structures in my compiler, the higher-order implementation takes more than twice as long as the custom traversal, so for performance this is not a good choice. Therefore I don't use higher-order functions in the parser, but I do use them in the later refactoring passes.

<b>Result:</b> Higher-order implementations of recursive descent take more than twice as long as custom traversals.

### The fastest way to process a list

The internal representation of a Fortran program in my compiler is an list of `[ $src_line, $info ]` pairs and the `$info` hash stores the parse tree as a nested array. So iterating through lists and arrays is a major factor in the performance.  

Raku has several ways to iterate through a list-like data structure. I tested six of them, as follows: 

```perl
constant NITERS = 2_000_000;
if CASE==0 { # 6.2 s
# map
    my @src = map {$_}, 1 .. NITERS;
    my @res = map {2*$_+1}, @src;
} elsif CASE==1 { # 7.9 s
# for each elt in list
    my @res=();
    my @src=();
    for 1..NITERS -> $elt {
        push @src, $elt;
    }
    for @src -> $elt {
        push @res, 2*$elt+1;
    }
} elsif CASE==2 { # 6.2 s
# for with index
    my @res=();
    my @src=();
    for 0..NITERS-1 -> $idx {
        my $elt=$idx+1;
        @src[$idx] = $elt;
    }
    for 0..NITERS-1 -> $idx {
        my $elt=@src[$idx];
        @res[$idx] = 2*$elt+1;
    }
} elsif CASE==3 { # 11.0
# loop (C-style)
    my @res=();
    my @src=();
    loop (my $idx=0;$idx < NITERS;++$idx) {
        my $elt=$idx+1;
        @src[$idx] = $elt;
    }
    loop (my $idx2=0;$idx2 < NITERS;++$idx2) {
        my $elt=@src[$idx2];
        @res[$idx2] = 2*$elt+1;
    }
} elsif CASE==4 { # 3.7 s
# postfix for with push
    my @src = ();
    my @res=();
    push @src, $_ for 1 .. NITERS;
    push @res, 2*$_+1 for @src;
} elsif CASE==5 { # 3.5 s
# comprehension
    my @src = ($_ for 1 .. NITERS);
    my @res= (2*$_+1 for @src);
}
```

The fastest way is to use list comprehension (case 5, 3.5 s), very closely followed by the suffix-style `for` (case 4, 3.7 s). The C-style `loop` construct (case 3) is the slowest (11 s). The `map` version performs the same as the index-based `for` loop (both 6.2 s). It is a bit odd that the list-based for loop, probably the most common loop construct, is slower than these two (7.9 s).

<b>Result:</b> List comprehensions are fastest, almost twice as fast as `for`-loops or `map`s. C-style `loop` is very slow.

### Parsing: regular expressions, string comparisons or list operations?

Finally, we have to decide how to parse the expression string. The traditional way to build an expression parser is using a Finite State Machine, consuming one character at a time (if needed with one or more characters look-ahead) and keeping track of the identified portion of the string. This is very fast in a language such as C but in Raku I was not too sure, because in Raku a character is actually a string of length one, so every test against a character is a string comparison. On the other hand, Raku has a sophisticated regular expression engine. Yet another way is to turn the string into an array, and parse using list operations. Many possibilities to be tested:


```perl6
constant NITERS = 100_000;
my $str='This means we need a stack per type of operation and run until the end of the expression';
my @chrs =  $str.comb;
if (CASE==0) { # 5.8 s
    for 1 .. NITERS -> $ct {
# map on an array of characters        
        my @words=();
        my $word='';
        map(-> \c { 
            if (c ne ' ') {
                $word ~= c;
            } else {
                push @words, $word;
                $word='';
            }
        }, @chrs);
        push @words, $word;
    }
} elsif CASE==1 { # 2.7 s    
     for 1 .. NITERS -> $ct {
# while with index through a string        
        my @words=();
        my $str='This means we need a stack per type of operation and run until the end of the expression';
        while my $idx=$str.index( ' ' ) {
            push @words, $str.substr(0,$idx);
            $str .= substr($idx+1);
        }
        push @words, $str;
    }         
} elsif CASE==2 {  # 11.7 s
    for 1 .. NITERS -> $ct {
# while on an array of characters        
        my @words=();
        my @chrs_ = @chrs; 
        my $word='';      
        while @chrs_ {
            my $chr = shift @chrs_;
            if ($chr ne ' ') {
                $word~=$chr;
            } else {
                push @words, $word;
                $word='';
            }
        }
        push @words, $word;
    }
} elsif CASE==3 { # 101 s
    for 1 .. NITERS -> $ct {
# while on a string using a regexp        
        my @words=();
        my $str='This means we need a stack per type of operation and run until the end of the expression';
        while $str.Bool {
            $str ~~ s/^$<w> = [ \w+ ]//;
            if ($<w>.Bool) {
                push @words, $<w>.Str;
            }
            else {
                $str ~~ s/^\s+//;
            } 
        }
    }   
} elsif CASE==4 { # 64 s
    for 1 .. NITERS -> $ct {
# reduce on an array of characters        
        my \res = reduce(
        -> \acc, \c { 
            if (c ne ' ') {
                acc[0],acc[1] ~ c;
            } else {
                ( |acc[0], acc[1] ),'';
            }
        }, ((),''), |@chrs);
        my @words = |res[0],res[1];
}
```

For the list-based version, the overhead is 1.6 s; for the string-based versions, 0.8s.

The results are rather striking. Clearly the regexp version is by far the slowest. This was a surprise because in my Perl implementation, the regexp version was twice as fast as next best choice. From the other implementations, the string-based FSM which uses the `index` and `substr` methods is by far the fastest, without the overhead it takes 1.9s s, which is more that 50 times faster than the regexp version. The `map` based version comes second but is nearly twice as slow. What is surprising, and actually a bit disappointing, is that the `reduce` based version, which works the same as the `map` based one but works on immutable data, is also very slow, 64 s. 

In any case, the choice is clear. It is possible to make the fastest version  marginally faster (1.6 s instead of 1.9 s) by not reducing the string but instead moving the index through the string. However, for the full parser I want to have the convenience of the `trim-leading` and `starts-with` methods, so I choose to consume the string.


<b>Result:</b> Using `index` and `substr` methods is much faster than using regexps.


## A faster expression parser

With the choices of string parsing and data structure made, I focused on the structure of the overall algorithm. The basic approach is to loop trough a number of states and in every state perform a specific action. In the Perl version this was very simple because we use regular expressions to identify tokens, so most of the state transitions are implicit. I wanted to keep this structure so I emulate the regexp `s///` operation with comparisons, indexing and substring operations.

```perl
my $prev_lev=0;
my $lev=0;
my @ast=();
my $op;
my $state=0;
while (length($str)>0) {
     # Match unary prefix operations
     # Match terms
     # Add prefix operations if matched
     # Match binary operators
     # Append to the AST
}
```
The matching rules and operations are very simple (I use `<pattern>` and `<integer>` as placeholders for the actual values). Here is the Perl version for reference:

* prefix operations:

```perl
if ( $str=~s/^<pattern>// ) { $state=<integer>; } 
```

* terms:

```perl
if ( $str=~s/^(<pattern>)// ) { $expr_ast=[<integer>,$1]; }
```    

* operators:

```perl
$prev_lev=$lev;
if ( $str=~s/^<pattern>// ) { $lev=<integer>; $op=<integer>; }
```    

In the Raku version I used the `given`/`when` construct, which is as fast as an `if` statement but a bit neater.

* prefix operations:

```perl6
given $str {
    when .starts-with(<token>) { 
        .=substr(<length of token>); 
        $state<integer>; }
```

* terms:

```perl6
given $str
    when .starts-with(<token start>) { 
        $expr_ast=[<integer>,$term]; }
```    

* operators:

```perl6
given $str {
    when .starts-with(<token>) { 
        .=substr(<length of token>); 
        $lev=<integer>; 
        $op=<integer>; 
    }
```    

One of the more complex patterns to match is the case of an identifier followed by an opening parenthesis with optional whitespace. Using regular expressions this pattern would be:

```perl6
if  $str ~~ s:i/^ $<token> = [ [a .. z] \w*] \s* \( // { 
    my $var=$<token>.Str;
    ... 
}
```

Without regular expressions, we first check for a character between 'a' and 'z' using `'a' le .substr(0,1).lc le 'z'`. If that matches, we remove it from `$str` and add it to `$var`. Then we go in a `while` loop for as long as there are characters that are alphanumeric or '_'. Then we strip any whitespace and test for '('. 

```perl6
when 'a' le (my $var = .substr(0,1)).lc le 'z' {
    my $idx=1;
    my $c = .substr($idx,1);
    while 'a' le $c.lc le 'z' or $c eq '_' 
        or '0' le $c le '9' {
        $var~=$c;
        $c = .substr(++$idx,1);
    }
    .=substr($idx);
    .=trim-leading;
    if .starts-with('(') {
        ...
    }
}
```

Another complex pattern is that for a floating point number. In Fortran, the pattern is more complicated because the sub-pattern `.e` can be part of a floating-point constant but could also be the part of the equality operator `.eq.`. Furthermore, the separator between the mantissa and the exponent can be not just `e` but also `d` or `q`. So the regular expression is rather involved:

```perl6
if (                    	
    (
        !($str~~rx:i/^\d+\.eq/) and
        $str~~s:i/^([\d*\.\d*][[e|d|q][\-|\+]?\d+]?)//        
    )        	
    or 
    $str~~s:i/^(\d*[e|d|q][\-|\+]?\d+)//
) {
    $real_const_str=$/.Str;
} 
```

Without regular expression, the implementation is as follows. We first detect a character between 0 and 9 or a dot. Then we try to match the mantissa, separator, sign and exponent. The latter three are optional; if they are not present and the mantissa does not contain a dot, we have matched an integer. 

```perl6
when '0' le .substr(0,1) le '9' or .substr(0,1) eq '.' { 
    my $sep='';
    my $sgn='';
    my $exp='';
    my $real_const_str='';

    # first char of mantissa
    my $mant = .substr(0,1);
    # try and match more chars of mantissa
    my $idx=1;
    $h = .substr($idx,1);
    while '0' le $h le '9' or $h eq '.' {
        $mant ~=$h;
        $h = .substr(++$idx,1);
    }
    $str .= substr($idx);

    # reject .eq.
    if not ($mant.ends-with('.') and .starts-with('eq',:i)) { 
        if $h.lc eq 'e' | 'd' | 'q' {
            # we found a valid separator
            $sep = $h;            
            my $idx=1;
            $h =.substr(1,1);
            # now check if there is a sign
            if $h eq '-' or $h eq '+' {
                ++$idx;
                $sgn = $h;
                $h =.substr($idx,1);
            }
            # now check if there is an exponent            
            while '0' le $h le '9' {
                ++$idx;
                $exp~=$h;
                $h =.substr($idx,1);
            }
            $str .= substr($idx);
            if $exp ne '' {
            $real_const_str="$mant$sep$sgn$exp";
            $expr_ast=[30,$real_const_str];
            } else {
                # parse error
            }
        } elsif index($mant,'.').Bool {
            # a mantissa-only real number
            $real_const_str=$mant;
            $expr_ast=[30,$real_const_str];
        }
        else { # no dot and no sep, so an integer
            $expr_ast=[29,$mant];   
        }
    } else { # .eq., backtrack and carry on
        $str ="$mant$str";        
        proceed;
    }            
}
```

A final example of how to handle patterns is the case of whitespace in comparison and logical operators. Fortran has operators of the form `<dot word dot>`, for example `.lt.` and `.xor.`. But annoyingly, it allows whitespace between the dot and the word, e.g. `. not .`. Using regular expressions, this is of course easy to handle, for example:

```perl6
if $str~~s/^\.\s*ge\s*\.//) {
    $lev=6;
    $op=20;
} 
```

I check for a pattern starting with a dot and which contains a space before the next dot. Then I remove all spaces from that substring using `trans` and replace this original string with this trimmed version. 

```perl6
when .starts-with('.') and  .index( ' ' ) 
    and (.index( ' ' ) < (my $eidx = .index('.',2 ))) {
    
    # Find the keyword with spaces
    my $match = .substr(0, $eidx+1);
    # remove the spaces
    $match .= trans( ' ' => '' );
    # update the string
    $str = $match ~ .substr( $eidx+1);
    proceed;
}
```

## Conclusion

Overall the optimised expression parser in Raku is still very close to the Perl version. The key difference is that the Raku version does not use regular expressions. With the above examples I wanted to illustrate how it is possible to write code with the same functionality as a regular expression `s///` operation, using some of Raku's built-in string operations:

* `substr` : substring
* `index` : location a a substring in a string
* `trim-leading` : strip leading whitespace
* `starts-with`
* `ends-with`
* `trans` : used to remove whitespace using the `' ' => ''` pattern
* `lc` : used in range tests instead of testing against both upper and lower case
* `le`, `lt`, `ge`, `gt`: for very handy range comparisons, e.g. `'a' le $str le 'z'`

The resulting code is of course much longer but arguably more readable than regular expressions, and currently four times faster.

I ran a lot more tests, and compared performance against Perl and Python as well, but that is another story. All code for the tests is available in [my GitHub repo](https://github.com/wimvanderbauwhede/raku-examples/tree/master/Performance-analysis).


<!-- Operators have precedence and associativity, and Fortran requires twelve precedence levels. In the "Append to AST" state, the parser uses `$lev` and `$prev_lev` to work out how the previously matched `$expr_ast` and `$op` should be appended to the `@ast` array. The prefix operations are handled by setting a state which is checked after term matching. The actual code is a bit more complicated because we need to parse array index expressions and function calls as well. This is done recursively during term matching; if a function call has multiple arguments, the parser is put into a new `$state`. 

So the end result is a minimally recursive parser, i.e. it only uses recursion when it is really necessary. 

There is a lot of repetition of the patterns for matching terms and operators because if I would instead abstract the `<pattern>` and `<integer>` values by e.g. storing them in an array, the array accesses would considerably reduce the performance. I do store the precedence levels in an array because there are so many of them that the logic for appending terms to the AST would otherwise become very hard to read and update. -->

<!-- ## Expression parser performance

I tested the new expression parser on a set of 50 different expressions taken from a weather simulation code. The old expression parser takes 45 s to run this test a thousand times; the new expression parser takes only 2 s. In other words, the new parser is *more than twenty times faster* than the old one. 

It is also quite easy to maintain and adapt despite its minimal use of abstractions, and because it is Fortran-specific, the rest of the code has become a lot cleaner too. You can find the code in [my GitHub repo](https://github.com/wimvanderbauwhede/RefactorF4Acc/blob/devel/RefactorF4Acc/Parser/Expressions.pm). -->



<!-- Here is a summary of all optimisations I tested. The tests were run using Perl v5.28 on a MacBook Pro (late 2013), timings are averages over 5 runs and measured using `time`.

<table>
  <thead>
<tr>
<th>
Optimisation
</th>
<th>
Speed-up
</th>

</tr>
  </thead>
   <tbody>
<tr>
<td> Hash key testing is faster than regexp matching </td><td> 3&times; </td>
</tr>
<tr>
<td> Custom tree traversals are faster than generic ones </td><td> 2&times; </td>
</tr>
<tr>
<td> `foreach` is faster than `map` </td><td> 1.3&times; </td>
</tr>
<tr>
<td> `foreach` is faster than indexed `for` </td><td> 1.4&times; </td>
</tr>
<tr>
<td> `foreach` is faster than C-style `for` </td><td> 1.7&times; </td>
</tr>
<tr>
<td> Integer comparison is faster than string comparison </td><td> 1.5&times; </td>
</tr>
<tr>
<td> Regexp matching is faster than successive string comparisons </td><td> 2.2&times; </td>
</tr>

 </tbody>
<table> -->
