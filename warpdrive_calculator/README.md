# Warp Drive Calculator

## intro . .

The **Warp Drive Calculator** is a Bash script that calculates hypothetical warp travel times between star systems using real astronomical data and Star Trek warp speed formulas. select famous starships, origin and destination stars (including iconic locations from the Star Trek universe), and calculates the estimated travel time at a chosen warp factor.

## features. . .

- **Starship Selection:** Choose from various iconic Starfleet vessels, each with unique maximum warp capabilities.
- **Star and Planet Database:** Includes real stars along with famous locations from the Star Trek universe, complete with astronomical facts and lore.
- **Warp Speed Calculations:** Uses the Star Trek: The Next Generation warp speed scale to compute velocities.
- **Distance Calculations:** Calculates distances between stars using their celestial coordinates and real astronomical data.
- **Immersive Experience:** Provides mission briefings and summaries, integrating Star Trek lore into the calculations.

## install . .

#### installing `bc`

```bash
sudo pacman -S bc
```

### downloading the Script

Clone the repository or download the script directly:

```bash
git clone https://github.com/getjared/bash.git
cd bash/warpdrive_calculator
```

### making the script executable

```bash
chmod +x wdc.sh
```

## using it. .

Run the script from the terminal:

```bash
./wdc.sh
```

Follow the prompts:

1. **Select a Starship:** Choose your vessel from the list provided.
2. **Select Origin Star:** Choose your starting point.
3. **Select Destination Star:** Choose your destination.
4. **Enter Warp Factor:** Input a warp factor up to the maximum allowed by your chosen starship.

### example Session

```plaintext
Welcome to the Warp Drive Calculator!
This tool calculates hypothetical warp travel times between star systems using real astronomical data.

Mission Briefing:
You are tasked with navigating a starship between two points in the galaxy. Choose your vessel and set your course!

Available Starships:
  [1] USS Enterprise-D
  [2] USS Voyager
  [3] USS Defiant
  [4] USS Enterprise
  [5] USS Discovery

Select your starship by number: 1

Available Stars and Planets:
  [1] Earth
  [2] Alpha Centauri
  [3] Vulcan
  [4] Qo'noS
  [5] Romulus
  [6] Bajor

Select your origin star by number: 1

Available Stars and Planets:
  [1] Earth
  [2] Alpha Centauri
  [3] Vulcan
  [4] Qo'noS
  [5] Romulus
  [6] Bajor

Select your destination star by number: 3

Maximum Warp Factor for USS Enterprise-D (Galaxy class): 9.6
Enter warp factor (up to maximum warp): 9.6

Mission Summary:
Starship: USS Enterprise-D (Galaxy class)
  Maximum Warp: 9.6
  Notes: Flagship of the Federation in the 24th century.

Calculating travel time from Earth to Vulcan at Warp 9.6...
------------------------------------------------------------
Origin Star: Earth
  Distance from Earth: 0 light-years
  Right Ascension: 0h0m0s
  Declination: 0°0′0″
  Spectral Type: G2V
  Mass: 1.0 Solar Masses
  Radius: 1.0 Solar Radii
  Astronomical Facts: Our home planet, the third planet from the Sun.
  Star Trek Lore: Birthplace of humanity and headquarters of the United Federation of Planets.

Destination Star: Vulcan
  Distance from Earth: 16.5 light-years
  Right Ascension: 12h30m49.42338s
  Declination: +12°23′28.0439″
  Spectral Type: K-class
  Mass: 0.81 Solar Masses
  Radius: 0.76 Solar Radii
  Astronomical Facts: Hypothetical location near 40 Eridani A.
  Star Trek Lore: Homeworld of the Vulcans, Spock's species.

Angular Separation: 187.7458514 degrees
Distance between stars: 16.5000 light-years
Distance in kilometers: 1.56e+14 km
Warp Factor: 9.6
Warp Speed: 4.39e+08 km/s

Estimated Travel Time:
  0.11 years
------------------------------------------------------------
Note: This calculation uses the Star Trek: The Next Generation warp speed scale.
For warp factors above 9, speeds increase exponentially toward Warp 10, which is infinite velocity.

Additional Information:
  - Speed of Light: 299792.458 km/s
  - 1 Light-Year: 9460730472580.8 km
  - Warp Speed Formula: Based on the TNG Technical Manual
  - Spectral Types indicate the star's temperature and color.
  - Solar Masses and Radii are relative to our Sun.
```

## the math. . <3

### warp ppeed calculations

The warp speed calculations are based on the **Star Trek: The Next Generation Technical Manual**, which provides a warp factor scale that defines the relationship between warp factors and multiples of the speed of light.

#### formula for warp factors up to 9

For warp factors **W** between 0 and 9:

\[
v = W^{\frac{10}{3}} \times c
\]

Where:
- \( v \) = velocity in km/s
- \( W \) = warp factor
- \( c \) = speed of light (\( \approx 299,792.458 \) km/s)

To handle fractional exponents in the script, we use logarithms and exponentials:

