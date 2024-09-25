# Warp Drive Calculator

a script that calculates hypothetical warp travel times between star systems using real astronomical data and Star Trek warp speed formulas. 

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [The Science and Fiction Behind the Calculator](#the-science-and-fiction-behind-the-calculator)
  - [Real Astronomical Data](#real-astronomical-data)
  - [Warp Speed Formulas](#warp-speed-formulas)
  - [Distance Calculations](#distance-calculations)
  - [Time Dilation and Relativistic Effects](#time-dilation-and-relativistic-effects)
- [Star Data](#star-data)

## Features

- Calculates travel times between various real star systems
- Uses actual astronomical data for star positions and properties
- Implements Star Trek: The Next Generation warp speed formulas
- Provides detailed output with star information and travel statistics
- Converts between different coordinate systems and units
- Calculates angular separation and true distance between stars
- Handles time formatting for various scales (years, days, hours)

## Prerequisites

This script requires `bc` (basic calculator) to be installed on your system. Most Unix-like systems come with `bc` pre-installed.

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/getjared/bash.git
   ```
2. Navigate to the project directory:
   ```
   cd bash/warpdrive_calculator
   ```
3. Make the script executable:
   ```
   chmod +x wdc.sh
   ```

## Usage

Run the script:
```
./wdc.sh
```

Follow the prompts to:
1. Select an origin star
2. Select a destination star
3. Enter a warp factor (between 1 and 9.99)

The calculator will then display detailed information about both stars and the calculated travel time.

## The Science and Fiction Behind the Calculator

### Real Astronomical Data

The calculator uses real astronomical data for stars, including:
- Distance from Earth (in light-years)
- Right Ascension and Declination (celestial coordinates)
- Spectral Type
- Mass (in Solar masses)
- Radius (in Solar radii)

This data allows for accurate positioning of stars in 3D space and provides interesting astrophysical context.

### Warp Speed Formulas

The warp speed calculations are based on formulas from Star Trek: The Next Generation Technical Manual:

- For warp factors < 9:
  ```
  velocity = warp_factor^3 * c
  ```
- For warp factors ≥ 9:
  ```
  velocity = ((10/3) * warp_factor - 70/3) * c
  ```
Where `c` is the speed of light (299,792.458 km/s).

These formulas create an exponential increase in speed as the warp factor approaches 10 (which represents infinite velocity).

### Distance Calculations

The script calculates the true distance between stars using their 3D positions in space:

1. Convert Right Ascension (RA) and Declination (Dec) to radians.
2. Calculate the angular separation using the spherical law of cosines:
   ```
   cos(angle) = sin(dec1) * sin(dec2) + cos(dec1) * cos(dec2) * cos(ra1 - ra2)
   ```
3. Use the law of cosines to find the true distance:
   ```
   distance = sqrt(d1^2 + d2^2 - 2 * d1 * d2 * cos(angle))
   ```
   Where d1 and d2 are the distances of the stars from Earth.

### Time Dilation and Relativistic Effects

Note that this calculator does not account for relativistic effects such as time dilation. In reality, travel at speeds approaching or exceeding the speed of light would involve significant relativistic effects. The Star Trek universe assumes the existence of subspace, which allows for faster-than-light travel without the typical relativistic consequences.

## Star Data

Current celestial objects:
- Earth
- Alpha Centauri
- Barnard's Star
- Sirius
- Epsilon Eridani
- Vega
- Betelgeuse
- Proxima Centauri
- Rigel
- Polaris
- Altair

Each star's entry includes its name, distance from Earth, coordinates, spectral type, mass, and radius.

---
