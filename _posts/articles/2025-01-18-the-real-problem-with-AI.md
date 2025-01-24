---
layout: article
title: The real problem with the AI hype
date: 2025-01-16
modified: 2025-01-16
tags: [ computing, climate ]
excerpt: "Even if the AI hype falls flat, it leads to increase emissions at a time when the world can't afford them at all."
comments: false
toc: false
categories: articles
image:
  feature: the-real-problem-with-AI_1600x600.avif
  teaser: the-real-problem-with-AI_400x150.avif
  thumb: the-real-problem-with-AI_400x150.avif
---

Climate change is an environmental problem. But our environment is what allows our society to thrive. The damage from climate change is societal and economical as well as ecological. And the only way to minimise this damage is to reduce global CO₂ emissions. Even keeping them at the current level will cause catastrophic warming. All this is explained in detail in the 2024 Emissions Gap Report of the United Nations [[16]](#16).

The current push for generative AI is deeply problematic in many ways. In this article I want to focus on the very real environmental damage caused not so much by the technology itself as by the hype surrounding it. 

In short:

* The hype creates an expectation of huge growth in demand for AI. Data centre companies have to start building capacity before this demand is realised, even if it never materialises. As a result, data centre capacity is being built up right now at an unprecedented scale. 
* This requires electricity generators to provision capacity for those future data centres, even if they would never be used.
* Without strong growth in demand, electricity generators would phase out fossil fuel generation because generating electricity from renewable sources is more cost-effective. Because of the AI hype, they are no longer phasing out fossil fuel generation as they want to maximise generation capacity to maximise future profits. New fossil fuel powered electricity plants are being developed as a result [[1]](#1) and existing ones are kept open for longer [[2]](#2). 
* As electricity generators of course want to optimise current profits as well, they want to sell all the electricity they can generate, rather than let plants idle. 
* And so global emissions from electricity generation are not decreasing at all, and are even expected to rise in the near future. This at a time when we need to reduce global emissions urgently and drastically. 


## Breakdown of data centre emissions

The greenhous gas emissions from a data centre can be broken down into a few main components, based on when and where the emissions are incurred:

1. Emissions incurred while building the data centre infrastructure (mainly the building itself and the cooling system). We will not discuss this further as it is mostly likely a relatively small contribution.
2. Emissions incurred while manufacturing the servers used in the data centre. The part of server manufacturing that produces by far the most emissions is the chip production. We will therefore focus on emissions from chip production
3. Emissions incurred while producing the electricity to run the servers. This is called the carbon intensity of electricity generation. This depends on where the data centre is located. But as data centres are globally distributed, we can consider the global average emissions of electricity production. 

We call 1. and 2. the "embodied carbon emissions" and 3. the "emissions from use". 

I think it is important to note that the global carbon intensity of electricity generation is decreasing. Unfortunately, this does not result in a decrease in emissions: what we see is that renewables are installed *in addition* to fossil fuel generation, rather than replacing them.

## A rough estimate of the growth in emissions

Let's first do a rough estimate. I present it mainly to give an idea of the scale of the global data centre power demand and of the chip production for the data centre servers.

### Emissions from data centre use

In 2023, the global electricity demand of data centres was 55 GW according to McKinsey [[3]](#3). According to Cushman & Wakefield [[4]](#4) it was 17 GW + 6 GW + 11 GW = 34 GW for Americas, EMEA and APAC combined, with another 49 GW under development. For APAC [[5]](#5) and for EMEA [[6]](#6), Savills confirm 11 GW resp. 6 GW; an extensive report by Lawrence Berkeley National Laboratory (LLNL) [[7]](#7) gives 20 GW for the US. So the figure used by McKinsey seems to be reliable. 

In terms of energy consumption that means 482 TWh/year. Global electricity generation is 30,000 TWh/y according to Our World in Data [[8]](#8).

### Embodied carbon emissions

I estimate the production of chips for data centres to consume 20 TWh/y. This is a very rough approximation, and likely an underestimate: I took the data for TSMC in Taiwan, which is producing most of Nvidia's GPUs but is of course not the only chip producer in the world. But in Taiwan are the four Gigafabs that make most of the GPUs so I used this as my estimate.

TSMC reports that there are in total 8 Gigafabs of which 4 in Taiwan [[9]](#9); also in Taiwan, 4 8-inch fabs and 1 6-inch fab; overall, 16 million 12-inch equivalent wafers in 2023. The combined capacity of the four facilities exceeded 12 million 12-inch wafers in 2023. So the four Gigafabs account for 3/4 of the total production. 

In 2023, TSMC's fabs consumed 23 TWh. Based on  a report by S&P Global [[10]](#10) this was 8% of Taiwan's total electricity production, which was 288 TWh in 2023 [[11]](#11). A article from Sept 2024 in IEEE Spectrum says it will be 12.5% in 2025 [[12]](#12).


### Growth in overall data centre emissions

Suppose the demand for AI data centres grows by 10× in ten years. That is about 25% per year and is within McKinsey's [[3]](#3) projections. 
Assuming a global electricity carbon intensity of 480 gCO₂e/kWh [[13]](#13) or 0.000480 GtCO₂e/TWh, then by 2035  the data centres would consume 4800 TWh/y and this would result in 2.3 GtCO₂e emissions. The chip production would consume 200 TWh/y or an extra 0.1 GtCO₂e. So the total data centre emissions as a result of 25% year on year growth over 10 years would be 2.4 GtCO₂e with this rough estimate. 

## Issues with this estimate

There are several oversimplifications in the above estimate. The most important one is that we can expect the electricity carbon intensity to keep decreasing over time. This will also affect the emissions from chip production. Furthermore, the servers are not running at full power all the time. So the actual emissions should be lower than this rough estimate. There are many other factors affecting the estimate, so to do this properly we need a much more refined model.

## A better estimate of the growth in emissions

We made a model for the evolution of data centre emissions over time, which takes into account both the embodied carbon [[15]](#15) and the emissions from use [[14]](#14). 
This model does not take into account the embodied carbon emissions from creating the actual infrastructure (data centres themselves, electricity supplies, networking, roads, water supplies). According to UNEP [[17]](#17), the footprint of the gobal construction sector was 10 GtCO₂e/y. Data centres are only a small fraction of all global construction, but I could not find reliable data and therefore could not include this contribution in the calculations.

Using our model, we arrive at an electricity consumption of 3400 TWh/y for the data centres by 2035. This is of the same order as the rough estimate, but as expected somewhat lower. The embodied carbon (which we modeled above by the estimate share of TSMC's electricity) is also considerably lower. The overall figure is 1.6 GtCO₂e of additional emissions (rather than the 2.4 GtCO₂e from our rough model; but rough as it was, this is quite close). This is still problematic: the total global CO₂ budget for 2035 is 22 GtCO₂e/y according to the UNEP Emissions Gap Report 2024 [[16]](#16). Global emissions from electricity generation were 14 GtCO₂e in 2023 and projected to rise to 15 GtCO₂e by 2035 without the growth in AI.

And if this trend would persist, then after 20 years of 22% growth year on year, the additional emissions would be almost 6 GtCO₂e/y.


## What about a hundred times growth?

If you think that the above growth rates sound crazy, Dell’s CEO has said that data centre capacity will increase by 100× over the next 10 years [[18]](#18). And OpenAI's Altman has said [[19]](#19) the world need 100× more semiconductor production capacity, which amounts to the same.

Needless to say, 100× growth would be a disaster: even if it happened in 20 years rather than in Michael Dell's 10 years, it would mean we end up at 36,000 TWh/y just for the data centres, and additional emissions of 11 GtCO₂e/y on a global CO₂ budget of only 10 GtCO₂e/y [[16]](#16) by 2045. In other words purely the emissions from making and running the servers would be more than the global emissions budget to meet the climate targets.


## The hype on its own is the real problem

To come back to my orginal premise: even if the growth in AI never materialises, the hype has set in motion a chain of events which, if allowed to go unchecked, can only lead to a rise in emissions. 

Once the extra electricity generation capacity has been created, generators will want to sell that electricity and therefore push hard to increase consumption. They will feel they have little choice, as they need at least to recoup their investment. 

Data centre operators also want to make a profit, or at least not a loss, so even if AI would die an ignoble death, they will try to find new workloads, and again push at consumers to use those new services. 

In this way the AI hype leads to increase emissions, even if there was no growth in AI workloads. And this at a time when we need to reduce global emissions urgently and drastically. Therefore *any* source of considerable additional emissions are problematic. 

*Note: the banner picture is* not *AI-generated*

## References

<small>
<span id="1">[1] [_"AI set to fuel surge in new US gas power plants"_, Finanical Times, January 2025, retrieved 17 January 2025](https://www.ft.com/content/63c3ceb2-5e30-44f4-bd39-cb40edafa4f8)</span><br>
<span id="2">[2] [_"IEA: Global coal power use reaches all time high, driven by increased electricity demand"_, Skidmore Z., 19 December 19 2024, retrieved 17 January 2025](https://www.datacenterdynamics.com/en/news/iea-global-coal-power-use-reaches-all-time-high-driven-by-increased-electricity-demand/)</span><br>
<span id="3">[3] [_"AI power: Expanding data center capacity to meet growing demand"_,  McKinsey & Company, 29 October 2024 , retrieved 17 January 2025](https://www.mckinsey.com/industries/technology-media-and-telecommunications/our-insights/ai-power-expanding-data-center-capacity-to-meet-growing-demand)</span><br>
<span id="4">[4] [_"Global Data Center Market Comparison"_, Cushman & Wakefield, 2024, retrieved 17 January 2025](https://cushwake.cld.bz/K5Eiws)</span><br>
<span id="5">[5] [_"Asia Pacific Data Centres"_, Savills, May 2024, retrieved 17 January 2025](https://pdf.savills.asia/asia-pacific-research/asia-pacific-research/ap-data-centre-spotlight-05-2024.pdf)</span><br>
<span id="6">[6] [_"European data centre power capacity projected to rise to approximately 13,100 MW by 2027"_, Savills, 30 May 2024, retrieved 17 January 2025](https://www.savills.co.uk/insight-and-opinion/savills-news/362723-0/european-data-centre-power-capacity-projected-to-rise-to-approximately-13-100-mw-by-2027)</span><br>
<span id="7">[7] [_"2024 United States Data Center Energy
Usage Report"_, Shehabi et al., December 2024, retrieved 17 January 2025](https://eta-publications.lbl.gov/sites/default/files/2024-12/lbnl-2024-united-states-data-center-energy-usage-report.pdf
)</span><br>
<span id="8">[8] [_"Electricity production by source"_, Our World in Data, 2024, retrieved 17 January 2025](https://ourworldindata.org/grapher/electricity-prod-source-stacked?tab=table)</span><br>
<span id="9">[9] [_"TSMC Fabs"_, TMC, retrieved 17 January 2025](https://www.tsmc.com/english/aboutTSMC/TSMC_Fabs)</span><br>
<span id="10">[10] [_"TSMC could account for 24% of Taiwan’s electricity consumption by 2030"_, Trueman C., 7 October 2024, retrieved 17 January 2025](https://www.datacenterdynamics.com/en/news/tsmc-could-account-for-24-of-taiwans-electricity-consumption-by-2030/
)</span><br>
<span id="11">[11] [_"Taiwan Electricity Production"_, CEIC, retrieved 17 January 2025](https://www.ceicdata.com/en/indicator/taiwan/electricity-production)</span><br>
<span id="12">[12] [_"TSMC’s Energy Demand Drives Taiwan’s Geopolitical Future"_, Fairley P., IEEE Spectrum, 3 September 2024, retrieved 17 January 2025](https://spectrum.ieee.org/taiwan-semiconductor)</span><br>
<span id="13">[13] [_"Carbon intensity of electricity generation, 2000 to 2023"_, Our World in Data, 2024, retrieved 17 January 2025](https://ourworldindata.org/grapher/carbon-intensity-electricity?tab=chart&country=EU-27~EU~G20+%28Ember%29~OWID_WRL)</span><br>
<span id="14">[14] ["LCA model for servers in a data centre", Vanderbauwhede W., 16 January 2025, retrieved 17 January 2025](https://codeberg.org/wimvanderbauwhede/low-carbon-computing/src/branch/master/LCA-model-equations/runLCAModel-AI.hs)</span><br>
<span id="15">[15] [_"Server embodied carbon model"_, Vanderbauwhede W., 17 January 2025, retrieved 17 January 2025](https://codeberg.org/wimvanderbauwhede/low-carbon-computing/src/branch/master/LCA-model-equations/calculateServerEmbodiedCarbon-DGX-A100.hs)</span><br>
<span id="16">[16] [_"Emissions Gap Report 2024"_, UN Environment Programme, 24 October 2024, retrieved 17 January 2025](https://www.unep.org/resources/emissions-gap-report-2024)</span><br>
<span id="17">[17] [_"2022 Global Status Report for Buildings and Construction"_, UN Environment Programme, 9 November 2022, retrieved 17 January 2025](https://www.unep.org/resources/publication/2022-global-status-report-buildings-and-construction)</span><br>
<span id="18">[18] [_"Michael Dell: AI to drive data center demand up 100x over next 10 years"_, Yadav N., 18 March 2024, retrieved 17 January 2025](https://www.datacenterdynamics.com/en/news/michael-dell-ai-to-drive-data-center-demand-up-100-fold-over-next-10-years/)</span><br>
<span id="19">[19] [_"The insatiable hunger of (Open)AI"_, Vanderbauwhede W., 10 March 2024, retrieved 17 January 2025]({site.url}/articles/the-insatiable-hunger-of-openai/)</span></small>