---
layout: article
title: "The politics of writing compilers"
date: 2021-12-20
modified: 2021-12-20
tags: [ computing, climate ]
excerpt: "Is compiler research apolitical?"
current_image: politics-of-compiler-writing_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: politics-of-compiler-writing_1600x600.jpg
  teaser: politics-of-compiler-writing_400x150.jpg
  thumb: politics-of-compiler-writing_400x150.jpg
---

Compilers are pieces of software that convert program code from one format into another. Typically, they convert source code into a binary format for execution on specific hardware. Compilers can also target virtual machines instead of physical hardware, or they can convert source code into different source code. 

(Some programming languages are not compiled but interpreted, which means they require another piece of software, an interpreter, to run them. An interpreter is effectively a compiler and virtual machine combined, because it transforms the source code into some internal representation that it can execute. In this article, I focus on compilers but the same issues apply to interpreters.)

Most end users never deal with compilers because they simply run the compiled applications. Some users have the need, know-how and skills to compile code written by others; fewer again have the need, know-how and skills to write their own code and compile it. And quite few people have the know-how and skills to write a compiler. And yet, compilers are crucially important, as without a compiler, programs can't run. 

This automatically takes me to the question of politics. Whoever controls the compiler has some power over the users (both the programmers and the end users), and therefore compilers are political objects. 

But what about compiler research, the field of computing science which investigates new theories, formalisms and techniques to advance the knowledge on compilers? Generally speaking, compiler researchers will not consider their work political. A compiler is a tool that can be used regardless of political convictions, and research into better compilers just leads to better tools. Compiler writers can make a similar argument: we just make them. 

There are many different aspects to this. As a compiler researcher or compiler writer, you could ask yourself the following questions:

* What are the reasons for doing this work? 
    - Why are you writing this compiler? Or what is the target compiler for your research?
    - Who is going to benefit from your work? You? Your employer? The community? What community?
* What are your assumptions?
    - Assumptions on the programmer: 
        - What do they need to know?  
        - What education level do they need? 
        - How wealthy do they need to be?
    - Assumptions on the user: 
        - Who is the user of your compiler? 
        - What are their required skills and background? 
        - How usable and accessible is your compiler? 
        - Which users can afford to use your compiler?
    - Assumptions on the computer:
        - If your compiler targets a specific hardware architecture, who has access to this hardware?
        - Does your compiler need the latest hardware and/or latest operating system to run? 
        - How much memory and disk space does it need?
        - Does it need internet access?
    - Assumptions on the availability: 
        - Is it available free of charge? 
        - Does it work on many operating systems?
        - Is it available in a readily-useable form?

Inevitably, the answers to these questions are inherently political. 

<br>

_The banner picture shows activists and a candidate of the Communist Party of Japan._ 