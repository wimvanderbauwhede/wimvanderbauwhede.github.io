---
layout: article
title: "The climate cost of the AI revolution"
date: 2023-03-06
modified: 2023-03-06
tags: [ computing, climate ]
excerpt: ""
current: ""
current_image: climate-cost-of-ai-revolution_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: climate-cost-of-ai-revolution_1600x600.jpg
  teaser: climate-cost-of-ai-revolution_400x150.jpg
  thumb: climate-cost-of-ai-revolution_400x150.jpg
---

Large Language Models (also called Generative AI) like GPT-3, and in particular its chat-based version ChatGPT, as well as models for image generation as used in  Midjourney, Stable Diffusion, DALL-E etc  have resulted in pushing Artificial Intelligence high on the hype cycle. In this article, I want to focus specifically on the energy cost of Large  Language Models (LLMs), what their widespread adoption could mean for global CO₂ emissions, and what could be done to limit these emissions.

## Carbon cost of electricity usage

How much CO₂ is emitted because of the electricity usage of LLMs? I argue that the metric to use is the carbon intensity of the geographical area in which the electricity is generated and can be traded. In practice, that means the country or group of countries of generation. Because electricity is still predominantly generated from fossil fuels (e.g. in the US, [according to IEA data](https://www.eia.gov/tools/faqs/faq.php?id=427&t=3) this is 60%; only 21% is truly renewable), using renewables simply results in displacement of the emissions. Renewables are already the cheapest form of generation, so generators do not need market pull to install more capacity: to maximise their profit, the must maximise their renewables capacity. Even when the generation is on-site, the argument still stands: that electricity could be traded on the grid. So we should use the overall carbon intensity of the US, which is 371 gCO₂/kWh according to [the Carbon Fund](https://carbonfund.org/calculation-methods/), or alternatively the global carbon intensity, 476 gCO₂/kWh according to [the IEA World Energy Outlook 2019](https://www.iea.org/reports/world-energy-outlook-2019). 

There is an imperative to *reduce* emissions from information and communication technologies (ICT): purely to keep to the Paris agreement, they should drop by 4x in the next 20 years, from about 2 GtCO₂e/y including embodied emissions to 500 MtCO₂e/y. So this is ICT's global carbon budget for the future.

This is not going to happen through renewables: with business as usual, by 2040, renewables will be at best 70% of all generated electricity, and crucially, generation from fossil fuels will largely remain constant. So even though we will have more electricity, we will not have less emissions. Therefore, reducing electricity consumption is critical.

## Training Large Language Models

According to [a paper by David Patterson et al.](https://arxiv.org/pdf/2104.10350.pdf), training  GPT-3 generates 552 ton of CO₂ (tCO₂e).  Using the metric as argued above, it is 477 tCO₂e.
This is not much compared to the [total emissions from ICT](https://www.sciencedirect.com/science/article/pii/S2666389921001884) (2 GtCO₂e/y, including embodied emissions), but it is still the same amount of CO₂ as produced by [heating 250 average UK homes for one year](https://heatable.co.uk/boiler-advice/average-carbon-footprint).

However, on the one hand, this is just a single model. On the other hand, one of the problems with those large language models is that they need to be kept up-to-date. People will expect the chat bot to know who this week's Prime Minister is, or the current hit song. Which means that training will need to be an ongoing process. So the carbon footprint will become many times larger than it already is. For the sake of argument, let's assume the model is retrained fully every day, then emissions from training would be 365 times larger, so about 175 ktCO₂e/y. If globally there would be a hundred such models from competing companies in different countries, that would mean an increase in global emissions of about 20 MtCO₂e/y.

This assumes full retraining; it is likely that the model will evolve so that there is a large static pre-trained set which needs to be updated infrequently, and a dynamic set which needs to be updated weekly or even daily. It is also likely that computational efficiency gains will be found. 

In any case, even if this was not so, and even if updates were daily, emissions from electricity generation used for training would not exceed 0.5% of global ICT CO₂ emissions &mdash; assuming these would for the rest remain constant, and that the number of such large models does not rise to thousands. 

What about the embodied carbon? [Microsoft claims](https://news.microsoft.com/source/features/ai/openai-azure-supercomputer/) that the supercomputer used to train GPT-3 hosts 10,000 GPUs and 285,000 CPU cores. Assuming these were similar to [NDv2 instances](https://learn.microsoft.com/en-us/azure/virtual-machines/ndv2-series), we can estimate their embodied carbon [starting from work by Boavizta](https://www.boavizta.org/en/blog/empreinte-de-la-fabrication-d-un-serveur) in the order of 2 tCO₂e per node, for 1250 nodes (8 GPUs per node). This is based on the assumptions that each node has a 3TB SSD, 512GB RAM and 2 Xeon CPUs, plus 8 V100 GPUs with each 32GB RAM.

So the total embodied carbon is of the order 2.5 ktCO₂ per machine. However, it takes 14 days to train GPT-3. So to manage daily retraining, 14 such machines are needed. Assuming 4 years useful life, that would result  in embodied carbon of the order of 35 ktCO₂e/y. So the embodied carbon is of the order of 20% of the total emissions, and we can put the total between 10 and 100 MtCO₂e/y to account for uncertainties in the estimates.

If overall ICT electricity consumption would reduce as required to limit global warming (i.e. a 4x reduction by 2040 to about 500 MtCO₂e/y), then the increased consumption from training of LLMs could with the highest estimate amount to 20% of the global total. Nevertheless, as the cost of this amount of energy for training would probably be prohibitive, and there are clearly technical options to reduce the energy consumption, I don't think it is likely that training of LLMs will become a major factor in ICT CO₂ emissions.

## Using Large Language Models

Next, let's consider the use of LLMs. An estimate for the footprint of ChatGPT is given by  [Chris Pointon](https://medium.com/@chrispointon/the-carbon-footprint-of-chatgpt-e1bc14e4cc2a) as 77,160 kWh per day assuming 13 million users per day with 5 questions each, so 65 million queries. This would generate
30 tCO₂e per day or 0.5 gCO₂e per query.

Just to be clear, in the big picture ([total global ICT emissions of 2 GtCO₂e](https://www.sciencedirect.com/science/article/pii/S2666389921001884)) this kind of footprint is still very small. But with a billions of queries per day, that means tens of MtCO₂e/y.

If that sounds improbably, consider this:  currently, Bing and Google each process 10 billion queries per day. So already, we would be looking at an electricity consumption of 8.7 TWh/y or emissions of 4 MtCO₂e/y purely from Bing and Google searches alone, without any growth or any other applications.

If there would be 100 such models as assumed above, that would mean 435 TWh/y or 200 MtCO₂e/y, even without taking into account the embodied carbon; recall that ICT has a proportional carbon budget of 500 MtCO₂e/y by 2040. There is probably no room for a hundred major search engines, but there are many other use cases for ChatGPT and other LLMs, e.g. dynamic content generation for SEO spamming, better email spam etc and there are of course also the image-based generative models. So the coexistence of just a hundred large applications of LLMs in the whole world is entirely plausible.

To put this into perspective, the total global CO₂ budget to limit global warming to below 1.5°C is 13GtCO₂e/y by 2040. From this it is clear that large-scale adoption of LLMs, even purely for search, would lead to unsustainable increases in CO₂ emissions.

## Reducing the climate cost

Assuming that ChatGPT-style LLMs make it through the Gartner hype cycle and are here to stay, their energy consumption would become a major concern. In the big picture, the best way to address this would of course be not to use this highly polluting technology. After all, there is no burning need for this type of technology, it us currently very much a case of a solution looking for a problem.

Second best would be to put a carbon tax on electricity usage. I think that is difficult because companies would likely resort to local generation. From my perspective that is simply hogging of renewables, but it would mean they can't be taxed.

Considering the scale of the required electricity generation, it is more precise to say "private generation": 
435 TWh/y is 15% of the global ICT electricity consumption. This can't simply be generated by putting a few solar panels on the roofs of the data centres. It would require a 500 MW wind farm per application. For example, the [Whitelee wind farm](https://en.wikipedia.org/wiki/Whitelee_Wind_Farm) near Glasgow has a maximum generative capacity of 539 MW and covers an area of 55 km² (about the size of Manhattan). Solar power is a bit more dense in hot countries, e.g. [Bhadla Solar Park](https://www.theecoexperts.co.uk/solar-panels/biggest-solar-farms) in India, the second largest solar farm in the world, has 2.7 GW capacity and covers 160 km², so 500MW would require 30 km².

So to provide "local" generation for such an LLM application, a company would have to buy a similar area of land for its private wind or solar farm, thereby reducing the area available for public generation. 


There is however a lot of scope for energy savings. To start with, for many applications there is no need for a model of the size of GPT-3. Something 10x smaller will do the job just fine, at a fraction of the cost. In fact, for many tasks, an LLM or BERT-style model is total overkill, and a conventional ML or IR technique will be orders of magnitude more cost effective to run. Especially in the context of chat-based search, generalised forms of caching and replacement of the LLM with a rule-based engine for much-posed queries would reduce the energy consumption significantly.