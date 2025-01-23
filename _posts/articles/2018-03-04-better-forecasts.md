---
layout: article
title: "Imagine we had better weather forecasts"
date: 2018-03-04
modified: 2018-03-04
tags: [ weather, accelerators, supercomputing ]
excerpt: "Current weather forecasts are at the same time very advanced and yet not good enough. Earlier and more accurate warnings could help to limit the damage of such events."
current: "Imagine we had better weather forecasts"
current_image: better-forecasts_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: better-forecasts_1600x600.avif
  teaser: better-forecasts_400x150.avif
  thumb: better-forecasts_400x150.avif
---

The last few days have shown that current weather forecasts are at the same time very advanced and yet not good enough. We had little warning of the very large amount of snow that would cripple our infrastructure. Earlier and more accurate warnings could help to limit the damage of such events (estimated at £470m a day just from the travel disruption). Also, better long-range predictions about the probabilities of such events in the future could help with investment and planning of infrastructure and services: should councils invest in more snow ploughs; should rail operators invest in making the network more resilient to extreme cold weather; how can the emergency services be kept running in such extreme conditions, etc.?

## So why are our forecasts not better?

### Resolution

One of the main reasons is that the resolution of the weather forecasting computer models is at the moment still quite coarse. For example the MetOffice forecasting model, which is considered amongst the best in the world, divides the UK in squares of 1.5 km at its highest resolution, i.e. the simulation produces a single averaged value anywhere within this 1.5 km x 1.5 km area. The time resolution for the shortest-term forecast is 50 seconds.

In contrast, for accurate simulation of local weather, a resolution of hundred metres and a time step of about a second are required. This would require a supercomputer a thousand times more powerful than the one currently in use by the MetOffice.

### Speed and power

<!--
Computers of course get faster all the time, but about ten years ago there was a fundamental change in _how_ they got faster. This is explained very well in the famous article ["The Free Lunch Is Over"](http://www.gotw.ca/publications/concurrency-ddj.htm) by Herb Sutter, but the result was that computers became harder to program and older programs would actually run _slower_ on the newer computers.
-->

 A key problem with supercomputers is that they consume _a lot_ of power. The current MetOffice supercomputer consumes 2.7 MW of electricity. A supercomputer a thousand times more powerful would need 2.7GW which is more than twice as much as all the electricity produced by the UK's largest nuclear power station, Hinkley Point B.

To reduce the power consumption, new supercomputers have started using special hardware called [_accelerators_](https://www.techradar.com/news/world-of-tech/future-tech/accelerating-supercomputing-power-1223031). Already, both the [fastest](https://www.top500.org/lists/2017/11/) and [most power-efficient](https://www.top500.org/green500/lists/2017/11/) supercomputers in the world use this technology.

### Programming challenges

Unfortunately writing programs for such an accelerator-based supercomputer is very complicated. And existing programs can't benefit from accelerators without major changes. Weather forecasting models are very large and complex, with around a million lines of code. Rewriting such a program is extremely difficult and time consuming.

## So what's hindering progress?

The holy grail is to develop a software technology that can automatically change legacy programs to make them suitable to the new, accelerator-based supercomputers. Many research groups, [including my own](https://www.nextplatform.com/2015/05/18/fpgas-held-back-in-hpc-but-hope-on-the-horizon/), are working on such approaches.

There is however a huge gap between a research proof-of-concept and a ready-for-use product and it takes considerable investment to bridge this gap. Unfortunately, a funding gap exists in this area: on the one hand, creating a product from a research proof-of-concept is not core research and can therefore not be funded by the Research Councils or through EU research funding. On the other hand, as there is no perceived commercial value in such a product (because the potential marked is very small), commercial funding is not an option.

## Imagine

So imagine that the UK took a more joined-up view with investment to speed up the adoption of research. In the case of weather forecasting, this would help to minimize the impact on people and the economy of severe weather events like we experienced recently. It would be a thousandfold return on the investment.

<!--
note: For even finer-grained local simulations, which would for example take into account the effect of the buildings in a city, resolutions of a few meters and time steps of a few hundredths of a second are necessary. This would require the model to compute a million times more data points than for the hundred-metres model and thus would require a billion times more computations than for the current model.
-->
