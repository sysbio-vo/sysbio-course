### Managing VMs with OpenStack

To start [log in to OpenStack](https://openstack.bitp.kiev.ua) deployed at [BITP](http://bitp.kiev.ua/) using credentials given to you.

There are different authentication providers as your cloud could be a part of larger system having users who come from other services. We are going to use [Keystone](https://docs.openstack.org/keystone/latest/), OpenStack service that provides API client authentication, service discovery, and distributed multi-tenant authorization. 

Other login options might include [EGI (European Grid Infrastructure)](http://egi.eu) or [Elixir](https://elixir-europe.org/), distributed infrastructure for life-science information.

One can be a part of [VO](https://en.wikipedia.org/wiki/Virtual_organization_(grid_computing)) (virtual organisation), which has access to different OpenStack instances as well as Grid infrastructures using alternative authentication methods. For example, EGI provides a [manual](https://egi-federated-cloud-integration.readthedocs.io/en/latest/openstack.html) on how to set up cloud infrastructure over grid.

#### Dashboard overview

After the login you will see OpenStack dashboard with the right menu featuring following sections:

* **API access**. Links to the OpenStack services dealing with different different part of the cloud such as network or authentication. We will use this information later when creating virtual machines (VMs) from the linux command line.
* **Compute**. Computing resources management.
  * **Overview**. Summary of available resources and running instances.
  * **Instances**. Virtuale machines in use (including suspended ones).
  * **Images**. Operating systems (OS) images, that were uploaded into the cloud. Many wide spread OS provide ready to use cloud images, for example [Ubuntu](https://cloud-images.ubuntu.com/). The images might come in different formats such as QCOW2 or VMDK, and depending on the specific OpenStack instance it is important to know who to [convert between formats](https://docs.openstack.org/image-guide/convert-images.html). OS must be specifically preconfigure, so OpenCloud could interact with it, however, it is not difficult to create image yourself. For example, one can [convert VirtualBox image into raw format](https://docs.openstack.org/image-guide/convert-images.html#vboxmanage-vdi-virtualbox-to-raw) using its VBoxManage command line tool or [create image manually](https://docs.openstack.org/image-guide/create-images-manually.html) using OpenStack manual.
  * **Key Pairs**. Encryption key (public key) and decryption key (private key) [pair](https://en.wikipedia.org/wiki/Public-key_cryptography) for secure data transmission. It's an alternative way how to access VM via SSH (secure shell protocol) instead of password authentication method, which is prohibited by defaults in many OS as less reliable. User can either create new key pair withing OpenStack or import existing one.
  * **Server Group**. It provides a mechanism to group servers according to certain policy.
* **Volumes**. Storage management.
  * **Volumes**. Overview of created volumes.
  * **Snapshots**. Typically snapshot is an exact capture of what a volume looked like at a particular moment in time, including all it's data. The OpenStack snapshot mechanism allows you to create new images from running instances. This is very convenient for upgrading base images or for taking a published image and customizing it for local use.
  * **Groups**. Volume groups.
  * **Group Snapshots**. Snapshot groups.
* **Network**. Network management.
  * **Network Topology**. Visual representation of network topology. Each OpenStack project can have its own private (internal) network(s), which must be connected to public network, so one can access the machine via SSH. Typically "public" network doesn't necessarily mean direct access via public IP and many OpenStack operators provide SSH access to a "jump host" from where one can login to the machine. Later we will use BITP jump host to connect to newly created VMs. 
  * **Networks**. The list of available networks.
  * **Routers**. The list of available routers, which redirects traffic from one network to another.
  * **Secutiry Groups**. A set of rules one can assign to the particular VM instance to allow or restrict usage of specific network protocols and ports.
  * **Floating IPs**. Floating IPs are just publicly routable IPs that one typically buys from an ISP (Internet Service Provider).
* **Orchestration**. Orchestration is typically a service for managing the entire lifecycle of infrastructure and applications within OpenStack clouds. More you can read in the OpenStack [manual](https://docs.openstack.org/newton/user-guide/cli-create-and-manage-stacks.html).
  * **Stacks**. These flexible template languages enable application developers to describe and automate the deployment of infrastructure, services, and applications. The templates enable creation of most OpenStack resource types, such as instances, floating IP addresses, volumes, security groups, and users. The resources, once created, are referred to as stacks.
  * **Resource Types**. There are many resources types such as server or volume, the full list can be found [here](https://docs.openstack.org/heat/pike/template_guide/openstack.html).
  * **Template Versions**. OpenStack [template versions](https://docs.openstack.org/heat/latest/template_guide/hot_spec.html).
  * **Template Generator**. An editor for [templates creation](https://docs.openstack.org/heat-dashboard/latest/user/template_generator.html).
* **Identity**. Projects and users management.
  * **Projects**. Projects list in the particular OpenStack instance.
  * **Users**. Users list in the particular OpenStack instance.
  * **Application credentials**. Users can create [application credentials](https://docs.openstack.org/keystone/queens/user/application_credentials.html) to allow their applications to authenticate to keystone. 

#### Create your first VM

Now when we are familiar with OpenStack dashboard it is time to create our first VM. Follow the instructions:

1. Navigate to Project -> Compute -> Instances and press **Launch Instance**.
2. Under **Details** menu input instance name.
3. Under **Source** menu select boot source **Image**, set volume size as **1GB**, select **Yes** to delete volume on instance delete, press arrow near the **Ubuntu-cosmic** image.
4. Under **Flavor** menu select **m1.tiny** instance type.
5. Under **Key pair** menu press **Create Key Pair**, enter kay pair name and press create. Copy pricate key to clipboard, open any text editor, paste the key and save the file. You won't be able to access VM without private key.
6. Press **Launch Instance**.

After that wait till the power state of the VM is **Running** and press VM name. You will be able to see VM overview, its network interfaces, boot log, console (for web access, although you won't be ablle to login as we use key authentication) and action log. Verify if console shows login prompt to be sure that VM is running indeed.

Next step is accessing VM via SSH. Unfortunatelly, we do not have many public IPs, so we are going to access VM through the jump host. Log in to **cloud-11** host using provided credentials:

```bash
# Enter password when asked
ssh username@cloud-11.bitp.kiev.ua
# Create file and copy private key
touch privatekey.pem
nano privatekey.pem
# Copy the key you saved before and save the file
# Change the permissions of the file as ssh requires it to be accessed by specific user only
chmod 600 privatekey.pem
# Check the permissions
ls -al
# Log in to the VM, check allocated FloatingIP in the OpenStack dashboard
ssh -i privatekey.pem ubuntu@ipaddress
```

#### Launching VM with Vagrant

Using graphical interface (GUI) is nice, but takes time, especially if one needs to launch and destroy VMs regularly. There are many ways how to do it via command line using config files with all required information. We are going to use [Vagrant](https://www.vagrantup.com/), open-source software product for building and maintaining portable virtual software development environments, e.g. for VirtualBox, KVM, Hyper-V, Docker containers, VMware, and AWS. It tries to simplify software configuration management of virtualizations in order to increase development productivity. There are many user provided plugins for Vagrant including OpenStack provider. In particular, we will use OpenStack plugin from this [repository](https://github.com/ggiamarchi/vagrant-openstack-provider). Before proceeding examine the repository and read about implemeted functionality.


```bash
# Download and unzip
# Check other download options here https://www.vagrantup.com/downloads.html
mkdir bin
wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_linux_amd64.zip
unzip vagrant_2.2.4_linux_amd64.zip
mv vagrant bin/
nano ~/.bashrc
# Add the following to the end of your .bashrc file while using nano
# or your text editor of choice:
export PATH="/home/$USER/bin:$PATH"
# Close editor and run
source .bashrc
# Make sure it works by launching
vagrant
# Install openstack plugin
vagrant plugin install vagrant-openstack-provider
```
You should see following message:
```bash
Installing the 'vagrant-openstack-provider' plugin. This can take a few minutes...
Fetching: terminal-table-1.4.5.gem (100%)
Fetching: sshkey-1.6.1.gem (100%)
Fetching: colorize-0.7.3.gem (100%)
Fetching: public_suffix-2.0.5.gem (100%)
Fetching: vagrant-openstack-provider-0.13.0.gem (100%)
Installed the plugin 'vagrant-openstack-provider (0.13.0)'!
```

Now clone the repository with Vagrant configuration
```bash
git clone https://github.com/sysbio-vo/ung-cloud.git
cd ung-cloud/cloud/vagrant
mkdir modules
cd modules
# Clone repos with required modules
git clone https://github.com/puppetlabs/puppetlabs-stdlib stdlib
git clone https://github.com/puppetlabs/puppetlabs-apt apt
cd ..
# Edit Vagrant file according by changin credentials, project name, image, flavor etc
# Launch instance
vagrant up
# Destroy instance when is not needed anymore
vagrant destroy
```
