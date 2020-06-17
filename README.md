# Automation Scripts

These automation scripts can be used to achieve the following items:

##### Linux RHEL 6/7 and Centos 6/7
- Change the contents of /etc/resolv.cong with desired name servers
- Run the prepare-for-wigs scripts for Linux Servers
- Run RHEL subscription script
- Configure SSHD to allow pubkey authentication
- Uninstall vmware tools 
- Perform steps to enable ENA support on non-nitro EC2 instances
- Install EFA driver on EC2 instances
- Setup and Run Linux pre-wig validator on Linux servers
- remove the 70-persistent-net.rules

##### Windows 2012 / 2016 / 2019
- Unjoin the server from domain and add to WORKGROUP
- Disable firewall and allow TSC connections
- Disable the built in Administrator ID
- Uninstall PV Drivers , Microsoft Monitoring Agent, VMware tools, Commvault agent 
- Remove any stale .aws credentials from systemprofle
- Uninstall and Reinstall Latest SSMAgent
- Uninstall and Reinstall Latest EC2Config
- Install ENADrivers, NVMe Drivers , PV Driver
- Install AWS Powershell Tool kit
- Validate system PATH variable
- Run Windows pre-wig validation script


### Instructions:

#### Set up the ansible inventory:
Provide the relevant host ips and connection information in the hosts file based upon the environment

#### Run the automation:
###### RHEL 6/7:
- `ansible-playbook -i hosts -l linux-rhel playbook-linux-rhel-prewig.yaml`
  
###### Centos 6/7:
- `ansible-playbook -i hosts -l linux-centos playbook-linux-centos-prewig.yaml`

###### Windows 2012/2016/2019
- `ansible-playbook -i hosts -l windows playbook-windows-prewig.yaml`

###### (Optional) Kernel update for RHEL and Centos Servers (if required)
- `ansible-playbook -i hosts -l windows playbook-kernelupdate.yaml`
