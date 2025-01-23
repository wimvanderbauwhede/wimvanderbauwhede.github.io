---
layout: article
title: "Emissions from ChatGPT are much higher than from conventional search (updated)"
date: 2025-01-06
modified: 2025-01-06
tags: [ computing, climate ]
excerpt: "ChatGPT-style queries use about sixty times more energy compared to conventional search."
current: ""
current_image: google-search-vs-chatgpt-emissions_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: google-search-vs-chatgpt-emissions_1600x600.avif
  teaser: google-search-vs-chatgpt-emissions_400x150.avif
  thumb: google-search-vs-chatgpt-emissions_400x150.avif
---

Chat-assisted search is one of the key applications for ChatGPT. To illustrate the impact of ChatGPT-style augmented search queries more clearly, I compare the energy consumption and emission of a ChatGPT-style query with that of a conventional Google search-style query. If all search queries are replaced by ChatGPT-style queries, what does that mean for energy consumption and emissions?

* tl;dr: Emissions would increase by 60x for a GPT-3 style model of around 175B paramters; for a GPT-4 style model, it could be 200x.

In [a previous post]({{ site.url }}/articles/climate-cost-of-ai-revolution) I wrote about the potential climate impact from widespread adoption of ChatGPT-style Large Language Models. My projections are in line with those made by de Vries in his recent article [[5]](#5). In this post, I look in more detail at the increase in energy consumption from using ChatGPT for search tasks. A more detailed analysis is available [as a preprint paper](https://arxiv.org/abs/2407.16894).

## Update 2025-01-06

I originally published the estimates below on 2023-11-17 and they are for GPT-3. According to [George Hotz](https://www.latent.space/p/geohot) GPT-4 consists of 8 instances of 220B-parameter GPT-3 models; [Dylan Patel
and Gerald Wong](https://semianalysis.com/2023/07/10/gpt-4-architecture-infrastructure/) claim it is 16 instances of each about ~111B, which is the same in total. But they also state that only 2 of these are routed, so the inference is performed on two 111B models; however, they also share Furthermore, ~55B shared parameters for attention, so we get about 280B parameters. For comparison, GPT-3.5 is a single 175B-parameter model. According to Patel and Wong, the inference cost of GPT-4 is 3x more expensive that of than GPT-3.5, which is much more than the increase of 1.6x in parameters would suggest. As for the inference, the energy consumption dominates, this means that GPT-4 likely consume up to 3x more energy than GPT-3.5, and consequently, a search query with a GPT-4 generated AI summary might have emissions of about 200x larger than a search query without AI summary.

## Google search energy and emissions

In 2009, The Guardian published [an article about the carbon cost of Google search](https://www.theguardian.com/environment/ethicallivingblog/2009/jan/12/carbon-emissions-google). Google [had posted a rebuttal to the claim that every search emits 7 g of CO₂ on their blog](https://googleblog.blogspot.com/2009/01/powering-google-search.html). What they claimed was that, in 2009, the energy cost was 0.0003 kWh per search, or 1 kJ. That corresponded to 0.2 g CO₂, and I think that was indeed a closer estimate.

This number is still often cited but it is entirely outdated. In the meanwhile, [computing efficiency has rapidly increased](https://www.science.org/doi/abs/10.1126/science.aba3758): Power Usage Effectiveness (PUE, metric for overhead of the data centre infrastructure) dropped by 25% from 2010 to 2018; server energy intensity dropped by a factor of four; the average number of servers per workload dropped by a factor of five, and average storage drive energy use per TB dropped by almost a factor of ten. Google has released [some figures about their data centre efficiency](https://www.google.co.uk/about/datacenters/efficiency/) that are in line with these broad trends. It is interesting to see that PUE has not improved much in the last decade.

Therefore, with the ChatGPT hype, I wanted to revise that figure from 2009. Three things have changed: the carbon intensity of electricity generation has dropped [[11]](#11), server energy efficiency has increased a lot [[9]](#9), and PUE of data centres has improved [[10]](#10). Combining all that, my new estimate for energy consumption and the carbon footprint of a Google search is 0.00004 kWh and 0.02 g CO₂ (using carbon intensity for the US).
According to Masanet's peer-reviewed article [[9]](#9), hardware efficiency increases with 4.17x from 2010 to 2018. This is a power law, so extrapolating this to 12 years gives 6.70x. I use 12 years instead of 14 from 2009 as typically servers have a life of 4 years. Therefore the most likely estimate is that the current servers are two years old, i.e. they have the efficiency from 2021.

    PUE: 1.16 in 2010; 1.1 in 2023;
    efficiency increase of hardware in 12 years: 6.70x
    US overall carbon intensity: 367 gCO₂/kWh

    0.0003*(1.1/1.16)*(1/6.70) = 0.0000424 kWh per search
    0.0000424*367 = 0.02 g CO₂ per search

So the energy consumption per conventional search query has dropped by 7x in 14 years. There is quite some uncertainty on this estimate, but it is conservative, so it will not be less than that, but could be up to 10x. Microsoft has not published similar figures but there is no reason to assume that their trend would be different; in fact, their use of FPGAs should in principle lead to a lower energy consumption per query. In that same period, carbon emissions per search have dropped about 10x because of the decrease in carbon intensity of electricity.

## ChatGPT energy consumption per query

There are several estimates of the energy consumption per query for ChatGPT. I have summarised the ones that I used in the following table. There are many more, these are the top ranked ones in a conventional search ☺.

<table>
<thead>
<tr><th>Ref</th><th>Estimate (kWh/query)</th><th>Increase vs Google search</th></tr>
</thead>
<tbody>
<!-- <tr><td><a href="#1">[1]</a></td><td>0.00297</td><td>42x</td> </tr> -->
<tr><td><a href="#1">[1]</a></td><td>0.001 - 0.01</td> <td>24x - 236x</td></tr>
<tr><td><a href="#2">[2]</a></td><td>0.0017 - 0.0026</td><td>40x - 61x</td> </tr>
<tr><td><a href="#3">[3]</a></td><td>0.0068</td><td>160x</td> </tr>
<tr><td><a href="#4">[4]</a></td><td>0.0012</td><td>28x</td> </tr>
<tr><td><a href="#5">[5]</a></td><td>0.0029</td><td>68x</td> </tr>
</tbody>
</table>

Reference [[5]](#5) is the peer-reviewed article by Alex de Vries. It uses the estimates from [[6]](#6) for energy consumption but does not present a per-query value so I used the query estimate from [[6]](#6). Overall, the estimates lie between 24x and 236x (from [1], which is a collation of estimates from Reddit and therefore very broad) or 28x to 160x (all other sources). 

I consider any estimate lower than 0.002 kWh/query overly optimistic and any estimate higher than 0.005 kWh/query overly pessimistic. However, rather than judging, I calculated the mean over all these estimates. I used four types of means. Typically, an ordinary average gives more weight to large numbers; a harmonic mean gives more weight to small numbers. Given the nature of the data, I think the geometric mean is the best estimate:

<table>
<thead>
<tr><th>Type of Mean</th><th>Mean increase </th></tr>
</thead>
<tbody>
<tr><td>Average</td><td>88</td> </tr>
<tr><td>Median</td><td>61</td> </tr>
<tr><td>Geometric mean</td><td>63</td> </tr>
<tr><td>Harmonic mean</td><td>48</td> </tr>
</tbody>
</table>

As you can see, there is not that much difference between the geometric mean and the media. So we can conclude that ChatGPT consumes between fifty and ninety times more energy per query than a conventional ("Google") search, with sixty times being the most likely estimate.

## Other factors contributing to emissions

### Training

Contrary to popular belief, it is the use of ChatGPT, not its training, that dominates emissions. I wrote about this in [my previous post]({{ site.url }}/articles/climate-cost-of-ai-revolution). In the initial phase of adoption, with low numbers of users, emissions from training are not negligible, but I assume the scenario where conventional search is replaced by ChatGPT-style queries, and in that case emissions from training are only a small fraction. How much is hard to say as we don't know how frequently the model gets retrained and what the emissions are from retraining; they are almost certainly much lower as the changes in the corpus are small, so it is tuning.

### Data centre efficiency

As far as I can tell, PUE is not taken into account in the above estimates. For a typical hyperscale data centre, it is around 1.1.

### Embodied carbon

Neither the Google search estimate nor the ChatGPT query estimates include embodied carbon. The embodied carbon can be anywhere between 20% and 50% of the emissions from use, depending on many factors. My best guess is that the embodied emission are proportionate to the energy consumption, so this would not affect the factor much.

## Conclusion

Taken all this into account, it is possible that the emissions from a ChatGPT query are more than a hundred times that of a conventional search query. But as I don't have enough data to back this up, I will keep the conservative estimates from above (50x - 90x; 60x most likely).

Now, if we want sustainable ICT, then the sector as a whole needs to reduce its emissions to a quarter from the current ones by 2040. The combined increase in energy use and growth in adoption of ChatGPT-like applications is therefore deeply problematic.

## References

### Google Search energy consumption estimates

<a name="7">[7]</a> ["The carbon cost of Googling", Leo Hickman, 2009, The Guardian](https://www.theguardian.com/environment/ethicallivingblog/2009/jan/12/carbon-emissions-google)<br>
<a name="8">[8]</a> ["Powering a Google search", Google, 2009](https://googleblog.blogspot.com/2009/01/powering-google-search.html)<br>
<a name="9">[9]</a> ["Recalibrating global data center energy-use estimates", Eric Masanet et al, 2020](https://www.science.org/doi/abs/10.1126/science.aba3758)<br>
<a name="10">[10]</a> ["Data Centers: Efficiency", Google, 2023](https://www.google.co.uk/about/datacenters/efficiency/)<br>
<a name="11">[11]</a> ["Carbon intensity of electricity, 2022", Our World in Data, 2023](https://ourworldindata.org/grapher/carbon-intensity-electricity))

### ChatGPT energy consumption estimates

<!-- <a name="1">[1]</a> ["ChatGPT’s Electricity Consumption", Kasper Groes Albin Ludvigsen, 2023, Towards Data Science](https://towardsdatascience.com/chatgpts-electricity-consumption-7873483feac4) -->
<a name="1">[1]</a> ["AI and its carbon footprint: How much water does ChatGPT consume?", Nitin Sreedhar, 2023, lifestyle.livemint.com](https://lifestyle.livemint.com/news/big-story/ai-carbon-footprint-openai-chatgpt-water-google-microsoft-111697802189371.html)<br>
<a name="2">[2]</a> ["ChatGPT’s energy use per query", Kasper Groes Albin Ludvigsen, 2023, Towards Data Science)](https://towardsdatascience.com/chatgpts-energy-use-per-query-9383b8654487)<br>
<a name="3">[3]</a> ["How much energy does ChatGPT consume?" (Zodhya, 2023, medium.com)](https://medium.com/@zodhyatech/how-much-energy-does-chatgpt-consume-4cba1a7aef85)<br>
<a name="4">[4]</a> ["The carbon footprint of ChatGPT" (Chris Pointon, 2023, medium.com)](https://medium.com/@chrispointon/the-carbon-footprint-of-chatgpt-e1bc14e4cc2a)<br>
<a name="5">[5]</a> ["The growing energy footprint of artificial intelligence" (Alex de Vries, 2023, Joule](https://www.cell.com/joule/fulltext/S2542-4351(23)00365-3)<br>
<a name="6">[6]</a> ["The Inference Cost Of Search Disruption – Large Language Model Cost Analysis" (Dylan Patel and Afzal Ahmad, 2023, SemiAnalysis)](https://www.semianalysis.com/p/the-inference-cost-of-search-disruption)


