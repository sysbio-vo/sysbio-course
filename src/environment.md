### Package management

#### Installing Ubuntu packages

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
  linux-generic linux-headers-generic
  linux-image-generic
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

Let's say we need to install R (we can even try to search package name if we don't know it):

```bash
apt-cache search r | grep statistic
sudo apt-get install r-base r-recommended
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

Wait, but it's not the latest version, why do we have 3.2? Didn't we update the system properly? Let's check the metadata of the package within Ubuntu repository:

```bash
apt-cache show r-base
```

We can also look at the version table as well (shows if a package is installed and to which repository it belongs to):

```bash
apt-cache policy r-base
```

> **NB:** If you want to know more about apt-cache command, just run it in the console without any parameters

After googling we found out that default Ubuntu repository does not contain the most fresh R distribution, as packages are updated gradually when some time passes after package authors updates it (it can happen with many packages, especially actively developed ones). We need to add additional repository, which contains fresh R (more details are [here](https://cran.r-project.org/bin/linux/ubuntu/)):

```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/r-cran.list
deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/
EOF
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get update
```

Now after packages metadata update we can check if we can upgrade smth:

```bash
aln@aln-vb:~$ apt list --upgradable
Listing... Done
r-base/xenial 3.4.4-1xenial0 all [upgradable from: 3.2.3-4]
r-base-core/xenial 3.4.4-1xenial0 amd64 [upgradable from: 3.2.3-4]
...
```

Finally we can initiate upgrade with our usual command:

```bash
sudo apt-get upgrade
# And if needed
sudo apt-get dist-upgrade
```

But where is the repo we just added stored? Try to examine the following folder:

```bash
ls /etc/apt/
cat /etc/apt/sources.list
cat /etc/apt/sources.list.d/r-cran.list
```

> **NB: ** There is an automatic way how to deal with the repositories using `add-apt-repository` command,  which  adds  an  external  APT  repository  to   either `/etc/apt/sources.list` or a file in `/etc/apt/sources.list.d/` or removes an already existing repository.

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
sudo apt-get autoremove
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

Sometimes you need to install .deb package manually (without Software Manager\), for example RStudio:

```bash
wget https://download1.rstudio.org/rstudio-xenial-1.1.456-amd64.deb 
sudo dpkg -i rstudio-xenial-1.1.456-amd64.deb
```

If you execute the lines above on a clean Ubuntu 16.04 you will most likely have error message similar to this:

```bash
aln@aln-vb$ sudo dpkg -i rstudio-xenial-1.1.456-amd64.deb
Selecting previously unselected package rstudio.
(Reading database ... 104144 files and directories currently installed.)
Preparing to unpack rstudio-xenial-1.1.456-amd64.deb ...
Unpacking rstudio (1.1.456) ...
dpkg: dependency problems prevent configuration of rstudio:
 rstudio depends on libjpeg62; however:
  Package libjpeg62 is not installed.
...
```

Since you're not installing RStudio from the repository the dependencies are not installed automatically, in this case you can simply install it manually:

```bash
sudo apt-get install libjpeg62
```

#### Installing R packages

> **NB: **It will save you a lot of pain if you install all the packages in the local folder even on your personal computer, this way you can easily install and update packages using RStudio graphical interface or install latest packages not available for your distribution. If you want custom local lib path, edit the `Renviron` config file, namely `R_LIBS_USER` variable:

```bash
aln@notik:/$ cat /etc/R/Renviron # Alternatively you can create the local file ~/.Renviron
...
R_LIBS_USER=${R_LIBS_USER-'~/R/x86_64-pc-linux-gnu-library/3.4'}
...
```

The most convenient way to install packages is through Bioconductor \(especially for bio-related stuff\):

```bash
## Install Bioconductor
## try http:// if https:// URLs are not supported
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install()

## Install specific package
BiocManager::install("Rsubread")
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

> **NB: ** For some packages it is better to install through Bioconductor if you use the latest R version, as Bioconductor usually has newest packages related to Bioinformatics

Let's try to install XML package in R (or RStudio):

```bash
install.packages("XML")
```

Well, we've got an error:

```bash
checking for xml2-config... no
Cannot find xml2-config
ERROR: configuration failed for package ‘XML’
* removing ‘/home/aln/R/x86_64-pc-linux-gnu-library/3.4/XML’
Warning in install.packages :
  installation of package ‘XML’ had non-zero exit status
```

