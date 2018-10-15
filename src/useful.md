Here is the random list of useful things:

[Shared conda environment](useful.md#shared-conda-env)
[How to keep ssh session alive](useful.md#ssh-session)


### Shared conda env

```bash
# download miniconda
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
# install miniconda
bash Miniconda2-latest-Linux-x86_64.sh
# add path to the pre-configured shared environments to conda config file
echo 'envs_dirs:
 - /storage/kau/shared_conda/envs' > ~/.condarc
bash
# check if everything is ok and you see the envs
conda info -e
# activate needed env
source activate nameoftheenvironment
```

### SSH session

If you want to run some calculation overnight or have unstable connection it is important to keep the ssh session alive. For this purpose there is a number of software that allows to detach ssh session and keep it alive on the server. Classical example is `screen`, which also allows to multiplex a physical terminal between several processes.

```bash
# create named screen session
screen -S test
# press CTRL-A-D to detach the session and attach using
screen -r test
# if the session terminated abruptly, e.g. the connection broke, use
screen -rd test
# list available sessions
screen -ls
# more info
man screen

```

* Ctrl+a-c — create a new window
* Ctrl+a-" — visualize the opened windows
* Ctrl+a-p, Ctrl+a-n — switch with the previous/next window
* Ctrl+a-number — switch to the window number
* Ctrl+d — kill a window
