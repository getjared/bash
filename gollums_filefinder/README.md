# gollum's file finder (gff.sh)

a gollum-themed bash script for system-wide file searching with colorful output. (it's pretty pointless but i use it ;p)

## features

- case-insensitive file search across the entire system
- gollum-inspired dialogue during the search process
- colorful terminal output for enhanced readability
- simple and user-friendly interface

## requirements

- bash shell
- sudo privileges (for system-wide search)

## installation

1. clone this repository or download the `gff.sh` script.
2. make the script executable:
   ```
   chmod +x gff.sh
   ```

## usage

run the script with sudo:

```
sudo ./gff.sh [filename]
```

works best if you throw an alias into your bashrc file
```
alias g='sudo /.gff.sh [filename]'
```

if no filename is provided, you will be prompted to enter one.

## examples

search for a file named "myfile.txt":
```
sudo ./gff.sh myfile.txt
```

search for a file with mixed case:
```
sudo ./gff.sh MyFiLe.TxT
```

## note

this script requires sudo privileges to search the entire file system. always be cautious when running scripts with elevated permissions.
