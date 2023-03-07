---
layout: article
title: "Frugal computing: developer perspective"
date: 2021-12-20
modified: 2021-12-20
tags: [ computing, climate ]
excerpt: "On the need for low-carbon and sustainable computing and what developers can do about it."
current_image: frugal-computing-developer_1600x600.jpg
comments: false
toc: false
categories: articles
image:
  feature: frugal-computing-developer_1600x600.jpg
  teaser: frugal-computing-developer_400x150.jpg
  thumb: frugal-computing-developer_400x150.jpg
---

On the need for low-carbon and sustainable computing and what developers can do about it.

This is a follow-up on my [article about Frugal Computing]({{site.url}}/articles/frugal-computing), focusing on the what developers can do to help reduce the carbon emissions from computing. 

## Key points

### The problem: 
  - The current emissions from computing are about 2% of the world total but are projected to rise steeply over the next two decades. By 2040 emissions from computing alone will be more than half the emissions level acceptable to keep global warming below 1.5°C. This growth in computing emissions is unsustainable: it would make it virtually impossible to meet the emissions warming limit.
  - The emissions from production of computing devices far exceed the emissions from their electricity usage, so even if devices are more energy efficient producing more of them will make the emissions problem worse.
  - The CO₂ emissions from the internet infrastructure resulting from individual internet usage are also very large and growing steeply because of the increased use of higher-resolution video and VR/AR. 

### The solution:
  - As a society we need to start treating computational resources as finite and precious, to be utilised only when necessary, and as effectively as possible. We need _frugal computing_: achieving the same results for less energy. 

### Developer actions:

  - Make software that works on older devices, the older the better.
  - Make software that will keep on working for a very long time.
  - Make software that uses the least amount of total energy to achieve its results.
  - Make software that also uses the least amount of network data transfer, memory and storage.
  - Make software that encourages the user to use it in a frugal way.

## Extending the useful life of computing devices is key

End-user computing devices (phones, laptops, desktops) [create more emissions during their manufacturing than during their useful life, and this is not likely to change significantly in the next two decades](https://reboxed.co/blogs/outsidethebox/the-carbon-footprint-of-your-phone-and-how-you-can-reduce-it). Therefore, we must extend the useful life of our computing devices. This is the top priority.

### Make software that works on older devices, the older the better

One of the main reason why users upgrade their devices is that the device is no longer capable of supporting the needs of new software. This can be because the new software requires
  - more resources than the device has (memory, CPU speed, network bandwidth, screen resolution);
  - a more recent version of other software than device can support, including the operating system.

This is why when developing software, you should make it work on older devices by design. That way, users with older devices can use your software without having to upgrade. That also means your software should use the least amount of resources (CPU, memory, storage etc) possible to achieve its results, as older devices have fewer resources.
  
### Make software that will keep on working for a very long time

It is also important that the software you write will keep on working for as long as possible, ideally forever. One reason why your software might stop working is that its resource utilisation grows over time. This can for example be the case if it needs increasingly more memory or disk space the longer it gets used. Another reason is that bugs and vulnerabilities that are discovered only after a long time might not get fixed. 

The software needs to be supported for as long the device lasts. So frugal software requires a long-term commitment in terms of updates for security and bugfixing.

## Being frugal with resources

Whereas for mobile phones the emissions from usage are much lower than the emissions from manufacturing, for laptops and desktop computers, emissions from usage are still significant. 

### Make software that uses the least amount of total energy to achieve its results

Not only do older devices have fewer resources, resource consumption eventually means emissions, because all resources on a device consume energy. In practice, a large source of emissions resulting from end user device activity is the local Wifi, because transfering the data (e.g. video) consumes a lot of energy. However, on laptops, desktops and servers, CPU and GPU power consumption is also a significant factor.

The consequence is that as a developer, you need to be aware of all factors that contribute to the total enery consumption of a task performed by your software. For apps and web sites, the dominant sources of emissions are [in the home](https://www.carbontrust.com/our-work-and-impact/guides-reports-and-tools/carbon-impact-of-video-streaming). For [non-networked games, the power consumption of the CPU and GPU](https://www.researchgate.net/publication/336909520_Toward_Greener_Gaming_Estimating_National_Energy_Use_and_Energy_Efficiency_Potential) is the main source of emissions. 

### Make software that encourages the user to be frugal

For some applications, the behaviour of the user can have a major effect on the resources it uses. If you are developing such an application, consider if you can encourage or nudge the user to use fewer resources.

For example: 

- Web browsers need resources depending on the number of sites the user is accessing concurrently as well as on the design of the sites;
- for video based applications, energy consumption depends on the resolution of the video; 
- if the user experiences the app as sluggish or erratic, they might be more inclined to upgrade their device.

[Note: post edited on 2022-12-07 because the original post assumed that internet network emissions are proportional to the traffic volume, and more recent research shows this is not the case.]