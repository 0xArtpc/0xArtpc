import pyfiglet
import sys
import socket
import requests
from datetime import datetime
import re
import urllib.parse
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

# Function to send email
def send_email(sender_email, sender_password, receiver_email, subject, message, attachment_filename):
    message_body = MIMEMultipart()
    message_body['From'] = sender_email
    message_body['To'] = receiver_email
    message_body['Subject'] = subject

    message_body.attach(MIMEText(message, 'plain'))

    # Attaching the specified file to the email
    with open(attachment_filename, "rb") as attachment:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(attachment.read())
    encoders.encode_base64(part)
    part.add_header("Content-Disposition", f"attachment; filename= {attachment_filename}")
    message_body.attach(part)

    # Configuring SMTP server and sending the email
    smtp_server = smtplib.SMTP('smtp-mail.outlook.com', 587)
    smtp_server.starttls()
    smtp_server.login(sender_email, sender_password)
    smtp_server.sendmail(sender_email, receiver_email, message_body.as_string())
    smtp_server.quit()

# Generating ASCII art text for the tool name
ascii_banner = pyfiglet.figlet_format("VulnScanner")
print(ascii_banner)

# Checking the number of command-line arguments
if len(sys.argv) == 2:
    # Resolving the IP address of the target host
    target = socket.gethostbyname(sys.argv[1])
else:
    print("Usage: vulnscanner.py <IP>")
    sys.exit()

# Displaying scanning information
print("-" * 50)
print("Scanning Target: " + target)
print("Scanning started at:" + str(datetime.now()))
print("-" * 50)

# Opening/creating a file for writing scan results
with open("vulnscanner-out.txt", "a") as f:
    f.write(f"\nTarget IP {target}\n-----------------------------\n")
    banners = {}

    try:
        # Scanning ports for potential vulnerabilities
        for port in range(1, 100):
            # Making the TCP connection
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(1)
            result = s.connect_ex((target, port))
            if result == 0:
                # Sending a GET Request
                s.send(b'GET / HTTP/1.1\r\nHost: ' + target.encode("utf-8") + b'\r\n\r\n')
                # Grab the banner
                banner = s.recv(1024)
                banners[port] = banner
                # Using regex to make a better output
                server_header = re.search(b"Server: (.+)", banner)
                final_banner = server_header.group(1).decode('utf-8') if server_header else banner.decode('utf-8')
                # Printing the banner with the port
                print(f"Port {port} Banner: {final_banner}")
                f.write(f"\nPort {str(port)} Banner {final_banner}")
            s.close()

    except KeyboardInterrupt:
        print("\n Exiting Program!")
        sys.exit()
    except socket.gaierror:
        print("\n Hostname Could Not Be Resolved!")
        sys.exit()
    except socket.error:
        print("\n Server not responding!")
        sys.exit()
    except Exception as e:
        print(f"\nError: {e}")

    # Searching for Common Vulnerabilities and Exposures (CVEs) related to banners
    while True:
        input_banner = input("\nEnter a banner to search for CVEs or 'continue' when done: ").strip()
        if input_banner.lower() == 'continue':
            break
        if not input_banner:
            print("Please enter a valid banner.")
            continue
    
        print(f"\nSearching for CVEs related to '{input_banner}'...")
        cve_searched = False
        for port, banner in banners.items():
            server_header = re.search(b"Server: (.+)", banner)
            final_banner = server_header.group(1).decode('utf-8') if server_header else banner.decode('utf-8')
            
            query_banner = urllib.parse.quote_plus(input_banner)
                
            url = f'https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword={query_banner}'
            response = requests.get(url)

            if response.status_code == 200:
                cve_pattern = r'\bCVE-\d{4}-\d{4,7}\b'
                cve_list = re.findall(cve_pattern, response.text)
                f.write(f"\n--------------------------\nCVE related to {query_banner}\n")
                if cve_list:
                    print("\nCVEs Found")
                    for cve in cve_list[:3]:
                        print(cve)
                        f.write(f"\n{cve}")
                    cve_searched = True
                else:
                    print("\nNo CVE found")
                break
        if not cve_searched:
            print(f"No banners matching '{input_banner}' found in the scanned ports.")
    
    mail_option = input("------------------------\nTo send a backup mail use the option 'mail'\nTo skip sending the email, press 'Enter': ")
    if mail_option == 'mail':
        f.close()
        # Prompting user to input receiver's email for sending backup mail
        receiver_email = input("\nReceiver mail: ")
        print("\nSending a backup mail..")
        # Configuring email details
        sender_email = '<YOUR-EMAIL>'
        sender_password = '<YOUR-PASSWORD>'
        subject = 'VulnScanner Report'
        message = 'Please find attached the report generated by the VulnScanner.'
        attachment_filename = 'vulnscanner-out.txt'
        # Sending email with the report as attachment
        send_email(sender_email, sender_password, receiver_email, subject, message, attachment_filename)
        print("\nMail sent, closing program...")
    elif not mail_option:
        print("\nClosing Program...")
