
# spacecraft tracker

a bash script to track the status and position of various spacecraft, including the iss, voyager 1 and 2, new horizons, curiosity rover, and james webb space telescope.

## features

- **iss status:** real-time latitude and longitude, altitude, velocity, and last update time
- **voyager 1 & 2:** calculates distance from earth in au and km based on launch date and average speed
- **new horizons:** shows distance from earth in au and km
- **james webb space telescope:** displays fixed position at l2 point
- **curiosity rover:** retrieves mission status, landing date, current martian sol, and total photos taken using nasa api

## prerequisites

ensure the following utilities are installed:

- `jq`
- `bc`
- `curl`
- `date`

on arch linux . .

```bash
sudo pacman -S jq bc curl coreutils
```

## installation

clone the repository:

```bash
git clone https://github.com/getjared/fsst.git
```

navigate to the directory:

```bash
cd bash/fsst
```

make the script executable:

```bash
chmod +x fsst.sh
```

## usage

run the script:

```bash
./fsst.sh
```

## configuration

to get the curiosity rover status, you need a nasa api key. replace the `API_KEY` variable in the script with your key.

you can obtain an api key from [nasa api](https://api.nasa.gov/)
