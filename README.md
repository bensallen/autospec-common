## ClearLinux Package Build Environment Setup

* Find a directory location that has a reasonable amount of disk space, 40+GB. We'll refer to that below as ROOT_PATH.

```
git clone https://github.com/bensallen/autospec-common.git $ROOT_PATH/pkgs
```

### Autospec

```
git clone https://github.com/clearlinux/autospec ~/autospec
pip3 install toml pycurl
```

* Edit $ROOT_PATH/pkgs/scripts/setup.sh

Set ROOT_PATH. It will be the location of the yum repos, mock build directories, pkgs repo.

* Edit pkgs/common/Makefile.common, and set REPO_ROOT to $ROOT_PATH/repos based on above.

* Run setup.sh

```
sudo $ROOT_PATH/pkgs/scripts/setup.sh
```

## Build an existing package from Clear's repos

```
git clone https://github.com/clearlinux-pkgs/yum.git $ROOT_PATH/pkgs/yum
sudo make -C $ROOT_PATH/pkgs/yum
```

* Produced RPMs will be moved to the os, debug, or srpms repos under $ROOT_PATH/repos/

## Build a brand new package, in this case we're building a package of autospec with autospec 

```
sudo make -C $ROOT_PATH/pkgs URL=https://api.github.com/repos/clearlinux/autospec/tarball PKG_NAME=autospec
```

* URL can generally be any source tarball
* In case of problems see log files in $ROOT_PATH/pkgs/<PKG_NAME>/results

## Build the linux kernel, i.e. special case using mock only and no autospec

```
git clone https://github.com/clearlinux-pkgs/linux.git pkgs/linux
sudo make -C $ROOT_PATH/pkgs/linux BUILDTYPE=mock PKG_VERS=4.13.2-390
```
