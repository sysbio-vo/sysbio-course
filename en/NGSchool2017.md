### Contents

[Basic commands to deal with packages in Ubuntu](#basic-commands-to-deal-with-packages-in-ubuntu)

#### 

#### 

#### Basic commands to deal with packages in Ubuntu



> Assuming you start from clean Ubuntu 16.04.
>
> **Note: **If you use VirtualBox and want to enable copy-paste between host and virtual machine, you need to download and install VirtualBox Guest Additions from Devices menu. After that reboot and click Devices -&gt; Shared Clipboard -&gt; Bidirectional.

```bash
sudo apt-get update
sudo apt-get upgrade
```

Run again upgrade to see if all the packages are installed:

```bash
aln@aln-vb:~$ sudo apt-get upgrade
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Calculating upgrade... Done
The following packages have been kept back:
  linux-generic-hwe-16.04 linux-headers-generic-hwe-16.04
  linux-image-generic-hwe-16.04
0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
```

If the dependencies have changed on one of the packages you have installed so that a new package must be installed to perform the upgrade then that will be listed as ["kept-back"](https://debian-administration.org/article/69/Some_upgrades_show_packages_being_kept_back). In our case kernel images need to be upgrade, which can be solved with:

```bash
sudo apt-get dist-upgrade
```

If we run upgrade again we can see that everything is ok:

```bash
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

Let's say we need to install R \(we can even try to search package name if we don't know it\):

```bash
apt-cache search r | grep statistic
sudo apt-get install r-base-core r-recommended
```

> Always use **sudo** over **su**: only particular command will run as super-user; you will be asked for your password, so you can think twice before executing; attempts to invoke sudo can be logged.

Let's run R:

```bash
aln@aln-vb:~$ R

R version 3.2.3 (2015-12-10) -- "Wooden Christmas-Tree"
Copyright (C) 2015 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

...

>
```

Wait, but we need the latest version, which is 3.4, why do we have 3.2 \(it can happen with many packages and versions\)? Didn't we update the system properly? Let's check the metadata of the package within Ubuntu repository:

```bash
apt-cache show r-base
```

We can also look at the version table as well:

```bash
apt-cache policy r-base
```

> If you want to know more about apt-cache command, just run it in the console without any parameters

After googling we found out that default Ubuntu repository does not contain the most fresh R distribution, as packages are updated gradually when some time passes after package authors updates it. We are suggested to add custom repository, which contains fresh R:

```bash
sudo add-apt-repository ppa:marutter/rrutter
sudo apt-get update
```

asdf

```bash
19 packages can be upgraded. Run 'apt list --upgradable' to see them.
aln@aln-vb:~$ apt list --upgradable
Listing... Done
r-base-core/xenial 3.4.1-2xenial0 amd64 [upgradable from: 3.2.3-4]
r-base-dev/xenial,xenial 3.4.1-2xenial0 all [upgradable from: 3.2.3-4]
r-cran-boot/xenial,xenial 1.3-20-1xenial0 all [upgradable from: 1.3-17-1]
r-cran-class/xenial 7.3-14-2xenial0 amd64 [upgradable from: 7.3-14-1]
r-cran-cluster/xenial 2.0.6-2xenial0 amd64 [upgradable from: 2.0.3-1]
r-cran-codetools/xenial,xenial 0.2-15-1cran1xenial0 all [upgradable from: 0.2-14-1]
r-cran-foreign/xenial 0.8.69-1xenial0 amd64 [upgradable from: 0.8.66-1]
r-cran-kernsmooth/xenial 2.23-15-3xenial0 amd64 [upgradable from: 2.23-15-1]
r-cran-lattice/xenial 0.20-35-1cran1xenial0 amd64 [upgradable from: 0.20-33-1]
r-cran-mass/xenial 7.3-47-1xenial0 amd64 [upgradable from: 7.3-45-1]
r-cran-matrix/xenial 1.2-11-1xenial0 amd64 [upgradable from: 1.2-3-1]
r-cran-mgcv/xenial 1.8-19-1xenial0 amd64 [upgradable from: 1.8-11-1]
r-cran-nlme/xenial 3.1.131-3xenial0 amd64 [upgradable from: 3.1.124-1]
r-cran-nnet/xenial 7.3-12-2xenial0 amd64 [upgradable from: 7.3-12-1]
r-cran-rpart/xenial 4.1-11-1xenial0 amd64 [upgradable from: 4.1-10-1]
r-cran-spatial/xenial 7.3-11-1xenial0 amd64 [upgradable from: 7.3-11-1]
r-cran-survival/xenial 2.41-3-2xenial0 amd64 [upgradable from: 2.38-3-1]
r-doc-html/xenial,xenial 3.4.1-2xenial0 all [upgradable from: 3.2.3-4]
r-recommended/xenial,xenial 3.4.1-2xenial0 all [upgradable from: 3.2.3-4]
```

Finally we can initiate upgrade with our usual command:

```bash
sudo apt-get upgrade
```

But where is this repo stored we added? Try to examine the following folder:

```bash
ls /etc/apt/
cat /etc/apt/sources.list
```

It happens that our repository had been added into the separate file. And actually, instead of using add-apt-repository command one can do it manually by editing corresponding files:

```bash
aln@aln-vb:~$ cat /etc/apt/sources.list.d/marutter-ubuntu-rrutter-xenial.list 
deb http://ppa.launchpad.net/marutter/rrutter/ubuntu xenial main
# deb-src http://ppa.launchpad.net/marutter/rrutter/ubuntu xenial main
```

Following command will remove the binaries, but not the configuration or data files of the package, and  will leave dependencies untouched.

```bash
sudo apt-get remove r-base
```

will remove about_everything _regarding the package`packagename`, but not the dependencies installed with it on installation. Both commands are equivalent. Particularly useful when you want to 'start all over' with an application because you messed up the configuration. However, it does not remove configuration or data files residing in users home directories, usually in hidden folders there. There is no easy way to get those removed as well.

```bash
apt-get purge packagename
```

removes orphaned packages, i.e. installed packages that used to be installed as an dependency, but aren't any longer. Use this after removing a package which had installed dependencies you're no longer interested in.

```bash
apt-get autoremove
```

> Danger of using autoremove