\[
v = e^{\left( \frac{10}{3} \times \ln W \right)} \times c
\]

#### formula for warp factors Above 9

For warp factors above 9, speeds increase exponentially toward Warp 10 (infinite velocity):

\[
v = e^{W} \times c
\]

### distance calculations

The distance between two stars is calculated using their **right ascension** (RA) and **declination** (Dec) coordinates, converted into decimal degrees and then into radians.

#### steps:

1. **convert sexagesimal coordinates to decimal degrees:**

   - Right Ascension (RA):
     \[
     \text{RA}_{\text{deg}} = (H + \frac{M}{60} + \frac{S}{3600}) \times 15
     \]
     Where \( H \) = hours, \( M \) = minutes, \( S \) = seconds.

   - Declination (Dec):
     \[
     \text{Dec}_{\text{deg}} = D + \frac{M}{60} + \frac{S}{3600}
     \]
     Where \( D \) = degrees, \( M \) = arcminutes, \( S \) = arcseconds.

2. **convert degrees to radians:**

   \[
   \theta_{\text{rad}} = \theta_{\text{deg}} \times \left( \frac{\pi}{180} \right)
   \]

3. **calculate angular separation (\( \phi \)) Using the spherical law of cosines:**

   \[
   \cos \phi = \sin \delta_1 \sin \delta_2 + \cos \delta_1 \cos \delta_2 \cos(\alpha_1 - \alpha_2)
   \]
   Where:
   - \( \delta_1, \delta_2 \) = declinations in radians
   - \( \alpha_1, \alpha_2 \) = right ascensions in radians

   Ensure \( \cos \phi \) is within the range \([-1, 1]\) to avoid mathematical errors due to floating-point inaccuracies.

   Calculate \( \phi \) using the arccosine function.

4. **calculate the distance between stars using the law of cosines:**

   \[
   d = \sqrt{d_1^2 + d_2^2 - 2 d_1 d_2 \cos \phi}
   \]
   Where:
   - \( d \) = distance between stars
   - \( d_1, d_2 \) = distances from Earth to each star

#### converting distance to kilometers

1 Light-Year (\( \text{LY} \)) is approximately \( 9.4607304725808 \times 10^{12} \) km.

\[
\text{Distance}_{\text{km}} = d_{\text{LY}} \times 9.4607304725808 \times 10^{12}
\]

#### calculating travel time

\[
\text{Travel Time (s)} = \frac{\text{Distance}_{\text{km}}}{v}
\]

Convert travel time to desired units (years, days, hours):

- **years:**
  \[
  \text{Travel Time (yr)} = \frac{\text{Travel Time (s)}}{31557600}
  \]
- **days:**
  \[
  \text{Travel Time (day)} = \frac{\text{Travel Time (s)}}{86400}
  \]
- **hours:**
  \[
  \text{Travel Time (hr)} = \frac{\text{Travel Time (s)}}{3600}
  \]

## included data

### stars and planets

includes a list of stars and planets with the following information:

- **Name**
- **Distance from Earth** (light-years)
- **Right Ascension** (sexagesimal)
- **Declination** (sexagesimal)
- **Spectral Type**
- **Mass** (Solar Masses)
- **Radius** (Solar Radii)
- **Astronomical Facts**
- **Star Trek Lore**

notable entries include:

- **Earth**
- **Alpha Centauri**
- **Vulcan**
- **Qo'noS**
- **Romulus**
- **Bajor**

### starships

Available starships for selection:

- **USS Enterprise-D** (Galaxy class)
- **USS Voyager** (Intrepid class)
- **USS Defiant** (Defiant class)
- **USS Enterprise** (Constitution class)
- **USS Discovery** (Crossfield class)

Each ship includes:

- **Name**
- **Class**
- **Maximum Warp Factor**
- **Notes**

## examples

### calculating travel time from earth to vulcan at warp 9.6

Using the **USS Enterprise-D** (Galaxy class) with a maximum warp factor of **9.6**.

#### Input:

- **Origin:** Earth
- **Destination:** Vulcan
- **Warp Factor:** 9.6

#### Output:

- **Distance between stars:** 16.5 light-years
- **Warp Speed:** \( 4.39 \times 10^8 \) km/s
- **Estimated Travel Time:** 0.11 years (approximately 40 days)

### Calculating Travel Time from Earth to Vega at Warp 3

Using the **USS Enterprise-D** (Galaxy class) with a maximum warp factor of **9.6**.

#### Input:

- **Origin:** Earth
- **Destination:** Vega
- **Warp Factor:** 3

#### Output:

- **Distance between stars:** 25.04 light-years
- **Warp Speed:** \( 1.17 \times 10^7 \) km/s
- **Estimated Travel Time:** 0.64 years (approximately 234 days)


## acknowledgments. .

- **Gene Roddenberry:** For creating the Star Trek universe that continues to inspire exploration and imagination.
- **NASA and ESA:** For providing astronomical data and resources that make tools like this possible.
- **The Open-Source Community:** For tools, resources, and collaborative efforts that support projects like this.

**Live long and prosper!**
