---
layout: article
title: Cheaper AI does not mean greener AI
date: 2025-01-13
modified: 2025-01-13
tags: [ computing, climate ]
excerpt: "The energy efficiency gains of LLM inference are not leading to lower emissions."
comments: false
toc: false
categories: articles
image:
  feature: cheaper-ai-is-not-greener-ai_1600x600.avif
  teaser: cheaper-ai-is-not-greener-ai_400x150.avif
  thumb: cheaper-ai-is-not-greener-ai_400x150.avif
---

In this article I have a look at the cost of queries for GPT-4 and similar models. The main conclusions are:

* The energy efficiency gains for queries to large language models (LLM) are not leading to lower emissions.
* On the contrary, the lower prices are likely to lead to increased use and therefore higher emissions.
* The cost of a query is mainly made up of the fixed cost (capex) of the data centre infrastructure and GPU servers. The electricity consumption contribution is a small proportion.
* Therefore, to maximise profit, it is the GPU utilisation that is optimised, to support as many users as possible on the available hardware. 
* But higher utilisation means higher energy consumption and therefore higher emissions. Projected growth makes this even worse.

## The urgent need to reduce emissions

To reiterate, according to the 2024 Emissions Gap Report of the UN [[1]](#1), the world must cut global greenhouse gas emissions to 20 gigatons CO₂-equivalent per year (GtCO₂e/y) by 2040 from the current level of 60 GtCO₂e/y to avoid catastrophic global warming, where “catastrophic” is meant quite literally: there will be a huge increase in frequency and severity of natural catastrophes if we don’t do this. Large parts of the earth will become unsuitable for habitation and agriculture.

To arrive at a sustainable level of emissions by 2040, global CO₂ emissions should reduced by close to 20% per year. However, currently, emissions are still rising at 1% &ndash; 2% per year, despite the increase in renewable electricity generation capacity.

The 2024 Emissions Gap Report of the UN [[1]](#1) explains in detail why renewables, carbon dioxide removal and carbon offsetting alone will not be sufficient to meet the targets. 

## Cheaper prompts, greener prompts?

The price per query/token for various LLMs has come down considerably compared to prices when GPT-3 was released. In his excellent article "Things we learned about LLMs in 2024" [[2]](#2), under the heading "The environmental impact got better" [[3]](#3), Simon Willison makes the following argument:

> A welcome result of the increased efficiency of the models—both the hosted ones and the ones I can run locally—is that the energy usage and environmental impact of running a prompt has dropped enormously over the past couple of years.

> OpenAI themselves are charging 100× less for a prompt compared to the GPT-3 days. I have it on good authority that neither Google Gemini nor Amazon Nova (two of the least expensive model providers) are running prompts at a loss.

> I think this means that, as individual users, we don’t need to feel any guilt at all for the energy consumed by the vast majority of our prompts. The impact is likely neglible compared to driving a car down the street or maybe even watching a video on YouTube.

Now, this all depends on the number of prompts, the size of the model and the size of the generated answers. For example, a single query to GPT-4 with a 1,000-word answer size produces 45 gCO₂e. An average UK car produces 132 gCO₂e/km. So this query is equivalent to driving a car 340 m, which is close to "down the street". And watching a YouTube video on a phone or tablet is less than 0.06 gCO₂e for watching 1 hour of HD video at 1080p; on a 40-inch TV it would be 16 gCO₂e. So still considerably less than the GPT-4 query. 

But that is really not the main argument. These AI workloads are in any case using extra energy, at an ever-increasing scale, and that energy is majority from fossil fuels. Every call to an LLM contributes to these additional emissions which we can't afford if we don't want catastrophic warming (or at least, if we want to limit the damage as much as possible). And  Simon Willison says that as well, under his next heading, "The environmental impact got much, much worse" [[4]](#4).

I looked at the electricity cost of running an LLM query and the pricing for a few of them. The energy consumption of GPT-4 is still several times larger than for GPT-3 [[5]](#5), and the energy consumption of Gemini 1.5 Pro is still of the order of GPT-3. And the prices are such that even without energy efficiency gains, their operation would still be profitable. Let's have a look at the figures.

## The electricity price for data centres is very low

Assuming that, because of their size, Google or OpenAI will always get the lowest prices, the price they  pay for their electricity is less than 6 cents [[6]](#6).

## Energy consumption of a GPT-3 style model

As I have discussed in detail in my article on the emissions of AI-augmented search [[7]](#7), the best estimate for the electricity consumption per query for GPT-3 and BLOOM is 0.003 kWh per query. This is to generate the AI summary for a search query so we will conservatively assume that the model is used to generate a 100-word summary. This is very conservative: the average query response length is actually only 30 words [[8]](#8).  At 6 cents per kWh, the electricity cost for such a query would be 0.018 cents per query, i.e. $0.00018; if we had assumed fewer generated tokens, it would be less.

## What makes up the cost of a query?

There are three main components to the cost of running a query: 

- the cost of building the infrastructure, 
- the cost of the servers and 
- the operation cost. 

The latter is dominated by the electricity cost (maintenance and water usage are lower contributors). Training an deploying a new model does not require a complete new data centre to be built, nor does it require replacing all the servers. But as the new models typically require more compute resources than the previous generation, it requires buying additional servers. 

The upshot is that the energy cost is not dominant. This is because building data centres and buying GPUs is very expensive. 

### Hardware cost

For example, a DGX-A100 server with eight A100 GPUs [[9]](#9) would cost $240k. (As I sanity check, in Feb 2023, SemiAnalysis [[10]](#10) quoted $195k for an 8× A100 server.) Running it for a year would cost about $2,400 (using a power consumption of 4550 W as reported by Nvidia [[11]](#11)).
So, for the running cost to exceed the fixed cost, the GPU server would need to run for a hundred years. But the servers will likely be replaced by the next generation GPU, which will arrive after two years, or at best after 5 years, so the hardware cost makes up the majority of the price. 

### Data centre infrastructure cost

Although hyperscale data centres are also very expensive to build, the data centre infrastructure cost is a smaller contribution to the overall cost because the data centre will last longer, with an expected life of 15 to 20 years [[12]](#12). The cost for a 60MW data centre that could accommodate 10,000 of the above servers is between $420 and $770M for construction [[13]](#13); but those 10,000 GPUs would cost $2.4 billion. 

### Inference cost contributions

If we assume a conservative model where we replace the servers only after 5 years, we take the average cost of $595M for construction and a 20-year lifespan and start at 1/4 capacity, and add 1/4 every 5 years for 20 years, we'd have $120M/year for the servers, $30M/year for the infrastructure and $15M/year for the electricity, or about 9% of the total cost. 

- This assumes that server and electricity costs costs don't change much over that period. 
- It is likely that each newer generation is about twice as energy efficient. If we would take that into account, the electricity would only be $2.4M/year, or less than 2% of the cost average over 15 years. 
- If the costs for servers and electricity would decrease over this period, the relative component of the infrastructure would increase but the electricity cost would still be a small proportion. 
- If, as is likely, servers would be replaced more frequently (every two years), then the contribution of the electricity usage to the cost will be even lower. 

(For completeness sake, such a 60MW data centre would use about 400M gallons of cooling water per year [[14]](#14), but that would cost only about $1M/year.)

### Conclusion on costs

What this tells us is that what matters in terms of profit is to optimise the utilisation of those expensive GPUs. So when the cost per query goes down, it is likely the consequence of improved utilisation, which means more users can be supported simultaneously, rather than improved energy efficiency.

## Price versus energy cost

### Gemini 1.5 Pro pricing

Generating 10,000 words using Gemini 1.5 Pro (10 RPM) costs ~$0.28 [[15]](#15) and the cost is proportional to the number of generated words (1000 words is ~$0.028, 100 words is ~$0.003) 

### OpenAI GPT-4 pricing

OpenAI GPT-4 charges between $0.030 and $0.120 per 1,000 tokens [[16]](#16) depending on the context length. The $0.030 is for GPT-4 Turbo, which is likely smaller than GPT-4.

### The price is much higher than the energy cost 

From these data, we can calculate the price/cost ratios. 

* Gemini 1.5 Pro is said to have 200B parameters [[17]](#17), which is of the same order as GPT-3. Using the cost per query for GPT-3 query, and model energy consumption scaling as the square root with parameter size as in this paper [[18]](#18), we get $0.028 / ($0.0018*sqrt(200B/175B)) = 14.55x; in other words, the price is 15× higher than the electricity cost.
Some say that it is only a 120B parameter model [[19]](#19); if that is the case, the ratio is 18.8×. 

* GPT-4 is said to be 3× more expensive than GPT-3 [[5]](#5), but GPT-4 Turbo could be only 1.5× more expensive. So our estimate is
GPT-4 : {0.030/1.5, 0.06/3,0.120/3 }/ 0.0018 =  {11.1×, 11.1×, 22.2×}; in other words, the price is 11× or 22× higher than the electricity cost. 

These figures are consistent with the relative cost contributions: with the GPU cost 10× larger, the price should indeed be more than 10× that of the electricity consumption. It also means that the electricity consumption does not matter much in the overall picture, i.e. Google and OpenAI don't have a huge incentive to prioritise increasing energy efficiency.

## Note on faster hardware

I used the energy consumption of GPT-3 running on A100 servers as reference, as inference is still predominatly done on A100. If all inference would run on H100 servers instead, we would expect better peformance. If that is the case, all ratios calculated above increase even more and so the electricity consumption contributes even less to the total cost. In other words, the conclusion that prices are not dominated by electricity consumption is even more valid. 

## Server lifecycle emissions

I have created a detailed life cycle analysis model for the servers [[20]](#20). The figure below shows embodied carbon emissions and emissions from use for hardware replacement cycles of 2, 3 and 5 years.

<figure>
<img src="{{ site.url }}/images/XXX.avif" alt="XXX"
title="XXX" />
<figcaption>Embodied carbon emissions and emissions from use over 15 years for hardware replacement cycles of 2, 3 and 5 years, assuming DGX-A100 servers.</figcaption>
</figure>

The results depend on many assumptions, but the conclusion is robust: embodied carbon from manufacturing the servers will be of the same order as the emissions from running the servers. 

This is mainly because the AI business needs ever increasing amounts of hardware, even though the hardware has become faster. I have used a figure of 22% per year as per the analysis by McKinsey [[21]](#21). So although the energy efficiency of the hardware increases with every generation, the combination of the embodied carbon and the growth in hardware resources still results in a huge increase in emissions. 

## Conclusion

For both Gemini 1.5 Pro and GPT-4, we see that their energy consumption is still of the order of GPT-3, and even with current low prices, the price is more than ten times the energy cost. This is because the high cost an short lifetime of the GPU servers makes up most of the total cost of inference. Of course the argument is that both models are more capable than GPT-3 and therefore there are energy efficiency gains. But the point is that large-scale deployment of these models leads to unacceptably high and rapidly increasing CO₂ emissions. 

From a climate change perspective, energy efficiency gains are only really meaningful if they result in a reduction of the overall emissions. That is clearly not the case. And the low price is likely to make this only worse, as it will drive adoption and further growth in data centres and so increase both embodied carbon and runtime emissions. 

## References

<small><span id="1">[1] [_"Emissions Gap Report 2024"_, UN Environment Programme, 24 October 2024, retrieved 17 January 2025](https://www.unep.org/resources/emissions-gap-report-2024)</span><br>
<span id="2">[2] [_"Things we learned about LLMs in 2024"_, Willison S., 31 December 2024, retrieved 17 January 2025](https://simonwillison.net/2024/Dec/31/llms-in-2024/)</span><br>
<span id="3">[3] [_"The environmental impact got better"_, Willison S., 31 December 2024, retrieved 17 January 2025](https://simonwillison.net/2024/Dec/31/llms-in-2024/#the-environmental-impact-got-better)</span><br>
<span id="4">[4] [_"The environmental impact got much, much worse"_, Willison S., 31 December 2024, retrieved 17 January 2025](https://simonwillison.net/2024/Dec/31/llms-in-2024/#the-environmental-impact-got-much-much-worse)</span><br>
<span id="5">[5] [_"GPT-4 Architecture, Infrastructure, Training Dataset, Costs, Vision, MoE Demystifying GPT-4: The engineering tradeoffs that led OpenAI to their architecture"_, Patel D. and Wong G., 10 July 2023, retrieved 17 January 2025](https://semianalysis.com/2023/07/10/gpt-4-architecture-infrastructure/)</span><br>
<span id="6">[6] [_"Cincinnati I Data Center Attributes"_, H5 Data Centers, 2024, retrieved 17 January 2025](https://h5datacenters.com/cincinnati-data-centre.html)</span><br>
<span id="7">[7] [_"Estimating the Increase in Emissions caused by AI-augmented Search"_, Vanderbauwhede W., 6 January 2025, retrieved 17 January 2025](https://arxiv.org/abs/2407.16894)</span><br>
<span id="8">[8] [_"ChatGPT Statistics — The Key Facts and Figures"_, Walsh M., 22 April 2024, retrieved 17 January 2025](https://www.stylefactoryproductions.com/blog/chatgpt-statistics)</span><br>
<span id="9">[9] [_"BIZON G9000 – 4x 8x NVIDIA A100, H100, H200 Tensor Core AI GPU Server with AMD EPYC, Intel Xeon"_, BIZON, retrieved 17 January 2025](https://bizon-tech.com/bizon-g9000.html#4654:46140;4656:46198;4658:46417;4660:46293;4661:46306)</span><br>
<span id="10">[10] [_"The Inference Cost Of Search Disruption – Large Language Model Cost Analysis $30B Of Google Profit Evaporating Overnight, Performance Improvement With H100 TPUv4 TPUv5"_, Patel D. and Ahmad A., 9 February 2023, retrieved 17 January 2025](https://semianalysis.com/2023/02/09/the-inference-cost-of-search-disruption)</span><br>
<span id="11">[11] [_"Energy and Power Efficiency for Applications on the Latest NVIDIA Technology"_, Gray A, 
Alan Gray, GTC 24, GTC 2024, 20th March 2024, retrieved 17 January 2025](https://developer-blogs.nvidia.com/wp-content/uploads/2024/10/Energy-Efficiency-GTC.pdf)</span><br>
<span id="12">[12] [_"The data center life story"_, Judge P., 21 July 2017, retrieved 17 January 2025](https://www.datacenterdynamics.com/en/analysis/the-data-center-life-story/)</span><br>
<span id="13">[13] [_"How Much Does it Cost to Build a Data Center?"_, Zhang M., 5 November 2023, retrieved 17 January 2025](https://dgtlinfra.com/how-much-does-it-cost-to-build-a-data-center/)</span><br>
<span id="14">[14] [_"Water-guzzling data centres"_, Ashtine M. and Mytton D., retrieved 17 January 2025](https://eng.ox.ac.uk/case-studies/the-true-cost-of-water-guzzling-data-centres)</span><br>
<span id="15">[15] [_"Gemini Pro API Pricing Calculator"_, InvertedStone, retrieved 17 January 2025](https://invertedstone.com/calculators/gemini-pricing/)</span><br>
<span id="16">[16] [_"How much does GPT-4 cost?"_, OpenAI, 2024, retrieved 17 January 2025](https://help.openai.com/en/articles/7127956-how-much-does-gpt-4-cost)</span><br>
<span id="17">[17] [_"Google Gemini PRO 1.5: All You Need To Know About This Near Perfect AI Model"_, Shittu H., 9 September 2024	, retrieved 17 January 2025](https://felloai.com/2024/09/google-gemini-pro-1-5-all-you-need-to-know-about-this-near-perfect-ai-model/)</span><br>
<span id="18">[18] [_"Measuring and Improving the Energy Efficiency of Large Language Models Inference"_, Argerich M. and Patiño-Martínez M., IEEE Access, 2024, Vol. 12, 5 June 2024](https://ieeexplore.ieee.org/document/10549890)</span><br>
<span id="19">[19] [_"Discussion: Gemini 1.5 May Technical paper"_, 2024, retrieved 17 January 2025](https://www.reddit.com/r/LocalLLaMA/comments/1cxlsa9/i_read_the_full_gemini_15_may_technical_paper_i/)</span><br>
<span id="20">[20] [_"LCA model for servers in a data centre "_, Vanderbauwhede W., 16 January 2025, retrieved 17 January 2025](https://codeberg.org/wimvanderbauwhede/low-carbon-computing/src/branch/master/LCA-model-equations/LCA-data-centre-growth-AI.hs)</span><br>
<span id="21">[21] [_"AI power: Expanding data center capacity to meet growing demand"_,  McKinsey & Company, 29 October 2024 , retrieved 17 January 2025](https://www.mckinsey.com/industries/technology-media-and-telecommunications/our-insights/ai-power-expanding-data-center-capacity-to-meet-growing-demand)</span></small>



