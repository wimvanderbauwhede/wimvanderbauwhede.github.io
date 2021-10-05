---
layout: article
title: "Frugal computing "
date: 2021-06-29
modified: 2021-06-29
tags: [ computing, climate ]
excerpt: "On the need for low-carbon and sustainable computing and the path towards zero-carbon computing."
current: "Writing faster Raku code"
current_image: frugal-computing_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: frugal-computing_1600x600.jpg
  teaser: frugal-computing_400x150.jpg
  thumb: frugal-computing_400x150.jpg
---

On the need for low-carbon and sustainable computing and the path towards zero-carbon computing.

* [Lisez en Français]({{site.url}}/translations/fr)
* [Lea en Español]({{site.url}}/translations/es)

## Key points

### The problem: 
  - The current emissions from computing are about 2% of the world total but are projected to rise steeply over the next two decades. By 2040 emissions from computing alone will be close to half the emissions level acceptable to keep global warming below 1.5°C. This growth in computing emissions is unsustainable: it would make it virtually impossible to meet the emissions warming limit.
  - The emissions from production of computing devices far exceed the emissions from operating them, so even if devices are more energy efficient producing more of them will make the emissions problem worse. Therefore we must extend the useful life of our computing devices.

### The solution:
  - As a society we need to start treating computational resources as finite and precious, to be utilised only when necessary, and as effectively as possible. We need _frugal computing_: achieving the same results for less energy. 

### The vision: 
  - Imagine we can extend the useful life of our devices and even increase their capabilities without any increase in energy consumption.
  - Meanwhile, we will develop the technologies for the next generation of devices, designed for energy efficiency as well as long life.
  - Every subsequent cycle will last longer, until finally the world will have computing resources that last forever and hardly use any energy.

## Defining computational resources

Computational resources are all resources of energy and material that are involved in any given task that requires computing. For example, when you perform a web search on your phone or participate in a video conference on your laptop, the computational resources involved are those for production and running of your phone or laptop, the mobile network or WiFi you are connected to, the fixed network it connects to, the data centres that perform the search or video delivery operations. If you are a scientist running a simulator in a supercomputer, then the computational resources involved are your desktop computer, the network and the supercomputer. For an industrial process control system, it is the production and operation of the Programmable Logic Controllers.

## Computational resources are finite

Since the start of general purpose computing in the 1970s, our society has been using increasing amounts of computational resources. 

