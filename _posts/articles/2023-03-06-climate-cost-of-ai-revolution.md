---
layout: article
title: "The climate cost of the AI revolution"
date: 2023-03-06
modified: 2023-03-06
tags: [ computing, climate ]
excerpt: "On the energy cost of Large  Language Models, what their widespread adoption could mean for global CO₂ emissions, and what could be done about it."
current: ""
current_image: climate-cost-of-ai-revolution_1600x600.avif
comments: false
toc: false
categories: articles
image:
  feature: climate-cost-of-ai-revolution_1600x600.avif
  teaser: climate-cost-of-ai-revolution_400x150.avif
  thumb: climate-cost-of-ai-revolution_400x150.avif
---

ChatGPT and other AI applications such as Midjourney have pushed "Artificial Intelligence" high on the hype cycle. In this article, I want to focus specifically on the energy cost of training and using applications like ChatGPT, what their widespread adoption could mean for global CO₂ emissions, and what we could do to limit these emissions.

## Key points

### Training of large AI models is not the problem

Training of large AI models requires a lot of electricity. However, for a modest growth scenario where there would be a hundred very popular AI-based services in the entire world, I estimate that the global CO₂ emissions from training AI are likely to remain relatively small.

### Large-scale use of large AI models would be unsustainable

For that same  modest growth scenario, with a hundred very popular AI-based services in the entire world, the electricity consumption resulting from the use of these services would lead to unsustainable increases in global CO₂ emissions.

### Renewables are not making AI more sustainable

Using renewables to power AI is not the solution. Large scale adoption of AI would lead to a huge increase in electricity consumption, much more than can be offset even by the fastest possible roll-out of renewables. So even if all AI is powered by renewables, it will not help us reduce global emissions and we will still miss the global climate targets.

### Reducing the climate cost of AI

 Technological solutions to increase energy efficiency of AI are likely to lead to a more than proportionate increase in demand for AI - as history has shown us with other technology adoptions. As with any activity that consumes energy, the best way to limit energy consumption is to limit the activity. As a society we need to treat AI resources as finite and precious, to be utilised only when necessary, and as effectively as possible. We need _frugal AI_. 



## Carbon cost of electricity usage

Many tech companies make much of their use of renewables to power their services. What metric should we use for the electricity usage of ICT in general and Large Language Models in particular? I argue that the metric to use is the carbon intensity of the geographical area in which the electricity is generated and can be traded. In practice, that means the country or group of countries of generation. If the usage is globally distributed, we should use the weighted average intensity.