But what is wrong? R cannot install dependencies? It should. It happens that R XML package requires XML dev Ubuntu package, so the right way would be to install R XML using Ubuntu package manager (don't execute the line yet):

```bash
sudo apt-get install r-cran-xml
```

However, not all the R packages can be installed using apt-get, so we can simply install XLM dev (in Ubuntu command line!):

```bash
sudo apt-get install libxml2-dev
```

And try to install XML within R again:

```bash
install.packages("XML")
```

> **NB: **Memorize the case with system dev packages as it is one of the most typical troubles newbies encounter when dealing with R packages.

#### Conda package manager

Using shared computation resources means that you don't have root access, so we need smth flexible and easy to deal with, which allows to transfer our configured environment from host to host easily. [Conda](https://conda.io/) is a popular solution in such case.

Let's start with installing [Miniconda](https://conda.io/miniconda.html) (contains the conda package manager and Python):

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
conda create --name test
ls ~/miniconda3/envs/
conda activate test
python --version
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
# Alternatively you can specify (any) env name
conda list -n test
```

You will see that there are multiple versions of fastqc with the same version number. The reason for that is [different builds of packages](https://conda.io/docs/user-guide/tasks/build-packages/package-spec.html) with otherwise identical names and versions, where build number is non-negative integer.

But sometimes you have to install the software of an older version, because you need to reproduce the particular environment (e.g. in case you do the benchmarking of some algorithms). On top of that you might require different python version. Lets create new environment and play with versions a little bit.

```bash
conda create --name python2 python=2
```

You can check what envs do you have:

```bash
(ngschool) aln@aln-vb:~$ conda info --envs
# conda environments:
#
test              *  /home/aln/miniconda3/envs/test
python2              /home/aln/miniconda3/envs/python2
root                 /home/aln/miniconda3
```

> **NB:** By default there is also root environment, if you have many concurrent tasks/projects better to separate different logic between environments, so you can easily deploy needed env somewhere else without installing unnecessary stuff.

Activate new env and install particular fastqc version:

```bash
conda activate python2
conda install fastqc=0.11.4
conda list
python --version
```

How to remove particular package or environment:

```bash
# Remove package fastqc from environment old
conda remove --name python2 fastqc
# Remove environment test entirely
conda remove --name python2 --all
conda info --envs
```

If you are not sure in which channel the package is exactly, you can look up on [http://anaconda.org](http://anaconda.org/) and install using following command without adding particular channel:

```bash
conda install --channel https://conda.anaconda.org/pandas bottleneck
# Alternatively
conda install -c pandas bottleneck
```

Not all the packages are available from conda repos, but you can install more with pip (stands for "Pip Installs Packages") package management system, which is used to install and manage software packages written in Python. Pip cannot manage envs and so on, it will just install the package into current conda env.

```bash
 pip install see
```

If you need to update conda use the command below, it also tells you about other packages that will be automatically updated or changed with the update.

```bash
conda --version
conda update conda
```

For the particular packages update use:

```bash
conda update fastqc
```

Very important function is exporting env file and creating new env based on that:

```bash
conda activate test
conda env export > test.yml
```

Check the content of the file:

```bash
(ngschool) aln@aln-vb:~$ cat test.yml 
name: ngschool
channels:
- bioconda
- conda-forge
- defaults
dependencies:
- htop=2.0.2=0
- ncurses=5.9=10
prefix: /home/aln/miniconda3/envs/test
```

You can see that the environment description file structure if very simple, you can create such file from scratch without exporting. Let's change environment name and try to create new env based on edited file:

```bash
mv test.yml copy.yml
# Edit with nano, when you're done press CTRL+X, then 'Y'
nano copy.yml
conda env create -f copy.yml
# List all the anvs
conda info --envs
```

This way you can easily copy \*.yml file on another computer and create identical environment as on your initial host. But if you need to clone the env within the same computer the following command is useful:

```bash
conda create --name clone --clone test
```

Finally you can deactivate environment using:

```bash
conda deactivate
```

##### Conda and R

> NB: Don't blindly run following commands, too easy to ruin everything!!!

The official conda manual suggests following commands:

```bash
# Install number of R packages together with r-base
conda install r-essentials
# Update
conda update r-essentials
# Update particular R package
conda update r-plyr
```

However, better way is to install latest r-base and use inbuilt R functions for install and update \(or with Bioconductor BiocLite\).

```bash
conda search r-base
conda install r-base -c conda-forge
```

Within R run:

```bash
install.packages("ggplot2")
```

If you are inside conda environment and didn't mess up anything the packages will be installed into `~/miniconda3/envs/clone/lib/R/library`. So you will have perfect separation of environments.


#### Compiling from source code

TODO:
* make
* cmake

### Virtualization

TODO: 
* VirtualBox
* Docker
* OpenStack
* Vagrant