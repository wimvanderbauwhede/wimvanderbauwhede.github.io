---
layout: article
title: "More on Funktal: I/O devices and state"
date: 2023-08-03
modified: 2023-08-03
tags: [ computing, functional, uxntal ]
excerpt: "How Funktal programs can interact with I/O devices, and how mutable state helps with this."
current: ""
current_image: funktal-devices-state_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: funktal-devices-state_1600x600.jpg
  teaser: funktal-devices-state_400x150.jpg
  thumb: funktal-devices-state_400x150.jpg
---

In [a previous post]({{site.url}}/articles/funktal/), I introduced [`Funktal`](https://codeberg.org/wimvanderbauwhede/funktal), a frugal functional programming language created for the [Uxn](https://wiki.xxiivv.com/site/uxn.html) VM. The Uxn VM is the heart of a clean-slate computing platform called [Varvara](https://wiki.xxiivv.com/site/varvara.html). This post explains how you can access Varvara's I/O devices from Funktal, and the closely related support for mutable state. I illustrate these features using three small GUI-based programs.

The main purpose of Uxn and Varvara is as a portable platform for GUI-based applications, such as the [`left`](https://wiki.xxiivv.com/site/noodle.html) editor, the [`noodle`](https://wiki.xxiivv.com/site/noodle.html) drawing program and many others, in particular games. To make Funktal a practical language for this platform, support for I/O devices (keyboard, mouse, screen, audio) is essential.

## Mutable state: why and how

Uxn I/O is event based, for example a button press or mouse click results in an event handler (aka vector or callback) being called. These handlers can access the Uxn VM's  working and return stack as well as its memory. Most programs are stateful, so a efficient mechanism for handling state is important.


### Keeping state on the stack

We could keep the state on the stack. This is OK for simple cases but quickly gets cumbersome. Suppose we have three items of state then our function needs to look like this:

    (\s1_in s2_in s3_in.
        <all computations>
        s3_out s2_out s1_out
    )

But we don't know the type of items on the stack, so we need explicit typing, e.g.

    types {
        RGB = Int Int Int MkRGB
    }

    (\(RGB,Int,Bool) <- s1_in:Bool<- s2_in: Int<- s3_in:RGB.
        <all computations>
        s3_out s2_out s1_out
    )

The tuple syntax only indicates that the function pushes multiple values on the stack, it is not an algebraic data type and so we can't construct it or pattern match on it.

### Putting the state in a record type

An improvement would be if the stack held an instance of a record type, because then all we have to do is keep such an instance on the stack.

    types {
        RGB = Int Int Int MkRGB
        State = Bool Int RGB MkState
    }

    (\State <- s_in:State. <all computations> s_out )

It still means that this state should remain on the stack, and if there are several event handlers each with their own state, either that means juggling those states or creating an overall state for all event handlers in the program and passing that around. Either way that would mean additional code for accessing the state.

Because each instance of a type is immutable, this approach also means that every update of the state requires to construct a new type. (And in practice we'll have to delete the old one, otherwise we'd run out of memory very quickly. But Funktal does not have managed memory yet. Yet another story.) Constructing types is expensive (and deletion even more so).

### Making state mutable

For all these reasons, I decided to add mutable state to Funktal. It is very simple: in a special block called `state` we define a singleton instance of the type used for the state:

    types {
        RGB = Int Int Int MkRGB
        State = Bool Int RGB MkState
    }

    state {
        s : State
    }

So this defines `s` as a mutable instance of `State`. There can only be one such instance per type.
And now the function simple becomes

    ( <all computations on s> )

To access the information in a stateful record, there are two built-in functions, `get` and `put`, which access a field in the record using its (base-0) index:

    0_1 s get -- gets the Bool from the record
    42 1_1 s put -- puts 42 in the Int slot

These are polymorphic functions that work for any record type registered as a `state`.

To make this more readable, I define some constants to identify the fields. Suppose the purpose of the fields in the State type are `greyscale`, `transparency` and `colour`, we can define

    constants {
        greyscale#State = 0_1
        transparency#State = 1_1
        colour#State = 2_1
    }

and write

    greyscale#State s get -- gets the greyscale from the record
    42 transparency#State s put -- puts 42 in the transparency field

(The '#' has no special meaning, I use it as a separator so that I can use the same field names in different types.)

Because `State` is a proper Funktal type, you can also use pattern matching to bind the field values to names:

    s (\None <- (greyscale transparency colour MkState) : State . <all computations on s> )

But as bound variables are immutable, you can't update the state this way.

### Mutable arrays

Funktal has a built-in `Array` type for immutable array constants, with built-in functions `size` and `at`.
Within the context of a mutable state type, such arrays can be updated using a built-in `update` function. 
For example, assuming a state `s : AState` has a field labelled `array` which is of type `Array`, we can write

    val idx array#AState s get update

## Devices

I/O devices in Uxn are typically defined in this way:

    |20 @Screen &vector $2 
        &width $2 &height $2 &pad $2 
        &x $2 &y $2 &addr $2 
        &pixel $1 &sprite $1

In Funktal we simply define a corresponding record type:

    types {
        Screen = Int Int Int Int Int Int Int Int8 Int8 MkScreen
    }

And to make this more readable, there is an aliasing mechanism

    aliases {
        Vector = Int
        Width = Int; Height = Int; Pad = Int; X = Int; Y = Int; Addr = Int; Pixel = Int8; Sprite = Int8
    }

    types {
        Screen = Vector Width Height Pad X Y Addr Pixel Sprite MkScreen
    }

The key difference with our mutable state is that each device has a unique address. 

    devices {
        0x20 scr : Screen
    }

And to make a clear distinction with state operations, the built-in function to access I/O devices are `read` and `write`, for example

    (\None<-colour:Int8 . colour sprite#Screen scr write )

## Bits and bobs: blocks, loops, done

There are a few more features of Funktal that make implementing device interactions easier.

### The `Block` type

A very common action in Uxn programs is to read constant data for sprites. For example, the following is typical:

    ;font-hex ADD2 .Screen/addr DEO2

This can't be implemented with the existing Arrays API in Funktal, because the `addr` field of the screen device expect the actual address in Uxn memory. Therefore I added a `Block` datatype, which is simply a contiguous sequence of bytes:

    font_hex : Byte 128 Block = [
         0x00,0x7c ,0x82,0x82 ,0x82,0x82 
        ... ]

This is only used for constants, and the instance of the type (i.e. the constant) contains the address of the first element (like an array in C). So you can write:

    font_hex + addr#Screen scr write

### The `loop` built-in

Although I conceived Funktal as a functional language, where a natural programming paradigm is using higher-order list functions such as `map` and `fold`, for I/O actions it is very common to loop over some action that does not return anything. It is of course easy to implement such a loop in native Funktal, but it can be done more efficiently in Uxntal, so Funktal has a built-in `loop` function which takes a start and end value and a lambda function, and returns nothing:

    loop: None <- Int <- Int <- (None<-Int)

For example

    0 9 `(\None<-idx:Int. idx 1 + print ) loop

will print all values in the range. (And although I know all the arguments to the contrary, the range is 0 to 9, not 0 to 8). 

### Stateful loop iteration

Sometimes you might to maintain some state during the loop iteration, similar to a `fold`. This can be done via the stack:

    0 -- This puts a 0 on the working stack
    0 len 1_1 - Int
    `(\ Int <- val : Int <- idx : Int .
        idx array at (\Int <- elt : Int .
            val idx array update
            elt
        )
    ) loop
    -- Clear the working stack
    (\None<-null:Int.)

This example loops over indices 0 to len-1, and gets the element from an array. It then updates the array with the value on the stack, and puts the element on the stack. So if the array was [11, 22, 33, 44], it will become [0, 11, 22, 33]. The one thing to look out for is that this will leave the final element on the stack, so you may want to remove it by calling an empty lambda on it, which is what `(\None<-null:Int.)` does.

### The `done` built-in

Funktal normally expects a called function to return. Event handlers have nowhere to return to. As a simple way to handle this is I added the `done` built-in, which will tell the compiler to emit a `BRK` rather than a `JMP2r` at the end of a function. If it is used elsewhere, it simply emits a `BRK` which is useful for debugging.

## Examples

I have implemented a few examples of GUI-based programs. Two are ports of Uxn demos, the third renders the Funktal logo.

### Example 1: DVD

[This example](https://codeberg.org/wimvanderbauwhede/funktal/src/branch/devel/examples/dvd.ftal) is a simple program that bounces the DVD icon around the screen. 

<figure>
<img src="{{ site.url }}/images/dvd.png" alt="A white DVD logo on a blue background" title="A white DVD logo on a blue background" />
<figcaption>DVD icon bouncing</figcaption>
</figure>

It is a straight port of the `dvd.tal` program. We define types for the system and screen devices and the dvd state:

    types {
        System = Word Int8 Int8 Int Int8 Int8 Word Word Word Int8 Int8 MkSystem
        Screen = Int Int Int Byte Int8 Int Int Int Int8 Int8 MkScreen
        DVD = Int Int Int Int MkDVD
    }

Then we create the instance:

    state {
        dvd : DVD
    }

    devices {
        0x00 sys : System
        0x20 scr : Screen
    }


There are no loops in this program, and no controls. It simply calculates the new position of the icon on every clock tick. The only event handler is `onFrame`. Because this is a straight port, it does use the stack for some values. The main program registers that event handler, does some setup and puts the borders on the stack:

    main {
        ...
    `onFrame vec#Screen scr write
    ...
        20 w#Screen scr read 20 -
        20 h#Screen scr read 20 -
    }

These borders are used by the event handler but not modified:

    functions {

        -- takes the borders from the stack
        onFrame = ( \ xmin xmax ymin ymax .
            0x00 drawDVD
            x#DVD dvd get
            y#DVD dvd get
            dx#DVD dvd get
            dy#DVD dvd get
            (\ Int <- x : Int <- y : Int <- dx : Int <- dy : Int .
                ... calculate new position ....
            )
            0x01 drawDVD
            -- put the borders back on the stack
            xmin xmax ymin ymax
            done
        )
    }

    -- takes the colour (0 or 1) as argument
    drawDVD = (\ None <- c : Int8. ... )

Note the use of `done` at the end of the `onFrame` function, because it is an event handler.

## Example 2: Snake

[This example](https://codeberg.org/wimvanderbauwhede/funktal/src/branch/devel/examples/snake.ftal) is a straight port of the `snake.tal` program, a game where you control a snake to eat apples, and the snake grows longer and longer. 

<figure>
<img src="{{ site.url }}/images/snake.png" alt="A green snake with a tail of 5 segments, about to eat a red apple, on a black background " title="A green snake with a tail of 5 segments, about to eat a red apple, on a black background" />
<figcaption>Snake in action</figcaption>
</figure>

The main differences with the DVD code is that there are buttons to control the direction of the snake, so we need a controller device, and that the tail of the snake is an array, so we use loops to update it.

The controller device:

    types {
        Controller = Vector Button Key MkController
    }

    devices {
        0x80 ctl : Controller
    }

The button handler is registered as before:

    `onButton vec ctl write

The handler itself:

    onButton = (
        button#Ctl ctl read
        (\None <-b:Int8.
             b 8_1 /=
            `( b noEscape )
            `( reset )
             if
        )
        done
    )

    noEscape = (\ None <- b : Int8 .
        b 4_1 >> (\None <-bb : Int8 .
            bb 0_1 /=
            `( bb dir#Snake snake put )
            `() if
        )
    )

So we read the button value, compute a value based on the button that is pressed, and write that into the `dir` field if the `snake` state. The `Snake` type is

    aliases {
        X=Int8; Y=Int8
        Dir=Int8; Len=Int8; Dead=Int8
        Tail = Int 32 Array
    }

    types {
        Snake = Dir Len Dead X Y Tail MkSnake
    }

    state {
        snake : Snake
    }

This is an example of a state containing an array. The main action is `drawSnake`

    drawSnake = (\None<-c:Int8.
        -- draw tail
        snake_icns addr#Screen scr write 
        len#Snake snake get (\None <- len:Int8 .
            0 len 1_1 - Int
            `(\None<-idx:Int .
                idx (tail#Snake snake get) at (\None <- xy:Int.
                xy 8_1 >> Int8 Int 3_1 << x#Screen scr write
                xy        Int8 Int 3_1 << y#Screen scr write
            )
            c sprite#Screen scr write
            ) loop
        )
        -- draw head
        ...
    )

The tail is an array of 16-bit integers which are actually pairs of 8-bit integers representing the coordinate for each segment of the tail. So what the code does is reading `xy` from the `tail` array, unpacking it into an x and y value, and multiplying these by 8 because we have 8x8 sprites so the movement is in steps of 8 pixels.

## Example 3: Funktal logo rendering

I implemented various ways of rendering the Funktal logo.

<figure>
<img src="{{ site.url }}/images/funktal-logo.png" alt="The Funktal logo, triangles and rectangles rendered as a grid of black dots" title="The Funktal logo, triangles and rectangles rendered as a grid of black dots" />
<figcaption>Funktal logo rendered using the example code</figcaption>
</figure>

[This example](https://codeberg.org/wimvanderbauwhede/funktal/src/branch/devel/examples/render-logo-gui-state-onFrame.ftal) is rendering it one pixel at a time for every frame event (clock tick). So it has no internal loops. It is a bit complicated because the Funktal logo can be decomposed into isosceles right triangles (the base and height are the same) and symmetry operations.
The array `triangleEncodings` contains a list of (triangle orientation, triangle position) pairs. There is a state `counters` with a counter for the triangle and the row and column position of the current pixel to be drawn. 


    onFrame = (\None.
        0_1 run get 1_1 ==
       `(
            trCodeIdx counters get
            rowIdx counters get
            colIdx counters get
            (\None <- tIdx:Int8 <- rIdx:Int8 <- cIdx:Int8.
                 tIdx Int triangleEncodings at rIdx cIdx drawPixel
                 cIdx rIdx <
                `( cIdx 1_1 + colIdx counters put )
                `( 0_1 colIdx counters put
                     rIdx triangleDim 1_1 - <
                    `( rIdx 1_1 + rowIdx counters put )
                    `( 0_1 rowIdx counters put
                         tIdx 14_1 <
                        `( tIdx 1_1 + trCodeIdx counters put )
                        `() if
                     ) if
                 ) if
            )
        ) `() if
        done
    )

There is a single control, pressing any key toggles pausing/continuing the rendering. That is the purpose of the first condition in the above code, `run` is a separate state.

## Conclusion

I hope this post and the previous one have provided some idea of what Funktal is like and what you can do with it. I plan to write another, longer article on how the compiler is made. For more information, see the a [specification](https://codeberg.org/wimvanderbauwhede/funktal/src/branch/main/SPEC.md) (aimed at people who want to program in Funktal) and the [design document](https://codeberg.org/wimvanderbauwhede/funktal/src/branch/main/DESIGN.md) (aimed at people who want to help develop Funktal or are just curious), both still very much in flux.

_The banner picture shows a detail of the control panel of a Japanese train_