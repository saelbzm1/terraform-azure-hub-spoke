\# Terraform Azure Hub \& Spoke



\## Description

This project deploys a scalable Azure Hub \& Spoke architecture using Terraform.



\## Architecture

\- 1 Hub VNet (central security with Azure Firewall)

\- 3 Spokes:

&#x20; - Web (frontend)

&#x20; - App (backend)

&#x20; - DB (database)



\## Features

\- Dynamic VNet and subnet creation

\- No hardcoding (fully data-driven)

\- Route tables forcing traffic through firewall

\- VMs deployed dynamically

\- Modular Terraform structure



\## Technologies

\- Terraform

\- Microsoft Azure



\## Design Principles

\- DRY (Don't Repeat Yourself)

\- Scalable architecture

\- Reusable modules

\- Infrastructure as Code



\## Notes

\- All resources are generated from a single `vnets` variable

\- Supports extension without modifying core code



