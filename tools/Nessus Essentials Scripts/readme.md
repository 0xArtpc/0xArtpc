<h1>Scripts for nessus essentials</h1>

<h2>Create Schedule Scan for nessus Essentials</h2>
<p>Usage: create_schedule_scan.sh -s scan_number -t target-ip -h host-of-nessus -u username-of-nessus -p password-of-nessus</p>
<p>Example create_schedule_scan.sh -s 2 -t 127.0.0.1 -h https://kali:8834 -u admin -p admin</p>
<br>
<p>List of scans and the respective numbers
Available scan types:
1. asv [cfc46c2d-30e7-bb2b-3b92-c75da136792d080c1fffcc429cfd]
2. discovery [bbd4f805-3966-d464-b2d1-0079eb89d69708c3a05ec2812bcf]
3. basic [731a8e52-3ea6-a291-ec0a-d2ff0619c19d7bd788d6be818b65]
4. patch_audit [0625147c-30fe-d79f-e54f-ce7ccd7523e9b63d84cb81c23c2f]
5. webapp [c3cbcd46-329f-a9ed-1077-554f8c2af33d0d44f09d736969bf]
6. malware [d16c51fa-597f-67a8-9add-74d5ab066b49a918400c42a035f7]
7. mobile [8382be4c-2056-51fe-65a3-a376b7912a013d58cfc392e0fac5]
8. mdm [fbcff9e6-0c8c-e6a9-4d8a-a43a6ee7c04b3fa5e24c0fc81b34]
9. compliance [40345bfc-48be-37bc-9bce-526bdce37582e8fee83bcefdc746]
10. pci [e460ea7c-7916-d001-51dc-e43ef3168e6e20f1d97bdebf4a49]
11. offline [1384f3ce-0376-7801-22db-a91e1ae16dea8d863e17313802b1]
12. cloud_audit [97f94b3b-f843-92d1-5e7a-df02f9dbfaaef40ae03bfdfa7239]
13. scap [fb9cbabc-af67-109e-f023-1e0d926c9e5925eee7a0aa8a8bd1]
14. advanced [ad629e16-03b6-8c1d-cef6-ef8c9dd3c658d24bd260ef5f9e66]
15. advanced_dynamic [939a2145-95e3-0c3f-f1cc-761db860e4eed37b6eee77f9e101]
16. active_directory [8b5d14bc-f33e-cbc1-ef33-bf6c40eb568f1401448c08dbfd88]
17. ai_llm_assessment [a303f033-d3b7-e53c-603d-a7bbf7b3c65ec6d8ecaa53911a55]
18. nessus_agent_reset_and_update [9b562e88-e3dc-41c8-90d5-46df3c827264333c17d5c7918f29]
19. credential_validation [1aaa8505-5326-e30c-d9e1-2dff4d39f18354e00d4c76f626b9]
</p>
