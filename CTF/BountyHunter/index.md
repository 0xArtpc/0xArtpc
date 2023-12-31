# BountyHunter

# Recon

## PortScan

`nmap -sCV -T4 -oN nmap 10.10.11.100`

![Untitled](images/Untitled.png)

Lets add the IP to our hosts file

`echo -e "10.10.11.100\tbounty.htb" >> /etc/hosts`

## Web

### Source Code

Found the page `mail/contact_me.php`

![Untitled](images/Untitled%201.png)

### Bounty Report System

After sending a random report we capture it inside BurpSuite and there is a base64 value

![Untitled](images/Untitled%202.png)

Base64 code

![Untitled](images/Untitled%203.png)

When we decode there is some `XML` code so maybe some `XXE` vulnerability

![Untitled](images/Untitled%204.png)

### XXE with LFI

Now we know that there is XML so we try to manipulate the data parameter, copy the valid code and lets make some changes, in this case i want to get the passwd file

![Untitled](images/Untitled%205.png)

Put that code on the data parameter and send

![Untitled](images/Untitled%206.png)

### PHP Wrapper

Now we want to read PHP files, there was a `db.php` file and to read it we used a php wrapper with XXE

`<!ENTITY x SYSTEM "php://filter/convert.base64-encode/resource=db.php">`

![Untitled](images/Untitled%207.png)

After encode it the same way send it and you should see something like this

![Untitled](images/Untitled%208.png)

Now when we decode it as base64 we get the contents of the file

![Untitled](images/Untitled%209.png)

`dbname = "bounty";
username = "admin";
password = "m19RoAU0hP41A1sTsq6K";`

## Privilege Escalation

### SSH

We cloud read the `passwd` file earlier and we found user `development` and `root`, now that we have the password lets connect as user development

`ssh development@bounty.htb`

![Untitled](images/Untitled%2010.png)

### Internal Tool

![Untitled](images/Untitled%2011.png)

Running the tool

`python3 [ticketValidator.py](http://ticketvalidator.py/)`

`invalid_tickets/390681613.md`

![Untitled](images/Untitled%2012.png)

What we can run as root

`sudo -l`

![Untitled](images/Untitled%2013.png)

`sudo /usr/bin/python3.8 /opt/skytrain_inc/ticketValidator.py`

After some time playing around with the python script found this line to get pass inside the `eval function`

![Untitled](images/Untitled%2014.png)

On the ticket file we need to set this value to 11 so 11/7 gives a remainder of 4 and that if gonna be true and we are getting the function eval

To test for it i just did this `import date`

![Untitled](images/Untitled%2015.png)

And we get the date it means the python is reading our code

![Untitled](images/Untitled%2016.png)

Now lets create a new `.md` file inside the target machine

`touch /tmp/test.md`

`vi /tmp/test.md`

![Untitled](images/Untitled%2017.png)

And now we are `root` user

![Untitled](images/Untitled%2018.png)
