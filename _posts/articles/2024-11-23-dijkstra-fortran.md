---
layout: article
title: "FORTRAN, an “infantile disorder”?"
date: 2024-11-23
modified: 2024-11-23
tags: [ computing, programming, Fortran, Lenin ]
excerpt: "A few notes on what the computing scientist Edsger Dijkstra said and didn't say about Fortran"
current: ""
current_image: dijkstra-fortran_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: dijkstra-fortran_1600x600.avif
  teaser: dijkstra-fortran_400x150.avif
  thumb: dijkstra-fortran_400x150.avif
---
A few notes on what the computing scientist Edsger Dijkstra said and didn't say about Fortran, and the origin of that term “infantile disorder”.

## Edsger Dijkstra 

[Edsger Dijkstra](https://inference-review.com/article/the-man-who-carried-computer-science-on-his-shoulders) was a Dutch computing scientist who helped shape the field in the 1960s-1980s and made important contributions to networking, concurrency and structured programming. He is probably best known for his strong objection to GOTO statements.

## What Dijkstra said and didn't 

In an article about [Fifty years of BASIC]( https://time.com/69316/basic/) ¹ I came across a claim about something Dijkstra had allegedly said: 

> He also spewed bile in the direction of FORTRAN (an “infantile disorder”), PL/1 (“fatal disease”) and COBOL (“criminal offense”).

Now, in the article referenced to back up this claim, ["How do we tell truths that might hurt?" (1975)]( https://dl.acm.org/doi/pdf/10.1145/947923.947924) , Dijkstra writes:

> FORTRAN, "the infantile disorder", by now nearly 20 years old, is hopelessly inadequate for whatever computer application you have in mind today: it is now too clumsy, too risky, and too expensive to use.

> PL/I --"the fatal disease"-- belongs more to the problem set than to the solution set. 

Note the quotes, which indicate he was quoting was someone else who called FORTRAN that. In [The Humble Programmer (1972)]( https://www.cs.utexas.edu/~EWD/transcriptions/EWD03xx/EWD340.html ) he says 

> When FORTRAN has been called an infantile disorder, full PL/1, with its growth characteristics of a dangerous tumor, could turn out to be a fatal disease.

So there also Dijkstra is saying that someone else called it that, and I will come back to this later. His own thoughts on FORTRAN are quite a bit more nuanced:

> The second major development on the software scene that I would like to mention is the birth of FORTRAN. At that time this was a project of great temerity and the people responsible for it deserve our great admiration. It would be absolutely unfair to blame them for shortcomings that only became apparent after a decade or so of extensive usage: groups with a successful look-ahead of ten years are quite rare! In retrospect we must rate FORTRAN as a successful coding technique, but with very few effective aids to conception, aids which are now so urgently needed that time has come to consider it out of date. 

Where Dijkstra went wrong in my opinion is in how he followed on from that:

> The sooner we can forget that FORTRAN has ever existed, the better, for as a vehicle of thought it is no longer adequate: it wastes our brainpower, is too risky and therefore too expensive to use. FORTRAN’s tragic fate has been its wide acceptance, mentally chaining thousands and thousands of programmers to our past mistakes. 

Because what effectively happened was that by 1977, the FORTRAN 77 standard incorporated the basic tenets of structured programming (control structures, recursive subroutines, blocks), and therefore effectively became a structured programming language, or at least a language that allowed structured programming  while not enforcing it. 

This was most likely a consequence of Dijkstra's own efforts, and as result we have a programming language that has never been forgotten but indeed has grown to incorporate more and more modern features. But it still has that bad reputation under "serious" computing scientists. 

When Dijkstra calls FORTRAN "too risky" to use, it is hard to know which precise risks he had in mind, but presumable a key risk had to do with the fact that in early FORTRAN, every loop was effectively a labeled jump, rather than a proper control structure, and certain ways of selection were thinly disguised conditional jumps. Dijkstra held (see e.g. [his famous "GOTO" article](https://dl.acm.org/doi/10.1145/362929.362947)) that no loop should have an early exit. 

Another obvious risk is that even FORTRAN 77 is not type safe. However, Fortran 90 programs that disallow certain legacy FORTRAN 77 constructs are actually type safe. 

And in both cases, it is possible to use source-to-source compilation to [convert the risky code into safe code](https://link.springer.com/article/10.1007/s11227-021-03839-9).


## The "Infantile Disorder"

The term "infantile disorder" is not a medical term an most likely was borrowed from the famous work by Lenin, ["Left-Wing" Communism: An Infantile Disorder](https://www.marxists.org/archive/lenin/works/1920/lwc/). But it should be noted that the original term in Russian, Детская болезнь (Detskaya Bolezn) means something closer to "childhood ailment"; in Dutch, Dijkstra's mother tongue, it would be "kinderziekte" which is a lot less dramatic. In the first English translation, the term in the title was "infantile sickness".

And indeed, that was Lenin's view: "Left-Wing" Communism was merely a childhood ailment which, easy to cure and which, when cured, would result in more robust organism:

> There is therefore nothing surprising, new, or terrible in the "infantile disorder" of "Left-wing communism" among the Germans. The ailment involves no danger, and after it the organism even becomes more robust. 
(Ch. 5)



> the error consisted in numerous manifestations of that "Leftwing" infantile disorder which has now come to the surface and will consequently be cured the more thoroughly, the more rapidly and with greater advantage to the organism. 
(Ch. 8) 


> Of course, the mistake of Left doctrinairism in communism is at present a thousand times less dangerous and less significant than that of Right doctrinairism (i.e., social-chauvinism and Kautskyism); but, after all, that is only due to the fact that Left communism is a very young trend, is only just coming into being. It is only for this reason that, under certain conditions, the disease can be easily eradicated, and we must set to work with the utmost energy to eradicate it. 
(Ch. 10)

It is probably a stretch to extend this to the case of FORTRAN, but when we do, we could consider the state of FORTRAN before its standardisation in 1977  the childhood with its ailments; the standardisation process the cure; and the subsequent revisions the growth into the robust and versatile programming language that Fortran is today, including [co-arrays](https://wg5-fortran.org/N1801-N1850/N1824.pdf), [OOP support](https://epubs.stfc.ac.uk/manifestation/2080/oo_fortran.pdf), and [many functional programming features](https://github.com/wavebitscientific/functional-fortran).

<!-- and even [lambdas](https://flibs.sourceforge.net/lambda_expressions.pdf) . -->

<small>¹ I could say a lot about BASIC too, it was the first language I ever learned, thanks to the brilliant TI-994A user manual. I used various dialects over the years, up to Visual Basic. Dijstra said that “It is practically impossible to teach good programming to students that have had a prior exposure to BASIC”. Luckily, nobody taught me how to program.</small>
<hr>
_The banner picture shows the K Computer Mae Station (京コンピュータ前駅) in Kobe, Japan. The K Computer was the most powerful supercomputer in 2011, and its dominant workload until it was decommissioned in 2019 was Fortran._