Because electricity is still predominantly generated from fossil fuels. In the US, where most of the data centres for AI training and use are located, [according to IEA data](https://www.eia.gov/tools/faqs/faq.php?id=427&t=3) this is 60%; only 21% is truly renewable. According to [EuroStat](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Renewable_energy_statistics), in the EU renewables account for 22% and according to [National Grid](https://www.nationalgrid.com/stories/energy-explained/how-much-uks-energy-renewable), in the UK it is 38%. Therefore, using renewables for increased electricity usage simply results in displacement of the emissions. [Renewables are already the cheapest form of generation](https://www.weforum.org/agenda/2021/07/renewables-cheapest-energy-source/), so generators do not need market pull to install more capacity: to maximise their profit, they will maximise their renewables capacity. Even when the generation is on-site, the argument still stands: the electricity use to power AI could be traded on the grid. So in the case of GPT-3 we should use the overall carbon intensity of the US, which is 371 gCO₂/kWh according to [the Carbon Fund](https://carbonfund.org/calculation-methods/), or alternatively the global carbon intensity, 476 gCO₂/kWh according to [the IEA World Energy Outlook 2019](https://www.iea.org/reports/world-energy-outlook-2019).

## Carbon emissions from ICT

[There is an imperative to *reduce* emissions from information and communication technologies](https://limited.systems/articles/frugal-computing/) (ICT): purely to keep to the Paris agreement, they should drop to a quarter of current emissions in the next 20 years, from about [2 GtCO₂e/y (including embodied emissions)](https://www.sciencedirect.com/science/article/pii/S2666389921001884) to 500 MtCO₂e/y. So this is the global ICT carbon budget for the future.

This is not going to happen through renewables: with business as usual, by 2040 renewables will be [at best 70% of all generated electricity](https://iea.blob.core.windows.net/assets/deebef5d-0c34-4539-9d0c-10b13d840027/NetZeroby2050-ARoadmapfortheGlobalEnergySector_CORR.pdf), and crucially, [generation from fossil fuels will largely remain constant](https://iea.blob.core.windows.net/assets/deebef5d-0c34-4539-9d0c-10b13d840027/NetZeroby2050-ARoadmapfortheGlobalEnergySector_CORR.pdf). So even though we will have more electricity, we will not have less emissions. Therefore, reducing global electricity consumption from ICT is critical.

## Training Large Language Models

Although the large amount of CO₂ emissions resulting from AI training has received a lot of attention, I would argue that training of LLMs is not the main problem.

According to a peer-reviewed paper by [Patterson et al.](https://arxiv.org/pdf/2104.10350.pdf), training GPT-3 generates 552 ton of CO₂ (tCO₂e). (Using yearly average carbon intensity, it is 477 tCO₂e; the paper used the actual intensity during the period of training, and that was slightly higher).
This is not much compared to the [total emissions from ICT](https://www.sciencedirect.com/science/article/pii/S2666389921001884), but it is still the same amount of CO₂ as produced by [heating 250 average UK homes for one year](https://heatable.co.uk/boiler-advice/average-carbon-footprint).

However, on the one hand, this is just a single model. On the other hand, one of the problems with those large language models is that they need to be kept up-to-date. People will expect the chat bot to know who this week's Prime Minister is, or the current hit songs, games and movies. Which means that training will need to be an ongoing process. So the carbon footprint will become many times larger than it already is. For the sake of argument, let's assume as a worst case that the model would need to be retrained fully every day. Then emissions from training would be 365 times larger, so about 175 ktCO₂e/y. If globally there would be a hundred such models from competing companies in different countries, that would mean an increase in global emissions of about 20 MtCO₂e/y.

This assumes full retraining; it will likely become possible to split the training data into a large static pre-trained set which needs to be updated infrequently, and a dynamic set which needs to be updated weekly or even daily. It is also likely that computational efficiency gains will be found.

In any case, even if this was not so, and even if updates were daily, emissions from electricity generation used for training would not exceed 2% of global ICT CO₂ budget &mdash; assuming that the number of such large models does not rise to thousands.

What about the embodied carbon? [Microsoft claims](https://news.microsoft.com/source/features/ai/openai-azure-supercomputer/) that the supercomputer used to train GPT-3 hosts 10,000 GPUs and 285,000 CPU cores. Assuming these were similar to [NDv2 instances](https://learn.microsoft.com/en-us/azure/virtual-machines/ndv2-series), we can estimate their embodied carbon [starting from work by Boavizta](https://www.boavizta.org/en/blog/empreinte-de-la-fabrication-d-un-serveur) in the order of 2 tCO₂e per node, for 1250 nodes (8 GPUs per node). This is based on the assumptions that each node has a 3TB SSD, 512GB RAM and 2 Xeon CPUs, plus 8 V100 GPUs with each 32GB RAM.

So the total embodied carbon is of the order 2.5 ktCO₂ per machine. However, it takes 14 days to train GPT-3. So to manage daily retraining, 14 such machines are needed. Assuming 4 years useful life, that would result  in embodied carbon of the order of 35 ktCO₂e/y. So the embodied carbon is of the order of 20% of the total emissions, and we can put the total between 10 and 100 MtCO₂e/y to account for uncertainties in the estimates.

This means that the increased consumption from training of LLMs could with the highest estimate amount to 20% of the global ICT CO₂ budget. Nevertheless, as the cost of this amount of energy for training would probably be prohibitive, and there are clearly technical options to reduce the energy consumption, I don't think it is likely that training of LLMs will lead to more than a few percent increase in ICT CO₂ emissions. So far, so good.

## Using Large Language Models

Next, let's consider the use of LLMs. An estimate for the footprint of ChatGPT is given by  [Chris Pointon](https://medium.com/@chrispointon/the-carbon-footprint-of-chatgpt-e1bc14e4cc2a) as 77,160 kWh per day assuming 13 million users per day with 5 questions each, so 65 million queries. This would generate
30 tCO₂e per day or 0.5 gCO₂e per query.

Just to be clear, in the big picture ([total global ICT emissions of 2 GtCO₂e](https://www.sciencedirect.com/science/article/pii/S2666389921001884)) this kind of footprint is still very small. But with a billions of queries per day, that means tens of MtCO₂e/y.

If that sounds improbable, consider this:  currently, Bing and Google each process 10 billion queries per day. So already, we would be looking at an electricity consumption of 8.7 TWh/y or emissions of 4 MtCO₂e/y purely from Bing and Google searches alone, without any growth or any other applications.

If there would be 100 such models as assumed above, that would mean 435 TWh/y or 200 MtCO₂e/y, even without taking into account the embodied carbon; recall that ICT has a proportional carbon budget of 500 MtCO₂e/y by 2040, so that would be 40% of that budget; and this is a budget that can't be exceeded without letting global warming get out of control.

There is probably no room for a hundred major search engines, but there are many other use cases for ChatGPT and other LLMs, e.g. dynamic content generation for SEO spamming, better email spam etc and there are of course also the image-based generative models. So the coexistence of just a hundred large applications of LLMs in the whole world is entirely plausible.

 From this it is clear that large-scale adoption of LLMs would lead to unsustainable increases in ICT CO₂ emissions.

## Reducing the climate cost

Assuming that ChatGPT-style LLMs make it through the [Gartner hype cycle](https://www.gartner.com/en/research/methodologies/gartner-hype-cycle) and are here to stay, then their energy consumption will become a major concern. In the big picture, the best way to address this would of course be not to use this highly polluting technology. After all, there is no burning need for LLMs, it is currently very much a case of a solution looking for a problem.

Second best would be to put a carbon tax on electricity usage. That might seem like a good way to curb electricity use in general. However, companies would likely resort to on-site generation. Considering the scale of the required electricity generation, it is more precise to say "private generation" than "on-site" or "local":
435 TWh/y is 15% of the global ICT electricity consumption. This can't simply be generated by putting a few solar panels on the roofs of the data centres. It would require a 500 MW wind farm per application. For example, the [Whitelee wind farm](https://en.wikipedia.org/wiki/Whitelee_Wind_Farm) near Glasgow, the largest on-shore wind farm in the UK, has a maximum generative capacity of 539 MW and covers an area of 55 km² (about the size of Manhattan). Solar power in hot countries has a higher energy density, but is still of the same order: e.g. the [Bhadla Solar Park](https://www.theecoexperts.co.uk/solar-panels/biggest-solar-farms) in India, one of the largest solar farms in the world, has 2.7 GW capacity and covers 160 km², so 500MW would require 30 km².

So to provide "on-site" generation for an LLM application such as ChatGPT-enabled search, a company would have to buy a similar area of land for its private wind or solar farm, thereby reducing the area available for replacing generation from fossil fuels.

There is however a lot of scope for energy savings. To start with, for many applications there is no need for a model of the size of GPT-3. Something 10x smaller will do the job just fine, at a fraction of the cost. For example, many of Google's current models are of that size. Of course, if there are many, then combined they will have similar footprints.

Then there are potential efficiency savings, e.g. through use of energy-efficient hardware accelerators such as FPGAs, Google's TPU chips or Cerebras' Wafer-Scale Engine. All of these have in principle the potential to be an order of magnitude more efficient for both the training tasks and queries.

In fact, for many tasks an LLM or other large-scale model is at best total overkill, and at worst unsuitable, and a conventional Machine Learning or Information Retrieval technique will be orders of magnitude more energy efficient and cost effective to run. Especially in the context of chat-based search, the energy consumption could be reduced significantly through generalised forms of caching, replacement of the LLM with a rule-based engines for much-posed queries, or of course simply defaulting to non-AI search.

However, improved resource usage efficiency also lowers the relative cost of using a resource, which leads to increased demand [1]. This is known as [Jevons paradox](https://www.oecd-forum.org/posts/the-jevons-paradox-and-rebound-effect-are-we-implementing-the-right-energy-and-climate-change-policies) or the "rebound effect". Jevons described in 1865 how energy efficiency improvements increased  consumption of coal. What this means is that the way to reduce the climate cost of the AI revolution can't be purely technological. As with any activity that consumes energy, the best way to limit energy consumption is to limit the activity.

As a society we need to treat AI resources as finite and precious, to be utilised only when necessary, and as effectively as possible. We need _frugal AI_.