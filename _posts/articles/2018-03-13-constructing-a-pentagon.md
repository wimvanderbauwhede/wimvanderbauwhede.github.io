---
layout: article
title: "A little maths puzzle in two parts"
date: 2018-03-13
modified: 2018-03-13
tags: [ maths, trigonometry, algebra ]
excerpt: "Of which the outcome is a way to construct a regular pentagon using compass and ruler."
current: ""
current_image: constructing-a-pentagon_1600x600.jpg
comments: false
toc: false
categories: articles
use_math: true
image:
  feature: constructing-a-pentagon_1600x600.jpg
  teaser: constructing-a-pentagon_400x150.jpg
  thumb: constructing-a-pentagon_400x150.jpg
---

I like solving little maths puzzles, deriving known results using nothing more complicated than secondary school level trigonometry, algebra and maybe a little calculus. The one below is actually two puzzles, but both have to do with regular polygons. 

## Part 1 Approximating &pi; by the perimeter of a regular polygon

Can one approximate $\pi$ by the perimeter of regular polygon with
increasing numbers of sides inscribed in a unit circle, so starting with
a triangle, then a hexagon, a dodecagon,... ? You may say that is obvious: the more sides, the closer the polygon approximates a circle. But I still wanted to work out the proof.

<figure>
<img src="{{ site.url }}/images/polygons-to-pi.png" width="80%" alt="Relationship between length of the side of a polygon and the
angle" id="fig:Relationship-between-lenght" />
<figcaption>Figure 1. Relationship between length of the side of a polygon and the
angle</figcaption></figure>

From  <a href="#fig:Relationship-between-lenght">Figure 1</a>, clearly

$$\begin{equation}
b=2\,sin\frac{\alpha}{2}\label{eq:1}
\end{equation}$$


For a polygon with *n* sides, we have

$$\begin{equation}
\alpha=\frac{2\pi}{n}\label{eq:2}
\end{equation}$$

So we can express the lenght of the side of a polygon as a function of
the number of sides as

$$\begin{equation}
b(n)=2\,sin\frac{\pi}{n}\label{eq:3}
\end{equation}$$

The perimeter of a regular polygon is obviously

$$\begin{align}
n.b(n) & = & 2n\,sin\frac{\pi}{n}\label{eq:4}\\
 & = & 2\pi\frac{sin\frac{\pi}{n}}{\frac{\pi}{n}}\nonumber \end{align}$$

We know that

$$\begin{equation}
\underset{x\rightarrow0}{lim}\frac{sin\,x}{x}=1\label{eq:5}
\end{equation}$$


This is easily proven using <a href="https://en.wikipedia.org/wiki/L%27H%C3%B4pital%27s_rule">de l’Hôpital’s
rule</a>
<br><br>

Using $x=\frac{\pi}{n}$ it follows indeed that

$$\begin{equation}
\underset{n\rightarrow\infty}{lim}n.b(n)=2\pi\label{eq:6}
\end{equation}$$

In other words the perimeter of successive polygons inscribed in a unit
circle does approach $2\pi$ -- which of course comes hardly as a surprise.

The following code implements this starting from a polygon with a given number of sides $n$ . The argument $h$ is half of the length of the side, and $n_{max}$ is the number of iterations. What the algorithm does is recursively creating polygons with $n, 2n, 4n, 8n, ... $ sides. The example starts from a triangle so $n=3$ and $h=\sqrt(3)/2$.
<br>
<br>

<code style="font-size:80%">
      -- n: # sides of the polygon<br>
      -- h: half of the length of a side<br>
<br>
      approx_pi n h n_max<br>
        | n == n_max = n*h<br>
        | otherwise =<br>
            approx_pi (2*n) (sqrt ((1 - sqrt (1-h*h) )/2)) n_max<br>
      -- e.g starting from a triangle.<br>
      main = print $ approx_pi 3 ((sqrt 3)/2) (3*2**14)<br>
<br>
</code>
<br>

What I find interesting is that every prime polygon produces a different series but they all converge towards $\pi$.
<br>

<figure>
</figure>


## Part 2 How to construct a pentagon using a compass and a ruler

