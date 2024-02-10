# @hyperify/gosd

SystemD cloud platform installer and manager

## Overview

`gosd` is a tool engineered to streamline the installation and management of a
SystemD-based cloud platform. Emphasizing simplicity and reliability, it 
integrates essential cloud functionalities through the use of statically 
compiled standalone tools. Rooted in the UNIX philosophy, `gosd` adopts a 
minimalistic approach, offering an efficient and user-centric experience in 
cloud platform management.

## Getting Started

(TODO: Instructions on how to install, configure, and use `gosd` will be added here)

## Planned Features and Requirements

- **Operating System**: Utilizes any SystemD compatible Linux distribution.
- **Monitoring and Metrics**: Integrated with Prometheus for comprehensive monitoring.
- **Configuration Management**: Managed using Ansible, with plans to incorporate Terraform.
- **Log Management**: Utilizes standard SystemD components like rsyslog and journald.
- **Automated Installation & Software Upgrades**: Simplified through Ansible.
- **Network Management and VPN**: Configured via Netplan and secured with Wireguard VPN.
- **Object Storage**: S3 compatible storage implemented using MinIO.
- **Custom REST API Component**: A custom API for platform operations.
- **Backup and Recovery**: Customizable with a custom utility or other single-file solutions.
- **User Authentication and Authorization**: Ensures secure access control.
- **Load Balancing and Traffic Management**: Handled by nginx.
- **Event Messaging and Streaming**: Uses NATS for efficient system-wide messaging and streaming.
- **Database Services**: Services with solutions like PostgreSQL.
- **File Sharing and Collaboration Tools**: Facilitates simple file sharing.
- **Disaster Recovery Planning**: Automated tools and strategies for effective disaster recovery.
- **High Availability Setup**: Focus on the high availability of critical components.
- **Resource Allocation and Scaling**: Dynamic resource allocation and scaling capabilities.
- **Security Compliance and Auditing**: Regular security measures and auditing.
- **Virtual Machine Management**: Minimalist approach using QEMU/KVM for necessary virtualization.
- **Container Management**: Basic management of container deployment through SystemD.
- **API Gateway and Service Mesh**: Manages internal API routing using nginx.
- **Documentation and User Guides**: Comprehensive guides for both users and administrators.
- **Support and Maintenance Tools**: Tools for diagnostics and system maintenance.

## License

Copyright (c) Heusala Group Ltd. All rights reserved.

`gosd` is licensed under the HG Evaluation and Non-Commercial License (version 
1). This license grants the right to use, modify, and distribute the software 
solely for non-commercial and evaluation purposes for a period of two (2) years 
from the date of each software release. After this period, the license terms 
automatically transition to the MIT License, allowing broader usage rights,
including commercial use.

Key aspects of the HG Evaluation and Non-Commercial License include:
- **Non-commercial and Evaluation Use**: Permitted for educational purposes, 
  research activities, personal projects, charitable organizations, and national 
  military purposes (subject to certain conditions).
- **Commercial Use Restriction**: The use of the software for commercial 
  purposes is prohibited during the two-year restriction period, unless explicit 
  permission is granted by Heusala Group Ltd.
- **Transition to MIT License**: After the two-year period, the terms transition
  to the MIT License, which permits use, modification, and distribution of the 
  software for any purpose, including commercial.
- **Non-Competing Activity**: Licensees agree not to use the software in any 
  manner that directly competes with Heusala Group Ltd's business interests 
  during the restriction period and for one year thereafter.

For full details of the license terms, please see the [LICENSE.md](LICENSE.md) 
file in the project repository.

**Note:** This summary is provided for convenience and does not represent the full 
legal terms of the license. Users should refer to the actual license text for 
all details and implications.

## Contact

If you have any questions, feedback, or would like to get involved with the 
`gosd` project, feel free to reach out to us.

- **Email**: For direct inquiries, you can email us at 
  [info@hg.fi](mailto:info@hg.fi).
- **Discord**: Join our community on Discord for discussion, support, and 
  collaboration. Here's the invite link to our server: [gosd Discord Server](https://discord.gg/V2X9XugU3p).

We look forward to hearing from you and welcome your contributions to the 
`gosd` community!
