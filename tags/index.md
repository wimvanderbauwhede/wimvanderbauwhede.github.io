---
layout: default
---

{% capture tags %}
  {% for tag in site.tags %}
      {{ tag[0] }}
        {% endfor %}    
{% endcapture %}
{% assign sortedtags = tags | split:' ' | sort %}

{% for tag in sortedtags %}
<h3 id="{{ tag }}">{{ tag }}</h3>
<!-- <ul> -->
{% for post in site.tags[tag] %}
<!--<li>-->
<a href="{{ site.url }}/{{ post.url }}"><img src="{{ site.url }}/images/{{ post.image.thumb }}" width="10%"></a>&nbsp;&nbsp;<a href="{{ site.url }}/{{ post.url }}">{{ post.title }}</a>
<!--</li>-->
{% endfor %}
<!-- </ul> -->
{% endfor %}


