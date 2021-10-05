---
layout: article
title: "Roles as Algebraic Data Types in Raku"
date: 2020-06-05
modified: 2020-06-05
tags: [ coding, hacking, programming, raku ]
excerpt: "Algebraic data types are great for building complex data structures, and easy to implement in Raku using roles."
current: "Roles as Algebraic Data Types in Raku"
current_image: roles-as-adts-in-raku_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: roles-as-adts-in-raku_1600x600.jpg
  teaser: roles-as-adts-in-raku_400x150.jpg
  thumb: roles-as-adts-in-raku_400x150.jpg
---

I have been a [lambdacamel](https://andrewshitov.com/2015/05/05/interview-with-audrey-tang/), one of those who like [Perl](https://www.perl.org/) and functional programming, especially in [Haskell](https://www.haskell.org/), for a long time. I still write most of my code in either of these languages.

I've also been a fan of [Raku](https://raku.org/) from long before it was called Raku, but I'd never used it much in real life. Recently though, I've been moving increasingly to Raku for code that I don't have to share with other people. It's a lovely language, and its functional heritage is very strong. It was therefore only natural to me to explore the limits of Raku's type system. 

## Is this article for you?

In this article I will introduce [algebraic data types](https://www.cs.kent.ac.uk/people/staff/dat/miranda/nancypaper.pdf), a kind of static type system used in functional languages like Haskell, and a powerful mechanism for creating complex data structures. I will show a way to implement them in Raku using _roles_. You don't need to know Haskell at all and I only assume a slight familiarity with Raku (I've added [a quick introduction](#raku-intro)), but I do assume you are familiar with basic programming. You may find this article interesting if you are curious about functional-style static typing or if your would like an alternative to object-oriented programming. 

## Algebraic Data Types
 
Datatypes (types for short) are just labels or containers for values in a program. Algebraic data types are composite types, they are formed by combining other types.
They are called algebraic because they consist of alternatives (sums, also called disjoint unions) and record (products) of types. For more details see [[1]](https://codewords.recurse.com/issues/three/algebra-and-calculus-of-algebraic-data-types) or [[2]](https://gist.github.com/gregberns/5e9da0c95a9a8d2b6338afe69310b945). 

To give a rough intuition for the terms "sum type" and "product type": in Raku,  with Booleans `$a`, `$b` and `$c`, you can write `$a or $b or $c` but you could also write `  $a + $b + $c` and evaluate it as `True` or `False`. Similarly, `$a and $b and $c` can be written as `$a * $b * $c`. In other words, `and` and `or` behave in the same way as `+` and `*`. In a generalised way, the types in algebraic data type system can be composed using similar rules.

### A few examples.

Let's first give a few examples of algebraic data types. In this section I am not using a specific programming language syntax. Instead I use a minimal notation to illustrate the concepts. I use the `datatype` keyword to indicate that what follows is a declaration for an algebraic data type; for a sum type, I'll separate the alternatives with '\|'; for a product type, I separate the components with a space. To declare a variable to be of some type, I will write the type name in front of it.

We can define a Boolean value purely as a type:

```haskell
	datatype Bool =  True | False
```

And we can use this as

```haskell
	Bool ok = True
```

This means that `ok` is a variable of type `Bool` with a value of `True`. In an algebraic data type, the labels are called 'constructors'. So `True` is a constructor that takes no arguments.

For a product type, we could for example create a type for an RGB colour triplet:

```haskell
	datatype RGBColour = RGB Int Int Int
```

The `RGB` label on the right-hand side is the constructor of the type. It takes three arguments of type `Int`:

```haskell
	RGBColour aquamarine = RGB 127 255 212
```

So `aquamarine` is a variable of type `RGBColour` with a value of `RGB 127 255 212`. 

The constructor identifies the type. Suppose we also have an HSL colour type

```haskell
	datatype HSLColour = HSL Int Int Int
```

with a variable `chocolate` of that type:

```haskell
	HSLColour chocolate = HSL 25 75 47
```

then both `RGB` and `HSL` are triplets of `Int` but because of the different type constructors they are not the same type. 

Let's say we create an RGB Pixel type:

```haskell
	datatype XYCoord = XY Int Int
	datatype RGBPixel  = Pixel RGBColour XYCoord
```

then 

```haskell
	RGBPixel p = Pixel aquamarine (XY 42 24)
```

is fine but

```haskell
	RGBPixel p = Pixel chocolate (XY 42 24)
```

will be a type error because `chocolate` is of type `HSLColour`, not `RGBColour`. 

We could support both RGB and HSL using a sum type:

```haskell
	datatype Colour = HSL HSLColour | RGB RGBColour
```

and change make a Pixel type definition:

```haskell
	datatype Pixel = Pixel Colour XYCoord
```

And now we can say 

```haskell
	Pixel p_rgb = Pixel (RGB aquamarine) (XY 42 24)
	Pixel p_hsl = Pixel (HSL chocolate) (XY 42 24)
```

### Integers and strings, recursion and polymorphism

I can hear you say: but what about `Int`, it doesn't have constructors? And what about a string, how can that be an algebraic data type? These are interesting questions as they allow me to introduce two more concepts: *recursive* and *polymorphic* types.

#### The type of an integer and recursive types

From a type perspective, you can look at an integer in two ways: if it is a fixed-size integer then the `Int` type can be seen as a sum type. For example, the type for an 8-bit unsigned integer could be

```haskell
    datatype UInt8 = 0 | 1 | 2 | ... | 255
```

In other words, every number is actually the name of a type constructor, as a generalisation of the `Bool` type.

However, in the mathematical sense, integers are not finite. If we consider the case of the natural numbers, we can construct a type for them as follows:

```haskell
    datatype Nat = Z | S Nat
```

The `Z` stands for "zero", the `S` for "successor of". This is a *recursive* type, because the `S` constructor takes a `Nat` as argument. With this type, we can now create any natural number:

```haskell
    Nat 0 = Z
    Nat 1 = S Z
    Nat 2 = S (S Z)
    Nat 3 = S (S (S Z))
    ...
```

This way of constructing the natural numbers is called [Peano numbers](https://www.britannica.com/science/Peano-axioms).

#### The type of a string and polymorphic types

Now, what about strings? Enumerating all possible strings of any length is not practical. But from a type perspective, a string is a list of characters. So the question is then: what is the type of a list? For one thing, a list must be able to contain values of any type. (In the context of algebraic datatypes, all values must be the same, so our list is more like a typed array in Raku.) But that means we need types that can be parameterised by other types. This is called *parametric polymorphism*. So a list type must look something like

```haskell
    datatype List a = ...
```

where `a` is a type variable, i.e. it can be replaced by an arbitrary type. For example, assuming we define the `Char` type simply by enumerating all characters in the alphabet (because of course, at machine level, every character is represented by an integer number):

```haskell
    datatype Char = 'a' | 'b' | 'c' | ... | 'z'
```

Then we can type our string as: 

```haskell
    List Char str = ...
```

But what about `List`? We use a similar approach as for `Nat` above, using a recursive sum type:

```haskell
    datatype List a = EmptyList | Cons a (List a)
```

Now we can create a list of any length:

```haskell
    List Char str = 
         Cons 'h' 
        (Cons 'e' 
        (Cons 'l' 
        (Cons 'l' 
        (Cons 'o' 
        EmptyList))))
```

Using the typical syntactic sugar for lists, we can write this as     

```haskell
    List Char str = [ 'h', 'e', 'l', 'l', 'o' ]
```

If I now invent an alias `Str` for `List Char`, and use double quotes instead of list notation, I can write    

```haskell
    Str str = "hello"
```

So integers and strings can be expressed as algebraic data types, and now we have introduced recursive and parameterised types.

### What are algebraic data types good for?  

These may seem like rather contrived examples, after all a language like Raku already has an `Int` and a `Str` type that work very well. So what is the use of these  algebraic data types? Of course the purpose of static types is to provide type safety and make debugging easier. But using algebraic data types also makes a different, more functional style of programming possible.

One common use case is a list where you want to store values of different types: you can create a sum type that has an alternative for each of these types. Another common case is a recursive type, such as a tree. Finally, the polymorphism provides a convenient way to create custom containers. I will give examples of each of these in the next section. Time to move on to Raku!

## Algebraic data types in Raku

As Raku is not a very well-known language (yet), here is a quick introduction of the features you'll need to follow the discussion below. 

<a name="raku-intro"></a>
### A quick introduction to Raku

Before Raku went its own way, it was meant to be the next iteration of Perl (hence the original name Perl 6). It is therefore more similar to Perl than to any other language.

Raku is syntactically similar to C/C++, Java and JavaScript: block-based, with statements separated by semicolons, blocks demarcated by braces, and argument lists in parentheses and separated by commas. The main feature it shares with Perl is the use of sigils ('funny characters') which identify the type of a variable: `$` for a scalar, `@` for an array, `%` for a hash (map) and `&` for a subroutine. Variables also have keywords to identify their scope, I will only use `my` which marks the variable as lexically scoped. A subroutine is declared with the `sub` keyword, and subroutines can be named or anonymous:

```perl6
sub square ($x) {
    $x*$x;
}
# anonymous subroutine 
my $anon_square = sub ($x) {
    $x*$x;
}
```

Raku also has [twigils](https://docs.raku.org/language/variables#index-entry-Twigil), secondary sigils that influence the scoping of a variable. For this article, the only twigil used in the code is `.` which is used to declare a role or class attribute with automatically generated accessors (like `$.notes` in the example below).

Raku supports sigil-less variables, and uses the `\` syntax to declare them. For more on the difference between ordinary and sigil-less variables, see [the Raku documentation](https://docs.raku.org/language/variables#Sigilless_variables). For example (`say` prints its argument followed by a newline):

```perl6
my \x = 42;
my $y = 43;
say x + $y; 
```
 

Raku has [gradual typing](https://raku.guide/): it allows both static and dynamic typing. That's a good start because we need static typing to support algebraic data types. It also has [immutable variables](https://docs.raku.org/language/variables) and [anonymous functions](https://raku.guide/#_anonymous_functions), and even [(limited) laziness](https://docs.raku.org/language/list#index-entry-laziness_in_Iterable_objects). And of course [functions are first-class citizens](https://raku.guide/#_functional_programming), so we have everything we need for pure, statically-typed functional programming. But what about the algebraic data types?

In Raku, `enum`s are sum types:

```perl6
    enum Bool <False True>
```

However, they are limited to type constructors that don't take any arguments. 

Classes can be seen as product types:

```perl6
    class BoolAndInt {
        has Bool $.bool;
        has Int $.int;
    }
```

However, classes do not support parametric polymorphism. 

This is where *roles* come in. According to the [Raku documentation](https://docs.raku.org/language/objects#Roles):

<blockquote>
Roles are a collection of attributes and methods; however, unlike classes, roles are meant for describing only parts of an object's behavior; this is why, in general, roles are intended to be mixed in classes and objects. In general, classes are meant for managing objects and roles are meant for managing behavior and code reuse within objects.
</blockquote>

Roles use the keyword `role` preceding the name of the role that is declared. Roles are mixed in using the `does` keyword preceding the name of the role that is mixed in.  Roles are what in Python and Ruby is called _mixins_.

So roles are basically classes that you can use to add behaviours to other classes without using inheritance. Here is a stripped-down example take from the [Raku documentation](https://docs.raku.org/language/objects#Roles) (`has` declares an attribute, `method` a method)

```perl6
role Notable {
    has $.notes is rw;

    method notes() { ... }; 
}
 
class Journey does Notable {
    has $.origin;
    has $.destination;
    has @.travelers;
 
    method { ... <implemented using notes()> ... };
}

```

In particular, roles can be mixed into other roles, and that is one of the key features I will exploit. Furthermore, role constructors can take arguments _and_ they are parametric. So we have everything we need to create proper algebraic data types. Let's look at a few examples.

### A few simple examples

#### An opinionated Boolean

This is the example of a sum type for a Boolean as above, but implemented with roles. The first line declares the type as an empty role, this corresponds to the data type name on the left-hand side. The next lines define the alternatives, each alternative uses `does OpinionatedBool` to tie it to the `OpinionatedBool` role which functions purely as the type name.  

```perl6
role OpinionatedBool {}
role AbsolutelyTrue does OpinionatedBool {}
role TotallyFalse does OpinionatedBool {}
```

In Raku, types are values; and for a role with an empty body, you don't need the `.new` constructor call. In a sum type, the alternatives usually are labelled containers for values, but they can be empty containers as well. When that is the case, there is no need to create separate instances of them because there is only one way to have an empty container.

```perl6
my OpinionatedBool \bt = AbsolutelyTrue;
```

Sum types can be used in combination with Raku's `multi sub` feature: Raku lets you provide several definitions for a function, with the same name but different signatures. With multi subs we can do what is known as pattern matching on types:

```perl6
multi sub p(AbsolutelyTrue $b) {
    say 'True';
}
multi sub p(TotallyFalse $b) {
    say 'False';
}

# Trying it out:
p(bt); # prints True
```

Because we use a type as a value, to test if a value is `AbsolutelyTrue` or `TotallyFalse`, we can use either the smart match `~~`, the container (type) identity `=:=` or the value (instance) identity `===` to test this (the smart match operator behaves like `=:=` if the right-hand side is a type and as `===` if it is an object instance). If we would create an instance like `AbsolutelyTrue.new`, this would not be the case. See the [code example](https://github.com/wimvanderbauwhede/raku-examples/blob/master/roles_types_and_instances.raku) for more details.


#### The Colour, XYCoord and Pixel types

Here is the implementation of the `Colour`, `XYCoord` and `Pixel` types from above. The `RGBColour` type is an example of a product type. There are two differences with my notation from above:

```haskell
datatype RGBColour = RGB Int Int Int
```

1. Because the role serves both as the type (`RGBColour`) and the instance constructor (`RGB`), they must have the same name. I only named them differently to make it easier to distinguish them so this is not an issue.
2. The types that make up each field must be named with unique names in the role's argument list, and need to have a corresponding attributes declared. That is again not really a limitation, because accessors for record type fields are handy. So it looks like:

```perl6
role RGBColour[Int \r, Int \g, Int \b] {
    has Int $.r = r;
    has Int $.g = g;
    has Int $.b = b; 
}
```
(the role's parameters are in square brackets)

And we create `aquamarine` like this:

```perl6
my RGBColour \aquamarine = RGBColour[ 127, 255, 212].new;
```

The definitions of `HSLColour` and `XYCoord` are analogous, you can find them in the [code example](https://github.com/wimvanderbauwhede/raku-examples/blob/master/role_as_adt_colour_example.raku). Let's look at the sum type to combine the RGB and HSL colour types:

```perl6
role Colour {}
role HSL[ HSLColour \hsl] does Colour {
    has HSLColour $.hsl = hsl;
};
role RGB[ RGBColour \rgb] does Colour {
    has RGBColour $.rgb = rgb;
};
```

This is essentially the same approach as for the opinionated Boolean, but we don't have empty roles: the `HSL` alternative takes an argument of type `HSLColour`, and the `RGB` alternative takes an argument of type `RGBColour`.
As in the product type, we use the role as a container to hold the values. The `Pixel` type from above looks like: 

```perl6
role Pixel[ Colour \c, XYCoord \xy ] {
    has Colour $.c = c;
    has XYCoord $.xy = xy;
}
```

And now we can create pixels with RGB and HSL colours:

```perl6
my Pixel \p_rgb = Pixel[ RGB[ aquamarine].new , XYCoord[ 42, 24].new ].new;
my Pixel \p_hsl = Pixel[ HSL[ chocolate ].new , XYCoord[ 42, 24].new ].new;
```

#### Recursion and polymorphism

Above, I showed the Peano number type to illustrate type-level recursion. This works just fine with roles in Raku too:

```perl6
role Nat{}    
role Z does Nat {}
role S[Nat $n] does Nat {}  
```

And we can combine this with type parameters as in the list example:

```perl6
role List[::a] {}
role EmptyList[::a] does List[a] {}
role Cons[ ::a \elt, List \lst ] does List[a] {
    has $.elt = elt;
    has $.lst = lst;
}
```
 (The prefix `::` is the Raku syntax to declare type variables)

##### Issues with current raku

There are some issues here: 

- The `EmptyList` alternative must either be declared as above, with a type parameter, or as

```perl6
role EmptyList does List {}
```

where the type also doesn't take a type variable. We can't write

```perl6
role EmptyList does List[::a] {}
```

This is of course only a minor issue, resulting only in some redundancy.

- A more serious issue is that the type of `lst` must be `List` (or `List[]`) instead of `List[a]`. That is actually a problem, as it weakens the type checking. So it must be a bug in the current version of `raku` (2020.01). When I provide `List[a]` I get the following error:

```
    Could not instantiate role 'Cons':
    Internal error: inconsistent bind result
    in any protect at gen/moar/stage2/NQPCORE.setting line 1216
    in block <unit> at list-adt.raku line 12
```

### A few more useful examples

#### A multi-type array

For the first example, I want to store values of different types in a typed array. They elements can be strings, labeled lists of strings, or undefined. I call this type `Matches`. Using the notation from above, it would be

```haskell
datatype Matches = 
      Match Str 
    | TaggedMatches Str (List Matches) 
    | UndefinedMatch
```

In Raku, it is defined as follows:

```perl6
    role Matches {}
    role UndefinedMatch does Matches {}
    role Match[Str $str] does Matches {
        has Str $.match=$str;
    } 
    role TaggedMatches[Str $tag, Matches @ms] does Matches {
        has Str $.tag = $tag;
        has Matches @.matches = @ms;
    } 
```

This type uses type constructors with 0 (`UndefinedMatch`), 1 (`Match`) and 2 (`TaggedMatches`) arguments, and the latter is a recursive type: the second argument is a list of `Matches`. With this definition, we can create an array of matches like this:

```perl6
    my Matches @ms = Array[Matches].new(
        Match["hello"].new,
        TaggedMatches[
            "Adjectives",
            Array[Matches].new(
                Match["brave"].new,
                Match["new"].new) 
                ].new,
        Match["world"].new
        );
```

As you can see, the typed values are actually constructed by calling `.new`. It is a bit nicer to create constructor functions, and once Raku has a more developped macro system, we might be able to generate these automatically.

```perl6
    my Matches @ms = mkMatches(
        mkMatch "hello",
        mkTaggedMatches(
            "Adjectives",
            mkMatches(
                mkMatch "brave",
                mkMatch "new" 
                )
        ),
        mkMatch "world)
        );
```

[Code for this example](https://github.com/wimvanderbauwhede/raku-examples/blob/master/roles_as_types.raku)

#### A generic tuple

For the next example, I want to define a type called `Either`. This is a parametric sum type with two parameters, so a kind of generic tuple:

```haskell
datatype Either a b = Left a | Right b
```

In Raku, this can be done through the use of type variables as parameters for the role:

```perl6
    role Either[::a,::b] { }
    role Left[::a \l,::b] does Either[a,b] { 
        has a $.left = l;
    }
    role Right[::a,::b \r] does Either[a,b] { 
        has b $.right = r;
    }
```

Because Raku expects both type variables to be declared in each constructor, it is a little bit less nice than my more abstract notation. We can pattern match on this type with a `multi sub`: 

```perl6
multi sub test (Left[Int,Str] $v) { say 'Left: '~$v.left }
multi sub test (Right[Int,Str] $v) {say 'Right: '~$v.right }
```

So we can write

```perl6
my Either[Int,Str] \iv = Left[42,Str].new;
my Either[Int,Str] \sv = Right[Int,'forty-two'].new;

test(iv); # prints 'Left: 42'
test(sv); # prints 'Right: forty-two'
```

[Code for this example](https://github.com/wimvanderbauwhede/raku-examples/blob/master/either.raku)

#### A parameterised binary tree

As a final example, here is a simple binary tree. First, let's look at an example implementation using a role from the [Raku documentation](https://docs.raku.org/language/objects#index-entry-Parameterized_Roles):

```perl6
role BinaryTree[::Type] {
    has BinaryTree[Type] $.left;
    has BinaryTree[Type] $.right;
    has Type $.node;

    method visit-preorder(&cb) {
        cb $.node;
        for $.left, $.right -> $branch {
            $branch.visit-preorder(&cb) if defined $branch;
        }
    }
    method visit-postorder(&cb) {
        for $.left, $.right -> $branch {
            $branch.visit-postorder(&cb) if defined $branch;
        }
        cb $.node;
    }
    method new-from-list(::?CLASS:U: *@el) {
        my $middle-index = @el.elems div 2;
        my @left         = @el[0 .. $middle-index - 1];
        my $middle       = @el[$middle-index];
        my @right        = @el[$middle-index + 1 .. *];
        self.new(
            node    => $middle,
            left    => @left  ?? self.new-from-list(@left)  !! self,
            right   => @right ?? self.new-from-list(@right) !! self,
        );
}
 
my $t = BinaryTree[Int].new-from-list(4, 5, 6);
$t.visit-preorder(&say);    # OUTPUT: «5␤4␤6␤» 
$t.visit-postorder(&say);   # OUTPUT: «4␤6␤5␤» 
```

This example contains quite a bit of Raku syntax:

- Raku allows dashes in names;
- the `->` syntax is a foreach loop, iterating over all elements of the preceding list;
- The `..` is array slicing;
- `::?CLASS` is a compile-time type variable populated with the class you're in and `:U` is a type constraint which specifies that it should be interpreted as a type object. Finally, the `:` marks the argument to its left as the invocant. In other words, it allows us to write `BinaryTree[Int].new-from-list(4, 5, 6)` where `BinaryTree[Int] is the value of `::?CLASS`. This is the Raku way to create custom constructors.   
- The `*` in front of the `@el` argument of `new-from-list` makes this a variadic function where `@el` contains all arguments;
- The `=>` syntax allows to assign arguments by name rather than by position;
- `?? ... !! ...` is Raku's syntax for C's ternary ` ? ... : ... `;

This example is written in Raku's object-oriented style, with methods acting on the attributes of the role. Let's see how we can write this in a functional style.

The algebraic data type for this binary tree is:

```haskell
datatype BinaryTree a = 
      Node (BinaryTree a) (BinaryTree a) a 
    | Tip
```

The `Tip` alternative is for the empty leaf nodes of the tree, which in the above example are left undefined. In Raku, we can implement this type as: 

```perl6
role BinaryTree[::Type] { }
role Node[::Type,  \l,  \r, \n] does BinaryTree[Type] { 
    has BinaryTree[Type] $.left = l;
    has BinaryTree[Type] $.right = r;
    has Type $.node = n;
}
role Tip[::Type] does BinaryTree[Type] { }
```

Instead of the methods we use functions, implemented as `multi sub`s. Most of the code is of course identical, but there is no need for conditionals to check if a leaf node has been reached. I have also used sigil-less immutable variables.

```perl6
multi sub visit-preorder(Node \n,&cb) {
    cb n.node;
    for n.left, n.right -> \branch {
        visit-preorder(branch,&cb)
    }
}
multi sub visit-preorder(Tip,&cb) { }

multi sub visit-postorder(Node \n,&cb) {    
    for n.left, n.right -> \branch {
        visit-postorder(branch,&cb)
    }
    cb n.node;
}
multi sub visit-postorder(Tip,&cb) { }

multi sub new-from-list(::T,[]) {
    Tip[Int].new    
}
multi sub new-from-list(::T,\el) {
    my \middle-index = el.elems div 2;
    my \left         = el[0 .. middle-index - 1];
    my \middle       = el[middle-index];
    my \right        = el[middle-index + 1 .. *];    
    Node[T,
        new-from-list(T,left),
        new-from-list(T,right),
        middle            
    ].new;
}

my BinaryTree[Int] \t = new-from-list(Int,[4, 5, 6]);
visit-preorder(t,&say);    # OUTPUT: «5␤4␤6␤» 
visit-postorder(t,&say);   # OUTPUT: «4␤6␤5␤» 
```

One thing to note is that in the `multi sub`s we don't have to match against the full type, for example in `visit-preorder` we match against `Tip` and `Node` rather than the full `Tip[a]` and `Node[::a,BinaryTree[a],BinaryTree[a],a]`. 

[Code for this example](https://github.com/wimvanderbauwhede/raku-examples/blob/master/binary_tree_2.p6)

## Wrap-up

Creating algebraic data types with Raku's roles is very straightforward. Any product type is simply a role with a number of typed attributes. The key idea for the sum type is to create an empty role and mix it in with other roles that become the type constructors for your alternatives. Because roles accept type parameters, we can have parametric polymorphism. And because a role can have attributes of its own type, we have recursive types as well. Combined with Raku's other functional programming features, this makes writing pure, statically typed functional code in Raku great fun.  

### References

[1] ["The algebra (and calculus!) of algebraic data types", by Joel Burget](https://codewords.recurse.com/issues/three/algebra-and-calculus-of-algebraic-data-types)
<br/>
[2] ["The Algebra of Algebraic Data Types, Part 1", by Chris Taylor](https://gist.github.com/gregberns/5e9da0c95a9a8d2b6338afe69310b945)

