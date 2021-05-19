# ShowOpenConnections
A simple bash script to show open connections for a process

## Disclaimer
The motivation for writing this script is troubleshooting during customer support sessions with a limited access to the internet.
If there are no limitations it is recommended to use Linux utilities like lsof or ss.

## How it works
Scans /proc/pid/fd and tries to associate each socket fd with  a line in /proc/net/tcp or /proc/net/tcp6.

## Usage
```
./showOpenConn.sh pid
```

The output is given as:
```
SocketNumber IP:Port
```

## It does not handle the cases of

* Socket types other than tcp and tcp6.
* Listening connections.

In case socket not found in tcp or tcp6 IP:Port will be omitted.
