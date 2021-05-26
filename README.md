# Vulnimiser

This is a simple script that can help you exploit some really knowed exploits to become the root user (Privilege escalation)

## How to use
1 - Download a binary from the releases tab
2 - Send it to your vulnerable machine
3 - Give it the execute permission using `chmod +x analyser`
4 - Run it with `./analyser`

## How to build
### Imports
 - strformat
 - os
 - strutils
 - osproc

1 - Clone the repo `git clone https://github.com/0x454d505459/vulnimiser.git`
2 - Change directory with `cd vulnimiser`
3 - Use Nim to build it `nim c analyser.nim`

## Disclaimer
Please be aware that this require a minimum acces on the machine.

## Contributing
If you know any other exploit that can give privileged access please create a new issue, if you know you how to implement crontab also create an issue

## Other usages
This can also be used as a privilege maintainer if you run it with privileges
