# warp drive calculator

## introduction

the warp drive calculator is a bash script that calculates hypothetical warp travel times between star systems using real astronomical data and star trek warp speed formulas.

it allows you to select a starship, an origin star, and a destination star (including famous locations from the star trek universe), and calculates the estimated travel time at a chosen warp factor.

## features

- **starship selection:** choose from various star trek starships, each with a unique maximum warp factor
- **real astronomical data:** includes real stars along with star trek locations, complete with astronomical facts and lore
- **warp speed calculations:** uses the star trek: the next generation warp speed scale to compute velocities
- **distance calculations:** computes distances between stars using their celestial coordinates

## usage

run the script:

```bash
./wdc.sh
```

follow the prompts:

1. select a starship
2. select your origin star
3. select your destination star
4. enter a warp factor (up to the ship's maximum warp)

## mathematical background

### warp speed calculations

the warp speed is calculated based on the warp factor \( w \) using the following formulas from the star trek: the next generation technical manual.

for warp factors \( w \leq 9 \):

\[
v = w^{\frac{10}{3}} \times c
\]

for warp factors \( w > 9 \):

\[
v = e^{w} \times c
\]

where:

- \( v \) is the velocity in km/s
- \( c \) is the speed of light (\( \approx 299,792.458 \) km/s)
- \( e \) is the base of the natural logarithm

since bash and `bc` have limitations with fractional exponents, the script uses logarithms and exponentials for calculation:

\[
v = e^{\left( \frac{10}{3} \times \ln w \right)} \times c
\]

### distance calculations

the distance between two stars is calculated using their right ascension (\( \alpha \)) and declination (\( \delta \)) coordinates.

1. **convert coordinates to decimal degrees**

- right ascension (in hours, minutes, seconds):

\[
\alpha_{\text{deg}} = (h + \frac{m}{60} + \frac{s}{3600}) \times 15
\]

- declination (in degrees, arcminutes, arcseconds):

\[
\delta_{\text{deg}} = d + \frac{m}{60} + \frac{s}{3600}
\]

2. **convert degrees to radians**

\[
\theta_{\text{rad}} = \theta_{\text{deg}} \times \left( \frac{\pi}{180} \right)
\]

3. **calculate angular separation (\( \phi \)) using the spherical law of cosines**

\[
\cos \phi = \sin \delta_1 \sin \delta_2 + \cos \delta_1 \cos \delta_2 \cos(\alpha_1 - \alpha_2)
\]

ensure that \(\cos \phi\) is within \([-1, 1]\) due to floating-point inaccuracies.

calculate \(\phi\) using the arccosine function:

\[
\phi = \arccos(\cos \phi)
\]

4. **calculate the distance between stars**

if \( d_1 \) and \( d_2 \) are the distances from earth to each star:

\[
d = \sqrt{d_1^2 + d_2^2 - 2 d_1 d_2 \cos \phi}
\]

5. **convert distance to kilometers**

since 1 light-year \( \approx 9.4607304725808 \times 10^{12} \) km:

\[
\text{distance}_{\text{km}} = d_{\text{ly}} \times 9.4607304725808 \times 10^{12}
\]

### travel time calculation

the travel time is calculated as:

\[
\text{travel time (s)} = \frac{\text{distance}_{\text{km}}}{v}
\]

convert the travel time to years, days, or hours as appropriate:

Years:
travel time (years)=travel time (s)31,557,600
travel time (years)=31,557,600travel time (s)​

Days:
travel time (days)=travel time (s)86,400
travel time (days)=86,400travel time (s)​

Hours:
travel time (hours)=travel time (s)3,600
travel time (hours)=3,600travel time (s)​

## example

calculating travel time from earth to vega at warp 3 using the uss enterprise-d (galaxy class, max warp 9.6):

- **origin:** earth
- **destination:** vega
- **warp factor:** 3

**output:**

- distance between stars: approximately 25.04 light-years
- warp speed: approximately \( 1.17 \times 10^7 \) km/s
- estimated travel time: approximately 0.64 years (about 234 days)


## acknowledgments

- gene roddenberry for creating the star trek universe
- nasa and esa for astronomical data

---
