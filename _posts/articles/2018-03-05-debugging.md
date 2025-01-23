---
layout: article
title: "A strategy for debugging"
date: 2018-03-05
modified: 2018-03-05
tags: [ coding, hacking, programming, debugging ]
excerpt: "For a long time it has been my contention that for a developer, more that programming, debugging should be treated as a core skill."
current: "A strategy for debugging"
current_image: debugging_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: debugging_1600x600.avif
  teaser: debugging_400x150.avif
  thumb: debugging_400x150.avif
---

For a long time it has been my contention that for a developer, more than programming, debugging should be treated as a core skill. A developer typically spends more time debugging code than writing code so it makes sense to try and optimize this process. Over the years I have developed a strategy for debugging. I see debugging as a generic, transferable skill that is applicable not only to coding but to any form of systems design.

## The mental models

To debug a system we need a mental model, an understanding of the system in our mind. I believe this is the real cornerstone of debugging, and the common mistake is to spend too little time in constructing these models.

The mental model should cover all aspects of the system that you need to understand. For example, if you want to understand why a program is slow, your mental model of the system should allow you to reason about the performance trade-offs.

I distinguish three types of mental models, each of them corresponds to a different view of the system.

### Behavioural system model

The understanding of _what_ the system does (or should do), how it should behave, is the _behavioural_ model. A bug is observed through this model: the system behaves in a way that does not conform to the behavioural model.
Usually (or at least if you're lucky) the behavioural system model is codified in a specification.

### Operational system model

The _operational_ system model is your understanding of _how_ the system works. This model allows us to formulate hypotheses about _why_ the system does not behave as expected. This is the most important mental system model, and part of the debugging process is actually improving and refining this model.

In many cases, the operational model is actually your model of how a program in a given language is compiled/interpreted and executed on the hardware. This model starts from the syntax and semantics of the programming language, and includes a model for any API used in the code. As a trivial example, in Python, the keys in a dictionary are unordered, whereas the default in a C++ map is ordered.

The closer you are to the bare metal, or the more you care about performance or memory footprint, the more details your mental model will have to include about the actual hardware, to the extent that for e.g. running code on FPGAs you even need to have a detailed mental model for the memory controllers. For debugging in higher-level languages, usually the model can be much more abstract, with a basic notion of memory management and code execution.

### Structural system model

The _structural_ system model is the model of _where_ we should look to trace and fix a bug. For software, this model is our understanding of the code structure. In general, the structure of software systems tends to be hierarchical and relatively loosely coupled. This means we only need to focus on a fraction of the codebase at a time. If this were not the case, debugging time would grow more than linearly with the code size. Fortunately for most systems it's closer to logarithmic.

## The debugging activity

Given the above mental system models, the activity of debugging is an iterative process involving several steps, and during the process we often jump between these steps.

### Identifying the bug

First, identify the bug. Is it really a bug or is your behavioural model incorrect, not specific enough or ambiguous? If necessary, adapt the model and re-iterate.

Then there are essentially three stages in the process of finding the bug.

### Narrowing down through exclusion

We start by narrowing down through a process of exclusion: "This bug can't be caused by X because of reason Y". This process relies mostly on the operational system model, but sometimes also on the structural model, especially if you're not 100% certain: "it is unlikely that the bug is in module X because of reason Y". For example, it is unlikely that the cause of the bug is located in a standard library, compiler or interpreter. The chances that the bug is in your own code is much higher, so that possibility should be explored first.

### Formulating hypotheses

Once we cannot proceed any further through exclusion, we switch to the most interesting stage. We formulate a hypothesis "Let's assume that the bug is caused by X" and then we use this as the basis for further investigation.

The main difference between exclusion and formulating a hypothesis is that when we formulate a hypothesis, we don't know if it is true or false, so we need to test it. With the exclusion process, we do know that our stated reason holds -- or at least we have a high degree of confidence -- so we don't test it.

Quite frequently our hypothesis will prove to be false, and then we have one fewer possible cause for the bug. Equally frequently, when our hypothesis proves to be false, this indicates that our operational model is incomplete. In that case we should formulate additional hypotheses to improve our mental model. I believe this is an important step that is often skipped because it seems to detract from the real task, i.e. finding the bug. But without an accurate operational model, it is much harder to find bugs, so the time spent in improving your system knowledge is always well spent.

### Gathering information

To test a hypothesis we can either use emulation or observation of the system behaviour. This requires the structural model to tell us where to look.

- By emulation I mean that we mentally run part of a program using our operational model. In that case we assume that our operational model is accurate enough to produce the same result as the actual system. In general, this is a tricky approach to debugging because if our mental model is inaccurate we won't find the bug. However, it is generally the approach taken when we have narrowed down the location of the bug sufficiently.
- We can observe the system behaviour through compiler or interpreter warnings, by using a debugger, or by making the code generate additional information. This requires a good structural model to guide us to the locations that we want to inspect using the debugger or where we want to add the code to generate the debugging information.
- Either way, the result should be some information that helps to test the hypothesis.

## Example scenarios

### Debugging your own code

Debugging code you wrote and understand, and whose use case is intimately familiar to you, should be the easiest type of debugging. However, the problem with this kind of code is often that, precisely because it is your own code and you have a very precise behavioural model, and of course a perfect structural model, you never bothered to create an accurate operational model of the code. This may sound strange because after all, if you wrote it, you should know how it works. But the reality is that we often perform very limited mental verification, esp. of corner cases, on our own code.


### Debugging a minimal, complete, and verifiable example

Debugging someone else's code is much harder because you typically lack all of the mental models.

I often have to debug code written by my students, usually long after they have graduated. The main conclusion is that we should teach our students how to write maintainable code, i.e. code that makes it easy to understand the structural model.

If the code is a Minimal, Complete, and Verifiable example [MCVE](https://stackoverflow.com/help/mcve) then building your mental models is relatively easy because the code base should be small and self-contained. For such examples, the operational model is usually defined at the level of language semantics and standard library APIs. There is a nice detailed post about debugging small programs on [Eric Lippert's blog](https://ericlippert.com/2014/03/05/how-to-debug-small-programs/).


### Debugging a huge codebase

The main challenge with debugging a truly huge codebase (millions of lines of code) is that you need to build mental models that cover the overall system, even if you are looking to debug a very specific aspect of the system behaviour.

For example, some years ago I modified the Weather Research and Forecasting model to run on GPUs, and debugged the changes. This is a numerical weather simulator with a codebase of about two million lines of Fortran 90. It is very well architected and there is reasonably good documentation. The main challenge in this system was actually to understand the build system first, because a large amount of code is generated at build time. Apart from that, I had to learn how a weather simulator works at the level of the physics, and how the code was parallelised. I modified the part of the code known as the advection kernel, to make it work on GPUs. As expected, the changes were not first-time-right, and debugging GPU code is difficult because it is hard to observe what happens inside the GPU. Nevertheless, I followed essentially the approach outlined above.
In this case, the original, unmodified code provided the reference behavioural model. I built the structural model through the process of working out which part of the code needed to be modified.  So the difficulty was as usual with the operational model, and in this case the bugs mostly originated from the fact that the GPU code is essentially C, and the host code Fortran, and they have different views on arrays and argument passing.

## Conclusion

Debugging is difficult and time consuming but a strategy based on behavioural, operational and structural mental models can make the process more efficient in a variety of scenarios.

_I would like to thank [Ahmed Fasih](https://fasiha.github.io/) for motivating me to write this article and suggesting the example scenarios._
