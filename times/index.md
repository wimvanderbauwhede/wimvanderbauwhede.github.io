---
layout: default
---
{% capture tags %}
  {% for post in site.posts %}
      {% assign tag = post.preptime | truncate: 3, ' ' %}
      {{ tag }}
  {% endfor %}
{% endcapture %}
{% assign numtags = tags | split:' ' | uniq | sort %}

{% for numtag in numtags %}
{% capture tag %}{{numtag}} minutes{% endcapture %}
{% capture idtag %}{{numtag}}-minutes{% endcapture %}
<h3 id="{{ idtag }}">{{ tag }}</h3>
{% for post in site.posts %}
{% if post.preptime == tag %}
<a href="{{ site.url }}/{{ post.url }}"><img src="{{ site.url }}/images/{{ post.image.thumb }}" width="10%"></a>&nbsp;&nbsp;<a href="{{ site.url }}/{{ post.url }}">{{ post.title }}</a>
{% endif %}
{% endfor %}
{% endfor %}
