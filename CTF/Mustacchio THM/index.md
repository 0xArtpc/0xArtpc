# Mustacchio

Description: XXE Vulnerability that allow us to get the id_rsa key and login to the server, inside the server there was a SUID file running, by manipulating the PATH var it gave us ROOT

# Recon

## Port scanning

`nmap -sCV -oN nmap 10.10.169.41`

![Untitled](images/Untitled.png)

Before we start exploring the webpage let’s add mustacchio to our `/etc/hosts`

![Untitled](images/Untitled%201.png)

## Web

Now that we are doing web recon let’s open our burp suite and make some requests.

### Setting up Burp

Start a new project

Put the URL inside the scope that we are attacking

![Untitled](images/Untitled%202.png)

Here we are filtering the HTTP history of our burp suite to only show in-scope items

![Untitled](images/Untitled%203.png)

### Exploring the website

As we are looking at the source code we find this strange directory

![Untitled](images/Untitled%204.png)

Found a file named users.bak

![Untitled](images/Untitled%205.png)

### SQL credentials

![Untitled](images/Untitled%206.png)

Finding the hash using `haiti`

![Untitled](images/Untitled%207.png)

Decoding the password

`john hash --format=raw-sha1 --wordlist=/usr/share/wordlists/rockyou.txt`

![Untitled](images/Untitled%208.png)

We tried to do ssh login using the credentials but we got premisson denied from the server

I did more recon and found this

![Untitled](images/Untitled%209.png)

### Web ( port 8765 )

Now we have an admin panel

After we login we get this page

![Untitled](images/Untitled%2010.png)

As we are searching more things on the page we find this message

![Untitled](images/Untitled%2011.png)

That key maybe he is reffering to that file above “`dontforget.bak`”

When we enter to that link we download the file and now there is a entry point

![Untitled](images/Untitled%2012.png)

When we inspect the text area we can see the `ID` and its named as `BOX` so with this we can inject XML here

![Untitled](images/Untitled%2013.png)

## Exploiting web (8765)

So now we know that we can inject XML inside this textarea lets put a random string to check how it reacts

![Untitled](images/Untitled%2014.png)

We have this `xml` parameter

![Untitled](images/Untitled%2015.png)

Now lets try to add a comment, using the `dontforget.bak` file we can get the XML structure,

![Untitled](images/Untitled%2016.png)

### Escalating XXE

By putting this payload

![Untitled](images/Untitled%2017.png)

We get `/etc/passwd` file but we need more than that

![Untitled](images/Untitled%2018.png)

### Getting the SSH key

We know there is a user named `barry` so lets get the ssh key

![Untitled](images/Untitled%2019.png)

![Untitled](images/Untitled%2020.png)

Now we save it to a file and use `ssh2john` to make a hash and after we decode it

### Decoding

I downloaded `ssh2john` using `wget https://raw.githubusercontent.com/magnumripper/JohnTheRipper/bleeding-jumbo/run/ssh2john.py`

![Untitled](images/Untitled%2021.png)

Now we can run it `python ssh2john.py /home/zodiac/thm/mustacchio/id_rsa > id_rsa.hash`

And we get the `id_rsa.hash` now we send it to `john`

![Untitled](images/Untitled%2022.png)

Now we connect using the key and the passphrase with ssh

`ssh -i id_rsa barry@mustacchio.thm`

![Untitled](images/Untitled%2023.png)

First flag

![Untitled](images/Untitled%2024.png)

# Privilege Escalation

## Recon

### Linux version

`uname -a`

Linux mustacchio 4.4.0-210-generic

Interesting file found by `find / -type f -perm -4000 2>/dev/null`

![Untitled](images/Untitled%2025.png)

### Exploitation

Read the file `strings live_log`

![Untitled](images/Untitled%2026.png)

The script is using `tail`, so we can manipulate the `tail`

Go to `/tmp` and create a script named as `tail`

Put this code, this will copy  the bash and send to our `/tmp` directory and changes the permissions

![Untitled](images/Untitled%2027.png)

Now we change the PATH variable so it runs our `tail` script

![Untitled](images/Untitled%2028.png)

Make it executable and run the `live_log`

![Untitled](images/Untitled%2029.png)

`bash -p`

![Untitled](images/Untitled%2030.png)

### Root Flag

![Untitled](images/Untitled%2031.png)
