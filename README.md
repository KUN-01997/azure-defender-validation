# Azure Defender for Cloud Misconfiguration Lab

This project simulates common Azure misconfigurations and remediates them using Terraform. Microsoft Defender for Cloud is used to detect and validate insecure configurations. It includes both vulnerable and secure resources to demonstrate detection, remediation, and validation workflows.

---

##  What This Project Demonstrates

- Detection of insecure cloud resources using **Microsoft Defender for Cloud**
- Infrastructure-as-Code (IaC) misconfiguration simulation using **Terraform**
- Real-world security issues like:
  - Publicly accessible Key Vaults
  - RDP exposed via NSG
  - Unencrypted managed disks
- IaC-based remediation using a secure Terraform configuration
- Export and interpretation of Defender findings using **Azure Resource Graph**

---

## Architecture

- `main.tf` deploys misconfigured Azure resources
- `remediate.tf` deploys secure equivalents side-by-side
- Defender for Cloud detects insecure versions and flags them
- Secure versions validate your remediation skills

---

##  MITRE ATT&CK Mapping

- **T1552.001 – Unsecured Credentials: Key Storage**  
  (Misconfigured Key Vault firewall)

- **T1133 – External Remote Services (RDP)**  
  (NSG rule exposing RDP to the internet)

- **T1529 – System Shutdown/Reboot**  
  (Unencrypted managed disks that allow offline tampering)

---

##  Skills Demonstrated

- Cloud misconfiguration modeling
- Security-as-code using Terraform
- Azure resource provisioning
- Microsoft Defender for Cloud integration
- Secure-by-default infrastructure design
- Terraform remediation validation


