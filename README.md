# p6-net-rcon

`Net::RCON` is a Perl 6 module for interacting with the Source RCON (remote console) protocol. Built on top of [`IO::Socket::INET`](https://docs.perl6.org/type/IO::Socket::INET), it allows server administrators to issue and recieve the results of commands executed against RCON-compatiable servers.


## Installation

### ... from zef

```
zef install Net::RCON
```

### ... from source

```
git clone https://github.com/shuppet/p6-net-rcon
cd p6-net-rcon/ && zef install ${PWD}
```
