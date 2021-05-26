# Vulnimiser

This is a simple script that can help you exploit some really knowed exploits to become the root user (Privilege escalation)

## How to use
 - Download a binary from the releases tab
 - Send it to your vulnerable machine
 - Give it the execute permission using `chmod +x analyser`
 - Run it with `./analyser`

## How to build
### Imports
 - strformat
 - os
 - strutils
 - osproc
### Building
 - Clone the repo `git clone https://github.com/0x454d505459/vulnimiser.git`
 - Change directory with `cd vulnimiser`
 - Use Nim to build it `nim c analyser.nim`

## Disclaimer
Please be aware that this require a minimum acces on the machine.

## Contributing
If you know any other exploit that can give privileged access please create a new issue, if you know how to implement crontab also create an issue

## Other usages
This can also be used as a privilege maintainer if you run it with privileges

## Knowed Issues
 - TryHackMe VMs lacks a C binder so the script can't run
