# Scripts for Nessus Essentials

## Create Schedule Scan for Nessus Essentials

**Usage:**  
`create_schedule_scan.sh -s scan_number -t target-ip -h host-of-nessus -u username-of-nessus -p password-of-nessus`  

**Example:**  
`create_schedule_scan.sh -s 2 -t 127.0.0.1 -h https://kali:8834 -u admin -p admin`  

### List of Available Scans and Their Respective Numbers

Available scan types:  
1. **asv**  
2. **discovery**  
3. **basic**  
4. **patch_audit**  
5. **webapp**  
6. **malware**  
7. **mobile**  
8. **mdm**  
9. **compliance**  
10. **pci**  
11. **offline**  
12. **cloud_audit**  
13. **scap**  
14. **advanced**  
15. **advanced_dynamic**  
16. **active_directory**  
17. **ai_llm_assessment**  
18. **nessus_agent_reset_and_update**  
19. **credential_validation**  
