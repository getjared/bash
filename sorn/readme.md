
# sauron: a minimal bash irc client

sauron is a super minimal irc client written in bash without external dependencies. it's named after the all-seeing eye from the lord of the rings.

## features

- connects to irc servers and channels
- sends and receives messages
- supports basic irc commands (/join, /msg, /quit)
- colorful terminal output for enhanced readability
- no external dependencies - runs with just bash
- customizable server, port, nickname, username, and channel

## requirements

- bash shell (version 4.0 or higher recommended)
- a working internet connection

## installation

1. clone this repository or download the `sauron.sh` script.
2. make the script executable:
   ```
   chmod +x sauron.sh
   ```

## usage

run the script with optional parameters:

```
./sauron.sh [-s server] [-p port] [-n nickname] [-u username] [-r realname] [-c channel]
```

if no parameters are provided, default values will be used.

### command-line options

- `-s`: irc server (default: irc.libera.chat)
- `-p`: irc port (default: 6667)
- `-n`: nickname (default: sauronBot)
- `-u`: username (default: sauron)
- `-r`: real name (default: Bash IRC Client)
- `-c`: channel to join (default: #bash)

### in-client commands

- `/quit`: exit the client
- `/join #channel`: join a new channel
- `/msg user message`: send a private message to a user

regular text input will be sent as a message to the current channel.

## example

connect to the default server and channel:

```
./sauron.sh
```

connect to a specific server and channel:
make sure you add the "" around the channel name.

```
./sauron.sh -s irc.example.com -c yourname "#mychannel"
bash sauron.sh -s irc.libera.chat -p 6667 -n getjared -c "#bash"
```

## note

this is a minimal irc client intended for basic usage and learning purposes. it may not support all irc features or have robust error handling. use at your own discretion, and remember the only real security you need to worry about is the patch for human stupidity.