For a long time the growth in computational capability as a function of device power consumption has literally been exponential, a trend expressed by [Moore's law](https://www.britannica.com/technology/Moores-law). 

With this growth in computational capability, increasing use of computational resources has become pervasive in today's society. Until recently, the total energy budget and carbon footprint resulting from the use of computational resources has been small compared to the world total. As a result, computational resources have until recently effectively been treated as unlimited. 

Because of this, the economics of hardware and software development have been built on the assumption that with every generation, performance would double for free. Now, this unlimited growth is no longer sustainable because of a combination of technological limitations and the climate emergency. Therefore, we need to do more with less. 

Moore's law has effectively come to an end as integrated circuits can't be scaled down any more. As a result, the performance per Watt is no longer increasing exponentially. On the other hand, the demand for computational resources is set to increase considerably.   

The consequence is that at least for the next decades, growth in demand for computational resources will not be offset by increased power efficiency. Therefore with business as usual, the total energy budget and carbon footprint resulting from the use of computational resources will grow dramatically to become a major contributor to the world total.

Furthermore, the resources required to create the compute devices and infrastructure are also finite, and the total energy budget and carbon footprint of production of compute devices is huge. Moore's Law has conditioned us to doubling of performance ever two years, which has led to very short effective lifetimes of compute hardware. This rate of obsolescence of compute devices and software is entirely unsustainable. 

Therefore, as a society we need to start treating computational resources as finite and precious, to be utilised only when necessary, and as frugally as possible. And as computing scientists, we need to ensure that computing has the lowest possible energy consumption. And we should achieve this with the currently available technologies because the lifetimes of compute devices needs to be extended dramatically. 

I would like to call this "frugal computing": achieving the same results for less energy by being more frugal with our computing resources. 

## The scale of the problem

### Meeting the climate targets

To limit global warming to 1.5&deg;C, within the next decade a global reduction from 55 gigatonnes CO₂ equivalent (GtCO₂e) by 32 GtCO₂e to 23 GtCO₂e per year is needed [[5]](#5). So by 2030 that would mean a necessary reduction in overall CO₂ emissions of more than 50%. According to the International Energy Agency [[10]](#10), emissions from electricity are currently estimated at about 10 GtCO₂e. The global proportion of electricity from renewables is projected to rise from the current figure of 22% to slightly more than 30% by 2040 [[15]](#15). In other words, we cannot count on renewables to eliminate CO₂ emissions from electricity in time to meet the climate targets. Reducing the energy consumption is the only option. 

### Emissions from consumption of computational resources

The consequence of the end of Moore's law was expressed most dramatically in a 2015 report by the Semiconductor Industry Association (SIA) "Rebooting the IT Revolution: a call to action" [[1]](#1), which calculated that, based on projected growth rates and on the 2015 ITRS roadmap for CMOS chip engineering technologies [[16]](#16), 

> computing will not be sustainable by 2040, when the energy required for computing will exceed the estimated world's energy production. 

It must be noted that this is purely the energy of the computing device, as explained in the report. The energy required by e.g. the data centre infrastructure and the network is not included. 

The SIA has reiterated this in their 2020 "Decadal Plan for Semiconductors" [[2]](#2), although they have revised the projection based on a "market dynamics argument": 

> If the exponential growth in compute energy is left unchecked, market dynamics will limit the growth of the computational capacity which would cause a flattening out the energy curve. 

This is merely an acknowledgement of the reality that the world's energy production is not set to rise dramatically, and therefore increased demand will result in higher prices which will damp the demand. So computation is not actually going to exceed the world's energy production.

> Ever-rising energy demand for computing vs. global energy production is creating new risk, and new computing paradigms offer opportunities to dramatically improve energy efficiency.

In the countries where most of the computational resources are consumed (US and EU), electricity production accounts currently for 25% of the total emissions [[4]](#4). According to the SIA's estimates, computation accounts currently for a little less than 10% of the total electricity production but is set to rise to about 30% by 2040. This would mean that, with business as usual, computational resources would be responsible for at least 10% of all global CO₂ emissions by 2040. 

The independent study "Assessing ICT global emissions footprint: Trends to 2040 & recommendations" [[3]](#3) corroborates the SIA figures: they estimate the computing greenhouse gas emissions for 2020 between 3.0% and 3.5% of the total, which is a bit higher than the SIA estimate of 2.5% because it does take into account networks and datacentres. Their projection for 2040 is 14% rather than 10%, which means a growth of 4x rather than 3x. 

To put it in absolute values, based on the above estimate, by 2040 energy consumption of compute devices would be responsible for 5 GtCO₂e, whereas the target for world total emissions from all sources is 23 GtCO₂e.

### Emissions from production of computational resources

To make matters worse, the carbon emissions resulting from the production of computing devices exceeds those incurred during operation. This is a crucial point, because it means that we can't rely on next-generation hardware technologies to save energy: the production of this next generation of devices will create more emissions than any operational gains can offset. It does not mean research into more efficient technologies should stop. But their deployment cycles should be much slower. Extending the useful life of compute technologies must become our priority.

The report about the cost of planned obsolescence by the European Environmental Bureau [[7]](#7) makes the scale of the problem very clear. For laptops and similar computers, manufacturing, distribution and disposal account for 52% of their [Global Warming Potential](https://www.sciencedirect.com/topics/earth-and-planetary-sciences/global-warming-potential) (i.e. the amount of CO₂-equivalent emissions caused). For mobile phones, this is 72%. The report calculates that the lifetime of these devices should be at least 25 years to limit their Global Warming Potential. Currently, for laptops it is about 5 years and for mobile phones 3 years. According to [[8]](#8), the typical lifetime for servers in data centres is also 3-5 years, which again falls short of these minimal requirements. According to this paper, the impact of manufacturing of the servers is 20% of the total, which would require an extension of the useful life to 11-18 years. 

### The total emissions cost from computing

Taking into account the carbon cost of both operation and production, computing would be responsible for 10 GtCO₂e by 2040, almost half of the acceptable CO₂ emissions budget [[2,3,14]](#2).

<figure>
<img src="{{ site.url }}/images/computing-emissions.png" alt="A graph with two bars: world emissions (55) and emissions from computing (0.1) in 2020; and for 2040, the world emissions target to limit warming to 1.5°C (23), and the projected emissions from computing (10)"
title="A graph with two bars: world emissions (55) and emissions from computing (0.1) in 2020; and for 2040, the world emissions target to limit warming to 1.5°C (23), and the projected emissions from computing (10)" />
<figcaption>Actual and projected emissions from computing (production+operation), and 2040 emission target to limit warming to &lt;2&deg;C</figcaption>
</figure>

### A breakdown per device type

To decide on the required actions to reduce emissions, it is important to look at the numbers of different types of devices and their energy usage. If we consider mobile phones as one category, laptops and desktops as another and servers as a third category, the questions are: how many devices are there in each category, and what is their energy consumption. The absolute numbers of devices in use are quite difficult to estimate, but the yearly sales figures [[10]](#10) and estimates for the energy consumption for each category [[11,12,13,14]](#11) are readily available from various sources. The tables below show the 2020 sales and yearly energy consumption estimates for each category of devices. A detailed analysis is presented in [[14]](#14).

<table>
<caption>Number of devices sold worldwide in 2020</caption>
<tr><th>Device type</th><th>2020 sales</th></tr>
<tr><td>Phones</td><td> 3000M</td></tr>
<tr><td>Servers</td><td> 13M</td></tr>
<tr><td>Tablets</td><td> 160M</td></tr>
<tr><td>Displays</td><td> 40M</td></tr>
<tr><td>Laptops</td><td> 280M</td></tr>
<tr><td>Desktops</td><td> 80M</td></tr>
<tr><td>TVs</td><td>220M</td></tr>
<tr><td>IoT devices</td><td> 2000M</td></tr>
</table>

The energy consumption of all communication and computation technology currently in use in the world is currently around 3,000 TWh, about 11% of the world's electricity consumption, projected to rise by 3-4 times by 2040 with business as usual according to [[2]](#2). This is a conservative estimate: the study in [[14]](#14) includes a worst-case projection of a rise to 30,000 TWh (exceeding the current world electricity consumption) by 2030. 

<table>
<caption>Yearly energy consumption estimates in TWh</caption>
<tr><th>Device type</th><th>TWh</th></tr>
<tr><td>TVs</td><td> 560</td></tr>
<tr><td>Other Consumer devices</td><td> 240</td></tr>
<tr><td>Fixed access network (wired+WiFi)</td><td> 900 + 500</td></tr>
<tr><td>Mobile network</td><td> 100</td></tr>
<tr><td>Data centres</td><td> 700</td></tr>
<tr><td>Total</td><td> 3000</td></tr>
</table>

The above data make it clear which actions are necessary: the main carbon cost of phones, tablets and IoT devices is their production and the use of the mobile network, so we must extend their useful life very considerably and reduce network utilisation. Extending the life time is also the key action for datacentres and desktop computers, but their energy consumption also needs to be reduced considerably, as does the energy consumption of the wired, WiFi and mobile networks. 


## A vision for low carbon and sustainable computing

It is clear that urgent action is needed: in less than two decades, the global use of computational resources needs to be transformed radically. Otherwise, the world will fail to meet its climate targets, even with significant reductions in other emission areas. The carbon cost of both production and operation of the devices must be considerably reduced. 

To use devices for longer, a change in business models as well as consumer attitudes is needed. This requires raising awareness and education but also providing incentives for behavioural change. And to support devices for a long time, an infrastructure for repair and maintenance is needed, with long-term availability of parts, open repair manuals and training. To make all this happen, economic incentives and policies will be needed (e.g. taxation, regulation). Therefore we need to convince key decision makers in society, politics and business.

Imagine that we can extend the useful life of our devices and even increase their capabilities, purely through better computing science. With every improvement, the computational capacity will in effect increase without any increase in energy consumption. Meanwhile, we will develop the technologies for the next generation of devices, designed for energy efficiency as well as long life. Every subsequent cycle will last longer, until finally the world will have computing resources that last forever and hardly use any energy.

<figure>
<img src="{{ site.url }}/images/towards-zero-carbon-computing.png" alt="A graph with four trends: emissions from production, emissions in total, performance and emissions/performance."
title="A graph with four trends: emissions from production, emissions in total, performance and emissions/performance." />
<figcaption>Towards zero carbon computing: increasing performance and lifetime and reducing emissions. Illustration with following assumptions: every new generation lasts twice as long as the previous one and cost half as much energy to produce; energy efficiency improves linearly with 5% per year.</figcaption>
</figure>

This is a very challenging vision, spanning all aspects of computing science. To name just a few challenges:

- We must design software so that it supports devices  with extended lifetimes.
- We need software engineering strategies to handle the extended software life cycles, and in particular deal with [technical debt](https://en.wikipedia.org/wiki/Technical_debt).
- Longer life means more opportunities to exploit vulnerabilities, so we need better cyber security.
- We need to develop new approaches to reduce overall energy consumption across the entire system.

To address these challenges, action is needed on many fronts. What will you do to make frugal computing a reality?

## References
<small>
  <span id="1">[1] [_"Rebooting the IT revolution: a call to action"_, Semiconductor Industry Association/Semiconductor Research Corporation, Sept 2015]( https://www.semiconductors.org/resources/rebooting-the-it-revolution-a-call-to-action-2/ )</span><br>
  <span id="2">[2] [_"Full Report for the Decadal Plan for Semiconductors"_, Semiconductor Industry Association/Semiconductor Research Corporation, Jan 2021](  https://www.src.org/about/decadal-plan/decadal-plan-full-report.pdf)</span><br>
  <span id="3">[3] [_"Assessing ICT global emissions footprint: Trends to 2040 & recommendations"_, Lotﬁ Belkhir, Ahmed Elmeligi, Journal of Cleaner Production 177 (2018) 448--463]( https://www.sciencedirect.com/science/article/pii/S095965261733233X)</span><br>
  <span id="4">[4] [_"Sources of Greenhouse Gas Emissions"_, United States Environmental Protection Agency]( https://www.epa.gov/ghgemissions/sources-greenhouse-gas-emissions), Last updated on April 14, 2021</span><br>
  <span id="5">[5] [_"Emissions Gap Report 2020"_, UN Environment Programme, December 2020]( https://www.unep.org/emissions-gap-report-2020)</span><br>
  <span id="6">[6] [_"The link between product service lifetime and GHG emissions: A comparative study for different consumer products"_, Simon Glöser-Chahoud, Matthias Pfaff, Frank Schultmann,  Journal of Industrial Ecology, 25 (2), pp 465-478, March 2021](  https://onlinelibrary.wiley.com/doi/full/10.1111/jiec.13123)</span><br>
  <span id="7">[7] [_"Cool products don’t cost the Earth – Report"_, European Environmental Bureau, September 2019]( https://eeb.org/library/coolproducts-report/)</span><br>
  <span id="8">[8] [_"The life cycle assessment of a UK data centre"_, Beth Whitehead, Deborah Andrews, Amip Shah, Graeme Maidment, Building and Environment 93 (2015) 395--405, January 2015]( https://link.springer.com/article/10.1007/s11367-014-0838-7)</span><br>
  <span id="9">[9] [Statista]( https://www.statista.com),  retrieved June 2021</span><br>
  <span id="10">[10] [_"Global Energy & CO₂ Status Report"_, International Energy Agency, March 2019]( https://www.iea.org/reports/global-energy-CO₂-status-report-2019/emissions)</span><br>
  <span id="11">[11] [_"Redefining scope: the true environmental impact of smartphones?"_, James Suckling, Jacquetta Lee, The International Journal of Life Cycle Assessment volume 20, pages 1181–1196 (2015)]( https://link.springer.com/article/10.1007/s11367-015-0909-4)</span><br>
  <span id="12">[12] [_"Server Rack Power Consumption Calculator"_, Rack Solutions, Inc., July 2019]( https://www.racksolutions.com/news/blog/server-rack-power-consumption-calculator/ )</span><br>
  <span id="13">[13] [_"Analysis of energy consumption and potential energy savings of an institutional building in Malaysia"_, Siti Birkha Mohd Ali,  M.Hasanuzzaman, N.A.Rahim, M.A.A.Mamun, U.H.Obaidellah,  Alexandria Engineering Journal, Volume 60, Issue 1, February 2021, Pages 805-820]( https://www.sciencedirect.com/science/article/pii/S111001682030524X)</span><br>
  <span id="14">[14] [_"On Global Electricity Usage of Communication Technology: Trends to 2030"_, Anders S. G. Andrae, Tomas Edler, Challenges 2015, 6(1), 117-157 ](https://doi.org/10.3390/challe6010117)</span><br>
  <span id="15">[15] [_"BP Energy Outlook: 2020 Edition"_,BP plc](https://www.bp.com/en/global/corporate/energy-economics/energy-outlook.html)</span><br>
  <span id="16">[16] [_"2015 International Technology Roadmap for Semiconductors (ITRS)"_, Semiconductor Industry Association, June 2015](https://www.semiconductors.org/resources/2015-international-technology-roadmap-for-semiconductors-itrs/)</span><br>
</small>