People have worked out [how to construct a pentagon using only a compass
and a ruler](https://en.wikipedia.org/wiki/Pentagon) long ago. Nevertheless, I wanted to derive the construction
from first principles.


<figure>
<img src="{{ site.url }}/images/pentagon-relationships.png" width="80%"  alt="Relationships in a pentagon" id="fig:Relationships-in-a" />
<figcaption>Figure 2. Relationships in a pentagon</figcaption>
</figure>

### The length of a side of a pentagon

From [Figure 2](#fig:Relationships-in-a) we can write down some
straightforward relationships between the length of a side of a pentagon
(*b* from the previous part) and the angle of the arc, $\frac{2\pi}{5}$.

$$\begin{equation}
x=\frac{b}{2}=sin\frac{\pi}{5}\label{eq:2.1}
\end{equation}$$

$$\begin{equation}
y=cos\frac{\pi}{5}\label{eq:2.2}
\end{equation}$$

$$\begin{equation}
x^{2}+y^{2}=1\label{eq:2.3}
\end{equation}$$

$$\begin{equation}
q = 2sin\frac{2\pi}{5}=4sin\frac{\pi}{5}cos\frac{\pi}{5}\label{eq:2.4}\end{equation}$$

Substitution of Eqs. $\ref{eq:2.1}$ and $\ref{eq:2.2}$ gives

$$\begin{equation}
q = 4xy\label{eq:2.5}\end{equation}$$

Now we consider the right triangle with hypothenuse *q*:

$$\begin{equation}
q^{2} = x^{2}+(1+y)^{2}\label{eq:2.6}\end{equation}$$

Substitution of Eq. $\ref{eq:2.3}$ in the RHS of Eq. $\ref{eq:2.6}$ and refactoring gives:

$$\begin{equation}
q^{2} = 2+2y\label{eq:2.7}\end{equation}$$

Substitution of Eq. $\ref{eq:2.3}$ and Eq. $\ref{eq:2.5}$ in the LHS of Eq. $\ref{eq:2.7}$ and refactoring gives:

$$\begin{equation}
(4-(2y)^{2})(2y)^{2} = 2+2y\label{eq:2.8}\end{equation}$$

Now we define $z=2y$ and rewrite Eq. $\ref{eq:2.8}$ as:

$$\begin{equation}
(4-z^{2}).z^{2}=2+z\label{eq:2.9}
\end{equation}$$

Which after more refactoring finally gives

$$\begin{equation}
z^{2}(2-z)-1=0\label{eq:2.10}
\end{equation}$$

This is a third-order equation but fortunately there is an obvious root
for $z=1$. After some factorization we obtain the remaining second-order
equation:

$$\begin{equation}
z^{2}-z-1=0\label{eq:2.11}
\end{equation}$$

The roots of this equation are:

$$\begin{align}
z & = & \frac{1\pm\sqrt{(-1)^{2}-4.1.(-1)}}{2.1}\label{eq:2.12}\\
 & = & \frac{1\pm\sqrt{5}}{2}\nonumber \end{align}$$

This is actually a very famous equation and its positive root is known as the [Golden ratio](https://en.wikipedia.org/wiki/Golden_ratio).

$$\begin{align}
\phi & = & \frac{1}{a} & = & \frac{a}{1-a}\label{eq:goldenratio}
\end{align}$$

Clearly *y* as defined is positive so $y=\frac{z}{2}=\frac{\phi}{2}$ or

$$\begin{equation}
y=\frac{1+\sqrt{5}}{4}\label{eq:2.13}
\end{equation}$$


From Eq. $\ref{eq:2.13}$ we can express *b* in terms of *y* using Eqns
$\ref{eq:2.1}$, $\ref{eq:2.2}$ and $\ref{eq:2.3}$:

$$\begin{equation}
b=2\sqrt{1-y^{2}}\label{eq:2.14}
\end{equation}$$

And so we obtain the expression for the length of the side of a pentagon
as

$$\begin{equation}
b=\sqrt{\frac{5-\sqrt{5}}{2}}\label{eq:2.15}
\end{equation}$$

### Construction of the pentagon

The remaining question is then, how do we construct a line of length *b*
using a rules and compass?

We do this indirectly, by constructing a line
of length *y* as shown in [Figure 3](#fig:Construction-of-a). First, we
construct a line of length 1/2. Then the hypothenuse of the right
triangle with sides 1/2 and 1 has a lenght of $\frac{\sqrt{5}}{2}$. We
add this to the 1/2 by drawing an arc of radius $\frac{\sqrt{5}}{2}$
using the compass. This way we get a line of length
$\phi = \frac{1+\sqrt{5}}{2}$. Dividing this into two gives *y* and through the
way we constructed this, we immediately get *b* as well and so we can
construct the pentagon using arcs of radius *b*.

<figure>
<img src="{{ site.url }}/images/pentagon-construction.png" alt="Construction of a regular pentagon using ruler and compass" id="fig:Construction-of-a" />
<figcaption>Figure 3. Construction of a regular pentagon using ruler and compass</figcaption>
</figure>


### A hidden triangle

The equation we solved to obtain *y* ([Eq. $\ref{eq:2.10}$](#eq:2.11)) is a third order equation, and
its other positive root is $z=1$. This shows in a way the danger of transforming a geometry problem into algebra:
only one of these roots, $z=\phi$, corresponds to a solution of our geometric problem.

But there is also a geometric interpretation for the root $z=1$. Substitution of $y=1/2$ in the equations for  results in $q=\sqrt{3}$ and $b=\sqrt{3}$,
in other words a regular triangle inscribed in the unit circle.

<figure>
<img src="{{ site.url }}/images/triangle-relationships.png" width="70%" alt="Relationships in a triangle" id="fig:Relationships-in-a" />
<figcaption>Figure 4. Relationships in a triangle</figcaption>
</figure>
