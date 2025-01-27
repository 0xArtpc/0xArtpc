<h1>Scripts for nessus essentials</h1>

<h2>Create Schedule Scan for nessus Essentials</h2>
<p>Usage: <br>
`create_schedule_scan.sh -s scan_number -t target-ip -h host-of-nessus -u username-of-nessus -p password-of-nessus`
`Example create_schedule_scan.sh -s 2 -t 127.0.0.1 -h https://kali:8834 -u admin -p admin`
<br>
<p>List of available scans and the respective numbers
Available scan types:
<br>1. asv
<br>2. discovery
<br>3. basic
<br>4. patch_audit
<br>5. webapp
<br>6. malware
<br>7. mobile
<br>8. mdm
<br>9. compliance
<br>10. pci
<br>11. offline
<br>12. cloud_audit
<br>13. scap
<br>14. advanced
<br>15. advanced_dynamic
<br>16. active_directory
<br>17. ai_llm_assessment
<br>18. nessus_agent_reset_and_update
<br>19. credential_validation
</p>
