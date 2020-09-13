---
layout: article
title: "Cleaner code with functional programming"
date: 2020-07-18
modified: 2020-07-18
tags: [ coding, hacking, programming, raku ]
excerpt: "An introduction to some powerful functional programming techniques in Raku and Python."
current: "Cleaner code with functional programming"
current_image: decluttering-with-functional-programming_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: decluttering-with-functional-programming_1600x600.jpg
  teaser: decluttering-with-functional-programming_400x150.jpg
  thumb: decluttering-with-functional-programming_400x150.jpg
---

<!-- To a functional programmer like me, every programming language is a functional language. --> 
Functional programming is a style of programming and modern languages support this style to a greater or lesser extent. In this article I want to explain how programming in a functional style provides you with powerful abstractions to make your code cleaner. I will illustrate this with examples in Raku and Python, which as we will see are both excellent languages for functional programming.

## Raku: a quick introduction

The code examples in this article are written in [Python](https://www.python.org/) and [Raku](https://raku.org/). I assume most people are familiar with Python, but Raku is less well known, so I will explain the basics first. The code in this article is not very idiomatic so you should be able to understand it easily if you know another programming language.

Raku is most similar to [Perl](https://www.perl.org). Both languages are syntactically similar to C/C++, Java and JavaScript: block-based, with statements separated by semicolons, blocks demarcated by braces, and argument lists in parentheses and separated by commas. The main feature that sets Perl and Raku apart from other languages is the use of sigils ('funny characters') which identify the type of a variable: `$` for a scalar, `@` for an array, `%` for a hash (map) and `&` for a subroutine. Variables also have keywords to identify their scope, I will only use `my` which marks the variable as lexically scoped. A subroutine is declared with the `sub` keyword, and subroutines can be named or anonymous:

```perl6
sub square ($x) {
    $x*$x;
}
# anonymous subroutine 
my $anon_square = sub ($x) {
    $x*$x;
}
```

In Python this would be:

```python
def square(x):
    return x*x

# anonymous subroutine 
anon_square = lambda x: x*x
```


<!-- Raku also has [twigils](https://docs.raku.org/language/variables#index-entry-Twigil), secondary sigils that influence the scoping of a variable. For this article, the only twigil used in the code is `.` which is used to declare a role or class attribute with automatically generated accessors (like `$.notes` in the example below). -->

Raku supports sigil-less variables, and uses the `\` syntax to declare them. For more on the difference between ordinary and sigil-less variables, see [the Raku documentation](https://docs.raku.org/language/variables#Sigilless_variables). For example (`say` prints its argument followed by a newline):

```perl6
my \x = 42; # sigilless
my $y = 43; 
say x + $y; 
```

In the code in this article, I will use the sigil-less variables whenever possible.

Raku has several types of sequence data structures. In the code below I will use [lists and arrays](https://docs.raku.org/language/list) and [ranges](https://docs.raku.org/type/Range). The main difference between a list and an array in Raku is that a list is immutable, which means that once created, it can't be modified. So it is a read-only data structure. To 'update' an immutable data structure, you need to create an updated copy. Arrays on the other hand are mutable, so we can update their elements, extend them, shrink them etc. All updates happen in place on the original. 

Raku's arrays are similar to Python's lists and Raku's lists are similar to Python's tuples, which are also immutable. Apart from the syntax, ranges in Raku are similar to ranges in Python, and both are immutable.

```perl6
my @array1 = 1,2,3; #=> an array because of the '@' sigil
my \array2 = [1,2,3]; #=> an array, because of the '[...]'

my \range1 = 1 .. 10; #=> a range 1 .. 10
my @array3 = 1 .. 10; #=> an array from a range, because of the '@' sigil

my \list1 = 1,2,3; #=> a list
my $list2 = (1,2,3); #=> also a list
my \list3 = |(1 .. 10);  #=> an array from a range because of the '|' flattening operation
```

The equivalent Python code would be

```python
list1 = list((1,2,3)) #=> a list from a tuple
list2 = [1,2,3]; #=> a list, because of the '[...]'

range1 = range(1,11) #=> a range 1 .. 10
list3 = list(range(1,11)); #=> a list from a range

tuple1 = 1,2,3; #=> a tuple
tuple2 = tuple([1,2,3]) #=> a tuple from a list
tuple3 = tuple(range(1,11)) #=> creates a tuple from a range
```

Other specific bits of syntax or functionality will be explained for the particular examples. 

## _A function, by any other name_ &mdash; functions as values

Functions are the essence of functional programming. As I explained in my article ["Everything is a function"]({{ site.url }}/articles/everything-is-a-function), in a proper functional language, all constructs are built from functions. 

All modern programming languages have a notion of functions, procedures, subroutines or methods. They are an essential mechanism for code reuse.
Typically, we think of a function as something that operates on some input values to produce one or more output values. The input values can be globally declared, attributes of a class or passed as arguments to the function. Similarly, the output values can be returned directly, to global variables, as class attributes or by modifying the input values. 

To benefit most from functional programming, it is best if functions are _pure_, which means that a call to the function always produces the same output for the same inputs. In practice, this is easier to achieve if the function only takes inputs as arguments and returns the output directly, but this is not essential.

The crucial feature of functional programming is that the input and output values of a function *can themselves be functions*. So functions must be values in your language. Sometimes this is called "functions must be first-class", and a function that takes and/or returns a function is sometimes called a "higher-order function". 

If functions are values, it follows that we can assign them to variables. In particular we will assign them to the arguments of other functions. But we can also assign them to ordinary variables. 

Let's consider the following function, `choose`, which takes three arguments `t`, `f` and `c`. 
 
```perl6
# Raku
sub choose (\t, \f, \d) {
	if (d) {t} else {f}
}
```
```python
# Python
def choose (t, f, d):
  if d:
    return t 
  else:
    return f
```

First let's call `choose` with strings as values for the first two arguments:

```perl6
# Raku
my \tstr = "True!";
my \fstr = "False!";

my \res_str = choose(tstr, fstr, True);

say res_str; #=> says "True!"
```

```python
# Python
tstr = "True!"
fstr = "False!"

res_str = choose(tstr,fstr,True)

print(res_str) #=> says "True!"
```
Now let's try with functions as arguments:

```perl6
# Raku
sub tt (\s) { say "True {s}!" }
sub ff (\s) { say "False {s}!" }

my &res_f = choose(&tt, &ff, False);

say &res_f; #=> says &ff
res_f("rumour"); #=> says "False rumour!"
```

```python
# Python
def tt(s):
  print( "True "+s+"!")
def ff(s):  
  print( "False"+s+"!")

res_f = choose(tt,ff,True)

print(res_f) #=> says <function tt at 0x7f829c3aa310>
res_f("rumour") #=> says "False rumour!"
```

So our function `choose` took two functions as its first two arguments, and returned a function. In Raku we need the `&` sigil on the function names because otherwise they would be evaluated: a bare function name like `tt` is the same as calling the function without arguments, `tt()`. By assigning this function to a variable (`res_f`), we can now call `res_f` as a function and it will eventually call `tt` or `ff` depending of the choice.

## Functions don't need a name

Now, if we can assign functions to variables, they don't really need a name themselves. So our functions can be anonymous. Most languages support anonymous functions. In functional languages they are usually called ["lambda functions"]({{ site.url }}/articles/everything-is-a-function/). In Raku, we have two ways to create anonymous functions:

Using the `sub (...)` syntax:

```perl6
my \tt = sub (\s) { say "True {s}!" };
```

Or using the ['pointy block' syntax](https://docs.raku.org/language/functions#index-entry-pointy_blocks), which is a little bit more compact:

```perl6
my \ff = -> \s { say "False {s}!" };
```

Python uses the `lambda` keyword:

```python
tt = lambda s : print( "True "+s+"!" )
ff = lambda s : print( "False "+s+"!" )
```

So now we can say

```perl6
my &res_f = choose(tt, ff, True);

say &res_f; #=> says sub { }
res_f("story"); #=> says "True story!"
```

When we print out the variable to which the function is bound, Raku returns `sub { }` to indicate that the variable contains a function.

In Python:

```python
res_f = choose(tt, ff, True);

print( res_f) #=> says <function <lambda> at 0x7f829b298b80>
res_f("story") #=> says "True story!"
```

## Examples: `map`, `grep` and `reduce`

Functions of functions have many uses, and I just want to highlight three examples that are available readily in Raku: `map`, `reduce` and `grep`. Python has `map` and `filter`, and provides `reduce` via the `functools` module. What these functions have in common is that they offer an alternative to `for`-loops over lists.

### `map` : applying a function to all elements of a list

`map` takes two arguments: a function and a list. It applies the function to all values in the list in order and returns the results, for example to square all values in a list:

```perl6
my \res = map -> \x {x*x} , 1 .. 10;
```

In Python we need to explicitly create the tuple, but apart from the syntax differences, the structure is quite the same:

```python
res = tuple( map( lambda x : x*x , range(1,11)))
```

This is the functional alternative to the more conventional `for`-loop:

```perl6
# Raku
my \res = [];
for 1 .. 10 -> \x {
	res.push(x*x);
}
```

```python
# Python
res = []
for x in range(1,11):
	res.append(x*x)
```

Note that in both Raku and Python we need to use a mutable data structure for the `for`-loop version, whereas the `map` version uses immutable data structures.

### `grep` : filtering a list

`grep` (called `filter` in Python) also takes arguments, a function and a list, but it only returns the values from the list for which the function returns `true`:

```perl6
# Raku
my \res = grep -> \x { x % 5 == 0 }, 1 .. 30;
```

```python
# Python
res = tuple(filter( lambda x : x % 5 == 0 ,range(1,31)))
```

We can of course write this using a `for`-loop and an `if`-statement, but that again requires a mutable data structure:  

```perl6
# Raku
my \res = [];
for 1 .. 30 -> \x {
	if (x % 5 == 0) {
	res.push(x);
	}
}
```
```python
# Python
res = []
for x in range(1,31): 
  if (x % 5 == 0):
    res.append(x)
```

What's nice about `map` and `grep` is that you can easily chain them together:

```perl6
# Raku
grep -> \x { x % 5 == 0 }, map -> \x {x*x}, 1..30
```
```python
# Python
res = tuple(filter( lambda x : x % 5 == 0 ,map( lambda x : x*x ,range(1,31))))
```

This is because `map` and `grep` take a list and return a list, so as long as you need to operate on a list, you can do this by chaining the calls.


### `reduce` : combining all elements of a list into a single value

`reduce` also takes a function and a list, but it uses the function to combine all elements of the list into a single result. So the function must take two arguments. The _second_ argument is the element taken from the list, and the first argument is used as a state variable to combine all elements. For example, calculating the sum of a list of numbers:

```perl6
# Raku
my \sum = reduce sub (\acc,\elt) {acc+elt}, 1 .. 10;

say sum; #=> says 55
```

```python
# Python
from functools import reduce

sum = reduce(lambda acc,elt: acc+elt, range(1,11))

print( sum); #=> says 55
```

What happens here is that `acc` is first set to the first element of the list (1), and then the second element is added to it, so `acc` becomes 1+2=3; then the third element (3) is added to this, and so on. The effect is to consecutively sum all the numbers in list.

To make this more clear, let's write our own version of `reduce`.

### Writing your own

In many functional languages, a distinction is made between a left-to-right (starting at the lowest index) and right-to-left (starting at the highest index) reduction. This matters because depending on the function doing the reducing, the result can be different if the list is consumed from the left or from the right. For example, suppose our reducing function is

```perl6
# Raku
-> \x,\y {x+y}
```
```python
# Python
lambda x,y: x+y
```

then it does not matter which direction we traverse the list. But consider the following function:

```perl6
# Raku
-> \x,\y { x < y ?? x+y !! x }
```

```python
# Python
lambda x,y: x+y if x<y else x
```
( ` ... ?? ... !! ...` is the Raku syntax for the conditional operator which is  `... ? ... : ...` in most other languages and `... if ... else ...` in Python)

In this case the result will be different if the list is reduced from the left or from the right. In Raku and Python, `reduce` is a left-to-right reduction.     

Also, instead of using the first element of the list, the reduction function can take an additional argument, usually called the accumulator. In functional languages, reduce is usually  called _fold_, so we can have a left fold and a right fold. Let's have a look how we could implement these. 

#### Left fold

A straightforward way to implement a left fold (so the same as `reduce`) is to use a `for`-loop inside the function. That means we have to update the value of the accumulator on every iteration of the loop. In Raku, sigil-less variables are immutable (I am simplifying here, see [the Raku documentation](https://docs.raku.org/language/containers#Binding) for the full story) so we need to use a sigiled variable, `$acc`. 

```perl6
# Raku
sub foldll (&f, \iacc, \lst) { 
  my $acc = iacc; 
  for lst -> \elt {
    $acc = f($acc,elt);
  }
  $acc;
}
```

```python
# Python
def foldll (f, iacc, lst):
  acc = iacc
  for elt in lst:
    acc = f(acc,elt)  
  return acc
```

If we want to use immutable variables only, we can use recursion. Raku makes this easy because it allows multiple signatures for a subroutine (`multi sub`s), and it will call the variant that matches the signature. In Python, there is the module [multipledispatch](https://pypi.org/project/multipledispatch/) that lets you do something similar to multi subs.

Our `foldl` will consume the input list `lst` and use `f` combine its elements into the accumulator `acc`. When the list has been consumed, the computation is finished and we can return `acc` as the result. So our first variant says that if the input list is empty, we should return `acc`.
The second variant takes an element `elt` from the list (see [the Raku documentation](https://docs.raku.org/type/Range) for details on the `*`) and combines it with `acc` into `f(acc,elt)`. It then calls `foldl` again with this new accumulator and the remainder of the list, `rest`.

```perl6
# When the list is empty, return the accumulator
multi sub foldl (&f, \acc, ()) { acc }
multi sub foldl (&f, \acc, \lst) {
  # Raku's way of splitting a list in the first elt and the rest
  # The '*' is a shorthand for the end of the list
   my (\elt,\rest) = lst[0, 1 .. * ]; 
   # The actual recursion
   foldl( &f, f(acc, elt), rest);
}
```

Python does not allow pattern matching of this kind so we need to write the recursion using a conditional:

```python
def foldl (f, acc, lst):
  if lst == (): 
    return acc 
  else:
  # Python's way of splitting a tuple in the first elt and the rest
  # rest will be a list, not a tuple, but we'll let that pass
   (elt,*rest) = lst 
   # The actual recursion
   return foldl( f, f(acc, elt), rest)
```

In this implementation, none of the variables is ever updated. So all variables can be immutable. 

#### Right fold

The right fold is quite similar to the left fold. For the loop-based version, all we do is `reverse` the list.

```perl6
# Raku
sub foldrl (&f, \acc, \lst) { 
  my $res = acc;
  for  lst.reverse -> \elt {
    $res = f($res,elt);
  }
  $res;
}
```

```python
# Python
def foldlr (f, iacc, lst):
  acc = iacc
  for elt in lst.reverse():
    acc = f(acc,elt)  
  return acc
```

In the recursive version, we take the last element from the list instead of the first one. For details on the `..^ * - 1` syntax please see [the Raku documentation](https://docs.raku.org/language/operators#infix_..^).

```perl6
# Raku
multi sub foldr ( &f, \acc, ()) { acc }
multi sub foldr (&f, \acc, \lst) {
    my (\rest,\elt) = lst[0..^*-1, *  ];
    foldr( &f, f(acc, elt), rest);
}
```

```python
# Python
def foldr (f, acc, lst):
  if lst == (): 
    return acc 
  else:
   (*rest,elt) = lst 
   return foldr( f, f(acc, elt), rest)
```


#### `map` and `grep` are folds

Now, what about `map` and `grep`? We can of course implement these with `for`-loops, but we can also implement them using our `foldl`:

```perl6
# Raku
sub map (&f,\lst) {
    foldl( sub (\acc,\elt) {
            (|acc,f(elt))
            }, (), lst);
}
```

```python
# Python
def map (f,lst):
    return foldl( 
      lambda acc,elt:(*acc, f(elt))
      ,()
      ,lst
    )
```
Because the function `f` is mappable, it only has a single argument. But `foldl` needs a function with two arguments, the first for the accumulator. So we call `foldl` with an anonymous function of two arguments. The accumulator itself is an empty list. Although we said earlier that a reduction combines all elements of the original list into a single return value, this return value can of course be any data type, so also a list. So we call `f` on every element of the original list and add it to the end of the accumulator list. (The `|` flattens the list, so `(|acc,f(elt))` is a new list built from the elements of `acc` and result of `f(elt)`.)

In a similar way we can also define `grep`:

```perl6
# Raku
sub grep (&f,\lst) {
    foldl( sub (\acc,\elt) {
      if (f(elt)) {
          (|acc,elt)
      } else {
          acc
      }
    }, (), lst);
}
```


```python
# Python
def filter (f,lst):
    return foldl( 
      lambda acc,elt:
        (*acc,elt) if f(elt) else acc
      , (), lst)
```

Just like in the `map` implementation, we call `foldl` with an anonymous function. In this function we test if `f(elt)` is true for every `elt` in `lst`. If it is true we create a new list from `acc` and `elt`, otherwise we just return `acc`. Because `map` and `grep` operate on each element of the list separately, we could implement them using the right fold as well. 

With these examples I hope that both the concept of a function working on functions and the possible ways of implementing them has become more clear. The advantage of the recursive implementation is that it allows us to use immutable data structures. 

### Why immutable data structures?

You may wonder why I focus on these immutable data structures. As we will have seen, functional programming works really well with immutable data structures. And they have one big advantage: you never have to worry if you have accidentally modified your data, or whether you should make a copy to be sure. So using immutable data structures make code less error-prone and easier to debug. They also have potential performance benefits. And as we'll see next, in Raku there is yet another advantage.

## Functions returning functions

Functions can also return functions. This is in particular useful if we want to have a parametrisable function. As a trivial example, suppose we want a series of functions that increments a number with a fixed value: `add1`, `add2` etc. We could of course write each of them separately:

```perl6
# Raku
sub add_1 (\x) {x+1}
sub add_2 (\x) {x+2}
sub add_3 (\x) {x+3}
sub add_4 (\x) {x+4}
sub add_5 (\x) {x+5}

say add_1(4); #=> says 5
```


```python
# Python
def add_1 (x) : return x+1
def add_2 (x) : return x+2
def add_3 (x) : return x+3
def add_4 (x) : return x+4
def add_5 (x) : return x+5

print( add_1(4)) #=> says 5
```
Or we could use a list filled with anonymous functions:

```perl6
# Raku
my \add =
sub (\x) {x},
sub (\x) {x+1},
sub (\x) {x+2},
sub (\x) {x+3},
sub (\x) {x+4},
sub (\x) {x+5};

say add[0].(4); #=> says 5
```

```python
# Python
add = (
lambda x : x+1,
lambda x : x+2,
lambda x : x+3,
lambda x : x+4,
lambda x : x+5
)

print( add[0](4)) #=> says 5
```

We could do better and use a loop to fill an array with anonymous functions:

```perl6
# Raku
my \add = [];
for 0 .. 5 -> \n {
  add.push(sub (\x) {x+n});
}

say add[1].(4); #=> says 5
```

```python
# Python
add = []
for n in range(0,6):
  add.append(lambda x: x+n)
```

We create a new anonymous function with every loop iteration, and add it to the array. But instead, we could use a function to create these anonymous functions, and then we could use `map` instead of a loop, and use an immutable data structure:

```perl6
# Raku
sub gen_add(\n) {  
  sub (\x) {x+n}
}

my \add = map &gen_add, 0..5;

say add[1].(4); #=> says 5
```

```python
# Python
def gen_add(n):  
  return lambda x : x+n

add = tuple(map( gen_add, range(0,6)))

print( add[1](4)) #=> says 5
```

### Laziness

In Raku, using a range has an additional benefit: we can set the end of the range to infinity, which in Raku can be written as `∞` (unicode 221E), `*` or `Inf`. 

```perl6
# Raku
my \add = map &gen_add, 0 .. ∞;  

say add[244].(7124); #=> says 7368
```

This is an example of what is called "lazy evaluation", or laziness for short: Raku is not going to try (and fail) to process this infinite list. Instead, it will do the processing when we actually use an element of that list. The evaluation of the expression is delayed until the result is needed, so when we call `add[244]`, what happens is that `gen_add(244)` is called to generate that function. 
Note that this will not work with the for-loop, because to use the for-loop we need a mutable data structure, and the lazy lists have to be immutable. So this is a nice example of how the functional programming style allows you to benefit from laziness. For the full story of laziness in Raku, please see [the documentation](https://docs.raku.org/language/list#index-entry-laziness_in_Iterable_objects). 

Python does not have lazy lists but is have a different form of laziness: the call to `map` (or `filter`) does not return the sequence of results but instead it returns a _generator_:

```python
# Pythom
map_gen = map( gen_add, range(0,6666))

print(map_gen) #=> says <map object at 0x7f344caefdc0>
```

It is only when we wrap the generator in a sequence constructor such as `tuple()` that the results are actually generated. 



## Function composition

We saw above that you can chain calls to `map` and `grep` together. Often you only need to chain `map` calls together, for example

```perl6
# Raku
map -> \x { x + 5 }, map -> \x {x*x}, 1..30;
```

```python
# Python
map( lambda x : x + 5, map( lambda x : x*x, range(1,31)))
```

In that case, we can do this a little bit more efficient: rather than creating a list and then calling map on that list, we can do both computations at once by composing the functions. Raku provides a special operator for this:

```perl6
map -> \x { x + 5 } ∘ -> \x { x * x }, 1..30;
```

The operator `∘` (the "ring operator", unicode 2218, but you can also use a plain `o`) is the function composition operator, and it's pronounced "after", so `f ∘ g` is "f after g". What it does is create a new function by combining two existing functions:

```perl6
my &h = &f ∘ &g;
```
is the same as

```perl6
sub h (\x) {
    f(g(x))
}
```

The advantage of the composition operator is that that it works for any function, including anonymous ones. But in fact, it is just another higher-order functions. It is simply the operator form of the following function:

```perl6
# Raku
sub compose(&f,&g) {
    sub (\x) { f(g(x)) }
}
```

Python does not have a function composition operator, but you can easily have `compose` in Python too:

```python
# Python
def compose(f,g):
    return lambda x: f(g(x))
```

## Conclusion

In this article I have used Raku and Python examples to introduce three key functional programming techniques: functions that operate on functions, functions that return functions and function composition. I have shown how you to use the functions _map_, _reduce_ (_fold_) and _grep_ (_filter_) to operate on immutable lists. I have explained how yo(u can implement such functions with and without recursion, and what the advantage is of the recursive implementation. Here is the code from the article, [Raku](https://github.com/wimvanderbauwhede/raku-examples/blob/master/decluttering-with-functional-programming.raku) and [Python](https://github.com/wimvanderbauwhede/raku-examples/blob/master/decluttering-with-functional-programming.py). 

There is of course a lot more to functional programming and I have written [a few articles on more advanced topics]({{ site.url}}/articles/). The concepts introduced in this article should provide a good basis for understanding those more advanced topics. If you want to learn more about functional programming, you might consider [my free online course](https://www.futurelearn.com/courses/functional-programming-haskell).

<!-- (reduce ->\x,\y {x o y}, -> \x {x+1},-> \x {x*2}, -> \x {2*x-1})(33) -->
<!-- ([∘] fs)(x) -->

<!-- List comprehensions
[ expression for item in list if conditional ] -->



<!-- From my perspective:
∘ Partial application 
∘ Pureness of I/O -->