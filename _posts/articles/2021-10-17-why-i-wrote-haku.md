---
layout: article
title: "Why I wrote Haku"
date: 2021-10-17
modified: 2021-10-17
tags: [ coding, hacking, programming, raku, haku ]
excerpt: "Haku is a natural language functional programming language based on literary Japanese. This article is about my motivation for creating Haku."
current: "Why I wrote Haku"
current_image: why-i-wrote-haku_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: why-i-wrote-haku_1600x600.avif

  teaser: why-i-wrote-haku_400x150.avif

  thumb: why-i-wrote-haku_400x150.avif

---

A few weeks ago I released [Haku](https://codeberg.org/wimvanderbauwhede/haku), a Japanese natural-language programming language. Haku is a strict functional language with implicit typing, and [an example program](https://codeberg.org/wimvanderbauwhede/haku/src/branch/main/examples/pwc131-t1.haku) looks like this:

<div style="writing-mode: vertical-rl">
<pre>
裂くとはパーツとヨウソで
若しパーツが空に等しいなら
［［ヨウソ］］ですけど
そうでなければ、
一パートはパーツの頭、
一パーツ一はパーツの尻尾、
一マエはパートの頭、
では
若しマエが〈ヨウソ引く一〉に等しいなら
［ヨウソ・パート］・パーツ一ですが
そうでなければ
［ヨウソ］・パーツ
の事です。

本とは
列は壱と弐と三と四と五と七と八と十一と十三と十六と十七、
仮一は列と空を裂くので畳み込む、
仮二は逆な仮一、
魄は仮二を逆で写像する、
魄を見せる
の事です。
</pre>
</div>

The [repository README](https://codeberg.org/wimvanderbauwhede/haku#haku) explains the language and gives some background, as does this [presentation](https://www.slideshare.net/WimVanderbauwhede/haku-a-toy-functional-language-based-on-literary-japanese). I have also written a separate post about the [implementation of Haku in Raku]({{site.url}}/articles/haku-in-raku). 

This article is about my motivation for creating Haku.

I am interested in how programming languages influence the programmer's thinking (the old adage of "to the programmer with a hammer, everything looks like a thumb"). 

From personal experience, I observe that my thinking patterns are quite different when I program in a functional language, an imperative one or an object-oriented one. There is also a marked difference between programming in a statically or dynamically typed language.

But what about the influence of the programmer's native language? Most programming languages are based on English, and in particular function calls typically use English word order. 

## Arithmetic in English and Flemish

For example, let's consider the common arithmetic operations +, -, *, /. If we use named functions rather than operators for these, and used the common parentheses-and-commas syntax for function calls, we get something like

    A+B: add(A,B) 
    A-B: subtract(A,B)
    A*B: multiply(A,B)
    A/B: divide(A,B)

In English we would express this most commonly as an infinitive or as an imperative. For the infinitive, we have:

<!-- <div class="highlight" style="background-color: #eadcb2">-->
    to add A and/to B
    to subtract A and/from B
    to multiply A and B
    to divide A and/by B

The pattern is `'to' <verb> A 'and' B`.

For the imperative, we have:

    add A and/to B
    subtract A and/from B
    multiply A and B
    divide A and/by B

The pattern is `<verb> A 'and' B`, so the same pattern apart from the `to`. And it is easy to see how this pattern informed the typical function call syntax `<verb> '(' A ',' B ')'`.

However, in Flemish (or Dutch), the order of the arguments is quite different. For the infinitive, we have:

    A en/bij B optellen; A optellen bij B
    A en/van B aftrekken; A aftrekken van B
    A en/met B vermenigvuldigen; A vermenigvuldigen met B
    A en/door B delen; A delen door B

The first variant has the pattern `A 'en' B <verb>`; the second variant needs a different preposition for each verb but the pattern is `A <verb> <preposition> B`. 

For the imperative, we have:

    tel A op bij B; tel A en/bij B op
    trek A af van B; trek A en/van B af
    vermenigvuldig A en/met B
    deel A en/door B

There is not just one single general pattern but three: `<verb> A 'en' B`, 
`<verb> A <preposition> <preposition> B` and  `<verb> A <preposition> B <preposition>`, depending on whether the verb has a preposition as part of it or not, and on the position we choose for that preposition. 

So not only are word orders for infinitive and imperative quite different, there is no simple rule for the imperative word order. Which makes me wonder what programming languages would look like if their developers had not been English native speakers. 

That question becomes even more interesting for non-Indo-European languages, because despite the example above, there are still lots of grammatical similarities between languages such as English, French and German.

## Japanese natural-language programming languages

There is one such language that particularly interests me and that is Japanese. I have been learning it for a long time and written [several posts on Japanese language related topics](https://quickandtastycooking.org.uk/articles/).

Besides having a very different grammar, Japanese has writing system that is a very different from the Latin alphabet as well as its own number system.

So I decided to create a natural-language programming language based on Japanese. 

There are already several Japanese natural-language programming languages, all made by Japanese native speakers. [Wikipedia lists eight](https://en.wikipedia.org/wiki/Non-English-based_programming_languages) but there are actually only four that are still under active development: [Dolittle](https://dolittle.eplang.jp/), [Produire](https://rdr.utopiat.net/), [Nadeshiko](https://nadesi.com/top/) and [Mind](https://www.scripts-lab.co.jp/mind/whatsmind.html). 

* _Dolittle_ ドリトル is an object-oriented language specifically designed for teaching children to program and follows the [Logo](http://people.eecs.berkeley.edu/~bh/logo.html) tradition with a turtle to draw shapes. 
* _Produire_ プロデル is an imperative and object-oriented language but more general purpose. It also has a turtle library, so education is definitely one of the main design purposes.
* _Nadeshiko_ なでしこ (meaning "pink", the flower) is an open source general purpose imperative language.
* _Mind_ is also imperative. Although it is actually a [Forth](https://www.forth.com/)-style stack-based language, in general structure it is similar to the other three. 

All these language are complete with support for graphics, networking etc and their own IDE and/or web-based editor. They are practical programming languages, so they all support the use of Arabic numerals as well as operators for arithmetic, logic and comparison operations. 

## Haku

My motivation to create Haku was not to create a practical language. I wanted to explore what the result is of creating a programming language based on a non-English language, in terms of syntax, grammar and vocabulary. In particular, I wanted to allow the programmer to control the register of the language to some extent (informal/polite/formal). [Nadeshiko](https://nadesi.com/v3/doc/index.php?%E6%96%87%E6%B3%95%2F%E6%95%AC%E8%AA%9E&show) and [Mind](https://www.scripts-lab.co.jp/mind/ver8/doc/02-Program-Hyoki.html#okurigana) allow this to some extent, but I wanted even more flexibility.

### Grammar

My main motivation for creating Haku is the difference in grammar between Japanese and most Indo-European languages.

Notions such as "noun", "adjective", "adverb" and "verb" are not quite so clearly defined in Japanese. For example, consider the word _yasashii_, "kind". A person who is kind is a _yasashii hito_. A person who is not kind is a _yasashikunai hito_. But in its own right, _yasashiku_ is and adverb, and _~nai_ is the plain negative verb ending, e.g. "I don't understand" is _wakaranai_. And this "adjective" can get a past tense: "the person who was not kind" is _yasashikunakatta hito_. And if we chain adjectives, e.g. "a kind and and clever person", we get _yasashikute kashikoi hito_. And indeed we can have _yasashihunakute　kashikonkatta hito_, "the kerson who was not kind and smart". It is also very easy to nominalise a verb or verbalise a noun by adding a suffix. 

The word order in a sentence is also quite different from most Indo-European languages. The typical order is main topic, secondary topic(s), verb. The function of the topics is indicated with what is called a "particle", a kind of suffix. For example, "I ate the pudding with a spoon" is _purin wo supuun de tabeta_. In this example, the main topic "I" is implied. Japanese is quite a parsimonious language: whenever possible, implied topics are left out, to be inferred from the context. 

Finally, compared to Indo-European languages, verb conjugation serves a different purpose in Japanese. For example in English, French and German, tenses are mainly uses to give precise indications of the time and duration of the action: simple past, present continuous, future perfect continuous etc. Japanese has essentially two tenses: the past and the non-past; and a form to similar to the -ing form in English to indicated an ongoing action, although that is again a loose approximation. However, there are many tenses to indicate modifiers to the verb to say e.g. that something is possible, that the speaker wants something, that a third party wants something, that the speaker has begun to do something, that someone is doing someone a favour and of course to express the level of politeness. For example, _shachou ha kiite kuremashita_ "the boss did me the favour of listening to me" (the _~mashita_ is a polite verb form), or _wasurekaketeita_ "I had begun to forget" (_~ta_ is a plain past, rather than polite).

Putting at least some of this grammar in the programming language seemed like an interesting challenge to me. In particular, I was interested in how programmers perceive functions calls. Some time ago I ran a poll about this, and 3/4 of respondents answered "imperative" (other options were infinitive, noun, -ing form). 

In Japanese, the imperative (_meireikei_, "command form") is rarely used. Therefore in Haku you can't use this form. Instead, you can use the plain form, the polite _-masu_ form or the _-te_ form (like "-ing"), including _-te kudasai_ (similar to "please"). Whether a function is perceived as a verb or a noun is up to you, and the difference is clear from the syntax. If it is a noun, you can turn it into a verb by adding _suru_, and if it is a verb, you can add the _no_ or _koto_ nominalisers. And you can conjugate the verb forms in many different ways, although in practice the verb ending has no semantic function in the Haku language.

### Naming and giving meaning

In principle, a programming language does not need to be based on natural language at all. The notorious example is APL, which uses symbols for everything. Agda programmers also tends to use lots of mathematical symbols. It works because they are very familiar with those symbols. An interesting question is if an experienced programmer who does not know Japanese could understand a Haku program; or if not, what the minimal changes would be to make it understandable. 

To allow to investigate that question, the Scheme and Raku emitters for Haku support (limited) transliteration to Romaji. I have the intention (but maybe not the time) to create a Romaji version of Haku as well as a version that does not use any Japanese but keeps the word order.

### Syntax and parsing
 
I also wanted the language to be closer, at lease visually, to literary Japanese. Therefore Haku does not use Roman letters, Arabic digits or common arithmetic, logical and comparison operators. It also supports top-to-bottom, right-to-left writing.  

Literary Japanese does not use spaces. So another question of interest to was how to tokenise a string of Japanese. 

- There are three writing systems: _katakana_ (angular), _hiragana_ (squigly) and _kanji_ (complicated). 
- _katakana_ is used in a similar way as italics, and also for loanwords and names of plants and animals.
- Nouns, verb, adjectives and adverbs normally start with a _kanji_
- _hiragana_ is used for verb/adjective/adverb endings and "particles", small words or suffixes that help identify the words in a sentence. 
- A verb/adjective/adverb can't end with a _hiragana_ character that represents a particle. 

So we have some simple tokenisation rules:
- a sequence of _katakana_
- a _kanji_ followed by more _kanji_ or _hiragana_ that do not represent particles
- _hiragana_ that represent particles

This is in fact a formalisation of the rules a human uses when reading Japanese. 

Where that fails, we can introduce parentheses. A human reader uses context, and a considerable amount of look-ahead parsing and backtracking, but that would make the parser very complex and slow.

In practice, only specific adverbs and adjectives are used in Haku. For example:

    ラムダ|は|或|エクス|で|エクス|掛ける|エクス|です

    ラムダ: katakana word
    は: particle
    或: pre-noun adjective
    エクス: katakana word
    で: particle
    エクス: katakana word
    掛ける: verb
    エクス: katakana word　
    です: verb (copula)

### Number system

For large numbers, Japanese uses a number system based on multiples of ten thousand (called _myriads_) rather than a thousand. A peculiar feature of this system is that there are _kanji_ for all powers of 10,000 up to 10<sup>48</sup>. For more background on this, please read [my article on this topic](https://quickandtastycooking.org.uk/articles/japanese-large-numbers/). 

The consequence is that a number such as 

    1,234,567,890 
    
is composed as 

      (10 + 2) * 100,000,000 
    + (3 * 1000 + 4 * 100 + 5 * 10 + 6) * 10,000
    +  7 * 1000 + 8 * 100 + 9 * 10
    
which can is written in _kanji_ as 

    十二億三千四百五十六万七千八百九十

There are also _kanji_ for numbers smaller than one. They go down to 10<sup>-12</sup> in powers of 10 and rational numbers are indicated with the _kanji_ 点 (_ten_, "dot"). So 

    3.14159

 can be written as    

     三点一分四厘一毛五糸九忽 

Apart from this format, the decimal format is also used, and is indeed more common for rational numbers and also for years (and dates in general), e.g. 2021 is written 二〇二一 instead of 二千二十一. Haku supports all these formats.

## Poetry

The expressiveness of Haku as a programming language is on purpose rather spartan. It is after all a "toy language", an experimental rather than general-purpose language. 

I am more interested in the natural-language expressiveness of Haku, and for that my criterion  is: Can the programmer write poetry in it? Several of Haku's features such as adjectives and verb conjugation (_okurigana_) are there entirely to make Haku programs sufficiently expressive on the natural-language level to support this idea. For that reason, my [favourite Haku program](https://codeberg.org/wimvanderbauwhede/haku/src/branch/main/examples/yuki.haku) is one that demonstrates this ability:

<div style="writing-mode: vertical-rl">
<pre>
忘れるとは件で空のことです。

遠いとは物で物を見せるのことです。

本とは
記憶は「忘れられないあの冬の the new fallen snow」、
忘れかけてた遠い記憶
の事です
</pre>
</div>

When run, this program prints out the string 「忘れられないあの冬の the new fallen snow」. The line that causes this string to be printed is 

忘れかけてた遠い記憶

_Wasurekaketeta tooi kioku_

This is on the one hand an example of some of the Japanese grammar features that Haku supports:

* adjectives as functions: _tooi_ is a so-called "i-adjective";
* adjectival verbs: _wasurekaketeta_ is a verb used as an adjective;
* complex verb conjucations: the plain form, used to define the function, is _wasureru_. The form _~kakeru_ means "starting to" and the final ending _~ta_ is a plain past. 

But on the other hand, it is also poetry.

## Why _haku_?

I decided to call my language _haku_ because I like the sound of it, and also because that word can be written in many ways and mean many things in Japanese (in my dictionary there are 89 _kanji_ that have _haku_ as one of their possible pronunciations). I was definitely thinking about the character Haku from the [Studio Ghibli movie "Spirited Away"](https://ghiblicollection.com/product/spirited-away-collector-s-edition?product_id=7231). Also, I like the resemblance with [Raku](https://raku.org), the implementation language. 

If I had to pick a _kanji_, I would write it 珀 (amber) or 魄 (soul, spirit).
