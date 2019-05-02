# ans-cmaster-cluster


These scripts, Ansible playbooks and roles will install a complete Conjur Master cluster (1 master, 2 standbys, load balancer, admin CLI) on fresh Linux inventory host(s). CentOS7, RHEL7.5 and Ubuntu 18.04/bionic have been tested and verified. Multiple inventory hosts of any type can be specified, with each host containing an entire Conjur Master cluster, with all Conjur nodes, LB & CLI running in the same Docker daemon. This configuration should only be used for testing purposes and is expressly NOT recommended for Production deployments.

Linux inventory hosts should be initially provisioned with at least 8GB RAM, 20GB HDD, 4 CPU cores, networking support with internet access and a user with sudo privileges. All installation is performed as that user using sudo as needed, not with root login. If multiple inventory hosts are specified, they must all be provisioned with the same installation user and password. The Conjur appliance, CLI and HAProxy load balancer images are loaded from tarfiles, not built or pulled from internet repos. All package dependencies are assumed accessible from their respective internet repos.

Variables in inventory.yml should be reviewed and edited before running any scripts. The inventory variables define resources (e.g ssh keys, tarfiles) and control optional and one-time task execution, e.g. Red Hat subscription initialization, machine preparation, docker installation, tarfile/image deletion, etc.

The scripts invoke Ansible playbooks and should be run in numerical order. 

Directory contents:
 - 0_installAnsible.sh - installs Ansible on localhost
 - inventory.yml - defines variables and inventory hosts
 - 1_inventoryBootstrap.sh - sets up SSH, passwordless sudo and python on inventory hosts 
 - 2_setupConjur.sh - installs dependencies, Docker and Conjur cluster
 - invBootstrap.yml - playbook to setup SSH and sudo access on inventory hosts
 - conjurSetup.yml - playbook to setup entire Conjur cluster
 - conjurDestroy.yml - playbook to destroy entire Conjur cluster
 - roles/ - directory of Ansible roles for machine prep, Docker and Conjur setup
 - client_test/ - directory for load testing of Conjur cluster
 - failover/ - directory for failover testing of Conjur cluster
