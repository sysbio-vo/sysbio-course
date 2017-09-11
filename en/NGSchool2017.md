### Contents

[Basic commands to deal with packages in Ubuntu](#basic-commands-to-deal-with-packages-in-ubuntu)

[Installing R packages](#installing-r-packages)

[Installing packages with conda](#installing-packages-with-conda)

#### Basic commands to deal with packages in Ubuntu

Assuming you start with clean Ubuntu 16.04.

> **NB: **If you use VirtualBox and want to enable copy-paste between host and virtual machine, you need to download and install VirtualBox Guest Additions from Devices menu. After that reboot and click Devices -&gt; Shared Clipboard -&gt; Bidirectional.

First, we need to update packages metadata from Ubuntu repositories and upgrade packages to newer versions.

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

If the dependencies have changed on one of the packages you have installed so that a new package must be installed to perform the upgrade then that will be listed as ["kept-back"](https://debian-administration.org/article/69/Some_upgrades_show_packages_being_kept_back). In our case kernel images need to be upgraded, which can be solved with:

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

> **NB: **Always use **sudo** over **su**: only particular command will run in super-user mode; you will be asked for your password, so you can think twice before executing; attempts to invoke sudo can be logged.

Let's run R:

```bash
aln@aln-vb:~$ R

R version 3.2.3 (2015-12-10) -- "Wooden Christmas-Tree"
Copyright (C) 2015 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

...

>
```

Wait, but we need the latest version, which is 3.4, why do we have 3.2? Didn't we update the system properly? Let's check the metadata of the package within Ubuntu repository:

```bash
apt-cache show r-base
```

We can also look at the version table as well \(shows if a package is installed and to which repository it belongs to\):

```bash
apt-cache policy r-base
```

> **NB:** If you want to know more about apt-cache command, just run it in the console without any parameters

After googling we found out that default Ubuntu repository does not contain the most fresh R distribution, as packages are updated gradually when some time passes after package authors updates it \(it can happen with many packages, especially actively developed ones\). We are suggested to add custom repository, which contains fresh R:

```bash
sudo add-apt-repository ppa:marutter/rrutter
sudo apt-get update
```

Now after packages metadata update we see that we can upgrade smth:

```bash
19 packages can be upgraded. Run 'apt list --upgradable' to see them.
aln@aln-vb:~$ apt list --upgradable
Listing... Done
r-base-core/xenial 3.4.1-2xenial0 amd64 [upgradable from: 3.2.3-4]
r-base-dev/xenial,xenial 3.4.1-2xenial0 all [upgradable from: 3.2.3-4]
...
```

Finally we can initiate upgrade with our usual command:

```bash
sudo apt-get upgrade
```

But where is the repo we just added stored? Try to examine the following folder:

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

More package install related command.

Following command will remove the binaries, but not the configuration or data files of the package, and will leave dependencies untouched.

```bash
sudo apt-get remove r-base
```

This command remove everything regarding the package, but not the dependencies installed with it. Both commands are equivalent. Particularly useful when you want to 'start all over' with an application because you messed up the configuration. However, it does not remove configuration or data files residing in users home directories, usually in hidden folders, which in most cases you will have to remove yourself.

```bash
sudo apt-get purge r-base
sudo apt-get remove --purge r-base
```

Following command removes orphaned packages, i.e. packages that were installed as an dependency. Use this after removing a package which had installed dependencies you're no longer interested in.

```bash
apt-get autoremove
```

> **NB: **You can accidentally remove important package, which will cause a lot of orphaned packages, don't be in a hurry to use autoremove, try to think why you suddenly have a lot of candidates

In case smth went wrong the following command attempts to correct a system with broken dependencies in place:

```bash
sudo apt-get -f install
```

If you want to get an idea of what an action will do use simulate flas:

```bash
sudo apt-get install -s r-base
```

Autoconfirm your choices with "yes" answer:

```bash
sudo apt-get remove -y r-base
```

Download, but not install:

```bash
sudo apt-get install -d r-base
```

Suppress all the output:

```bash
sudo apt-get remove -qq r-base
```

Sometimes you need to install .deb package manually \(without Software Manager\), for example RStudio:

```bash
wget https://download1.rstudio.org/rstudio-xenial-1.0.153-amd64.deb 
sudo dpkg -i rstudio-xenial-1.0.153-amd64.deb
```

If you execute the lines above on a clean Ubuntu 16.04 you will most likely have error message similar to this:

```bash
aln@aln-vb:~/Downloads$ sudo dpkg -i rstudio-xenial-1.0.153-amd64.deb 
(Reading database ... 215529 files and directories currently installed.)
Preparing to unpack rstudio-xenial-1.0.153-amd64.deb ...
Unpacking rstudio (1.0.153) over (1.0.153) ...
dpkg: dependency problems prevent configuration of rstudio:
 rstudio depends on libjpeg62; however:
  Package libjpeg62 is not installed.
...
```

Since you're not installing RStudio from the repository the dependencies are not installed automatically, in this case you can simple install manually:

```
sudo apt-get install libjpeg62
```

#### Installing R packages

> **NB: **It will save you a lot of pain if you install all the packages in the local folder even on your personal computer, this way you can easily install and update packages using RStudio graphical interface or install latest packages not available for your distribution. [Starting from R 3.4](https://knausb.github.io/2017/07/r-3.4.1-personal-library-location/) \(Jun 2017\) though, you need to uncomment following line and specify your local lib path in the config file \(previously R did it interactively\). If you don't have root access, just create new file "~/.Renviron" and put the R\_LIBS\_USER variable there.

```bash
aln@notik:/$ cat /etc/R/Renviron
...
# edd Jun 2017  Comment-out R_LIBS_USER
R_LIBS_USER=${R_LIBS_USER-'~/R/x86_64-pc-linux-gnu-library/3.4'}
...
```

The most convenient way to install packages is through Bioconductor \(especially for bio-related stuff\):

```bash
## Install Bioconductor
## try http:// if https:// URLs are not supported
source("https://bioconductor.org/biocLite.R")
biocLite()

## Install specific package
biocLite("Rsubread")
```

Or using default functions:

```bash
# Check installed packages
installed.packages()
# Install specific package
install.packages("ggplot2")
# Update packages
update.packages()
# Update without prompts for permission
update.packages(ask = FALSE)
# Update only a specific package (the same as install)
install.packages("plotly")
```

Let's try to install XML package in R \(or RStudio\):

```bash
install.packages("XML")
```

Well, we've got an error:

```bash
checking for xml2-config... no
Cannot find xml2-config
ERROR: configuration failed for package ‘XML’
* removing ‘/home/aln/R/x86_64-pc-linux-gnu-library/3.2/XML’
Warning in install.packages :
  installation of package ‘XML’ had non-zero exit status
```

But what is wrong? R cannot install dependencies? It should. It happens that R XML package requires XML dev Ubuntu package, so the right way would be to install R XML using Ubuntu package manager \(don't execute the line yet\):

```bash
sudo apt-get install r-cran-xml
```

However, not all the R packages can be installed using apt-get, so we can simply install XLM dev \(in Ubuntu command line!\):

```bash
sudo apt-get install libxml2-dev
```

And try to install XML within R again:

```bash
install.packages("XML")
```

Remember this case as it is one of the most typical troubles newbies encounter when dealing with R packages.

#### Installing packages with conda

Using shared computation resources will mean that you don't have root access, so we need smth flexible and easy to deal with, which allows to transfer our configured environment from host to host easily. [Conda](https://conda.io/) is a popular solution on that regards.

Let's start with installing [Miniconda](https://conda.io/miniconda.html) \(contains the conda package manager and Python\):

```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod u+x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

There is very nice [tutorial](https://conda.io/docs/user-guide/getting-started.html) from conda site, it is highly recommended to read it all, here we will briefly overview the most important things. Don't forget about [cheat sheet](https://conda.io/docs/_downloads/conda-cheatsheet.pdf), it will help you to memorize the commands!

First, we need to add some channels, or repositories with software binaries. With info command we can see brief data on the conda install:

```bash
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda info
```

Then we create and activate separate environment called 'ngschool':

```bash
conda create --name ngschool
ls ~/miniconda3/envs/
source activate ngschool
```

After activating the environment you will see its name in the beginning of the prompt line. Lets check if we have anything installed:

```bash
conda list
```

Obviously, the environment is empty. We need to install our first application:

```bash
# Try to check if there is a package with particular name
conda search fastqc
# More detailed package info
conda info fastqc
# Install the package
conda install fastqc
# Check the list again
conda list
```

But sometimes you have to install the software of an older version, because you need to reproduce the particular environment \(e.g. in case you do the benchmarking of some algorithms\). Lets create new environment and play with versions a little bit.

```bash
conda create --name old
```

You can check what envs do you have:

```bash
(ngschool) aln@aln-vb:~$ conda info --envs
# conda environments:
#
ngschool              *  /home/aln/miniconda3/envs/ngschool
old                      /home/aln/miniconda3/envs/old
root                     /home/aln/miniconda3
```

> **NB:** By default there is also root environment, if you have many concurrent tasks/projects better to separate different logic between environments, so you can easily deploy needed env somewhere else without installing unnecessary stuff.

Activate new env:

```
source activate old
```



