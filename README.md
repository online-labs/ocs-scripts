# Scaleway Image Toolbox

This repository contains the tools, documentations, examples and contents for building, debug and running images on [Scaleway](https://www.scaleway.com/).


## Getting start

You can look the docker-based [hello-world](https://github.com/scaleway/image-helloworld) image.

See [Building images on Scaleway with Docker](http://www.slideshare.net/manfredtouron/while42-paris13-scaleway) presentation on Slideshare.


## Repository

This repository contains :

- [Common scripts](#how-to-download-the-common-scripts-on-a-target-image) used in the images (upstart, sysvinit, openrc, common helpers, etc)
- The [Builder](https://github.com/scaleway/image-tools/tree/master/scripts)


## Official images built with **image-tools**

Official images are available when creating a new server

- Distributions
  - [Ubuntu](https://github.com/scaleway/image-ubuntu) (available tags: **14.04**, **14.10**, **15.04**)
  - [Debian](https://github.com/scaleway/image-debian)
  - [Fedora](https://github.com/scaleway/image-fedora)
  - [Alpine Linux](https://github.com/scaleway/image-alpine)
  - [Archlinux](https://github.com/scaleway/image-archlinux)
  - [Opensuse](https://github.com/scaleway/image-opensuse) (Work in progress)
  - [Slackware](https://github.com/scaleway/image-slackware) (Work in progress)
  - [Busybox](https://github.com/scaleway/image-busybox) (Work in progress)
- Apps
  - [Docker](https://github.com/scaleway/image-app-docker)
  - [Ghost](https://github.com/online-labs/image-app-ghost)
  - [Owncloud](https://github.com/online-labs/image-app-owncloud)
  - [Pydio](https://github.com/online-labs/image-app-pydio)
  - [Wordpress](https://github.com/online-labs/image-app-wordpress)
  - [OpenVPN](https://github.com/online-labs/image-app-openvpn) (Work in progress)
  - [Seedbox](https://github.com/online-labs/image-app-seedbox) (Work in progress)
  - [Timemachine](https://github.com/online-labs/image-app-timemachine) (Work in progress)
  - [Mesos](https://github.com/online-labs/image-app-mesos) (Work in progress)
  - [Proxy](https://github.com/online-labs/image-app-proxy) (Work in progress)
  - [Node.js](https://github.com/online-labs/image-app-nodejs) (Work in progress)
  - Discourse (Planned)
  - Gitlab (Planned)
- Services (those images are not available when creating a new server)
  - [Try-it](https://github.com/online-labs/image-service-tryit)
  - [Rescue](https://github.com/online-labs/image-service-rescue)


## Unofficial images built with **image-tools**

Unofficial images are only available to those who build them.

For the one using the Docker-based builder, they can also be used as a parent image.

- [moul's devbox](https://github.com/moul/ocs-image-devbox): Based on the [official Docker image](https://github.com/online-labs/image-app-docker)
- [moul's bench](https://github.com/moul/ocs-image-bench): Based on the [official Ubuntu image](https://github.com/online-labs/image-ubuntu)
- [mxs' 3.2 perf](https://github.com/aimxhaisse/image-ocs-perf-3.2): Based on the [Ubuntu image](https://github.com/online-labs/image-ubuntu)
- [mxs' 3.17 perf](https://github.com/aimxhaisse/image-ocs-perf-3.17): Based on the [Ubuntu image](https://github.com/online-labs/image-ubuntu)


# Builder

We use the [Docker's building system](https://docs.docker.com/reference/builder/) to build, debug and even run the generated images.

We added some small hacks to let the image be fully runnable on a C1 server without Docker.

The advantages are :

- Lots of available base images and examples on the [Docker's official registry](https://registry.hub.docker.com)
- Easy inheritance between images ([app-timemachine](https://github.com/online-labs/image-app-timemachine) image inherits from [app-openvpn](https://github.com/online-labs/image-app-openvpn) image which inherits from [ubuntu](https://github.com/online-labs/image-ubuntu) image)
- Easy debug with `docker run ...`
- A well-known build format file (Dockerfile)
- Docker's amazing builder advantages (speed, cache, tagging system)


## Install

The minimal command to install an image on an attached volume :

    # write the image to /dev/nbd1
    $ make install

## Commands

    # Clone the hello world docker-based app on an armhf server with Docker
    $ git clone https://github.com/scaleway/image-helloworld.git

    # Run the image in Docker
    $ make shell

    # push the rootfs.tar on s3 (requires `s3cmd`)
    $ make publish_on_s3 S3_URL=s3://my-bucket/my-subdir/

    # push the image on docker registry
    $ make release DOCKER_NAMESPACE=myusername

    # remove build directories
    $ make clean

    # remove build directories and docker images
    $ make fclean


Debug commands

    # push the rootfs.tar.gz on s3 (requires `s3cmd`)
    $ make publish_on_s3.tar.gz S3_URL=s3://my-bucket/my-subdir/

    # push the rootfs.sqsh on s3 (requires `s3cmd`)
    $ make publish_on_s3.sqsh S3_URL=s3://my-bucket/my-subdir/

    # build the image in a rootfs directory
    $ make build

    # build a tarball of the image
    $ make rootfs.tar

    # build a squashfs of the image
    $ make rootfs.sqsh


## Install builder's `.mk` files

```bash
# From a shell
wget -qO - https://raw.githubusercontent.com/scaleway/image-tools/master/scripts/install.sh | bash
# or
wget -qO - http://j.mp/scw-image-tools | bash
```

Or from a Makefile ([example](https://github.com/scaleway/image-helloworld/blob/master/Makefile))

```Makefile
## Image tools  (https://github.com/scaleway/image-tools)
all:    docker-rules.mk
docker-rules.mk:
    wget -qO - http://j.mp/scw-image-tools | bash
-include docker-rules.mk
```


# Unit test a running instance

At runtime, you can proceed to unit tests by calling

```bash
# using curl
SCRIPT=$(mktemp); curl -s -o ${SCRIPT} https://raw.githubusercontent.com/scaleway/image-tools/master/scripts/unit.bash && bash ${SCRIPT}
# using wget
SCRIPT=$(mktemp); wget -qO ${SCRIPT} https://raw.githubusercontent.com/scaleway/image-tools/master/scripts/unit.bash && bash ${SCRIPT}
```

# Image check list

List of features, scripts and modifications to check for proper **scaleway** image creation.

- Add sysctl entry `vm.min_free_kbytes=65536`
- Configure NTP to use internal server.
- Configure SSH to only accept login through public keys and deny environment customization to avoid errors due to users locale.
- Configure default locale to `en_US.UTF-8`.
- Configure network scripts to use DHCP and enable them.
  Although not, strictly speaking, needed since kernel already has IP address and gateway this allows DHCP hooks to be called for setting hostname, etc.
- Install custom DHCP hook for hostname to set entry in `/etc/hosts` for software using `getent_r` to get hostname.
- Install scripts to fetch SSH keys
- Install scripts to fetch kernel modules.
- Install scripts to connect and/or mount NBD volumes.
- Install scripts to manage NBD root volume.
- Disable all physical TTY initialization.
- Enable STTY @ 9600 bps.

Before making the image public, do not forget to check it boots, stops and restarts from the OS without any error (most notably kernel) since a failure could lead to deadlocked instances.


# How to download the common scripts on a target image

Those scripts are mainly used in the base image (distrib) but can sometimes be useful in the app images (inherited from distrib).o

An example of usage in the [Ubuntu image](https://github.com/scaleway/image-ubuntu/blob/9cd0f287a1977a55b74b1a37ecb1c03c8ce55c85/14.04/Dockerfile#L12-L17)

```bash
wget -qO - http://j.mp/scw-skeleton | bash -e

# Using upstart flavor
wget -qO - http://j.mp/scw-skeleton | FLAVORS=upstart bash -e
# Using sysvinit, docker-based and common flavors
wget -qO - http://j.mp/scw-skeleton | FLAVORS=sysvinit,docker-based,common bash -e

# Specific GIT branch
wget -qO - http://j.mp/scw-skeleton | FLAVORS=upstart BRANCH=feature-xxx bash -e

# Use curl
curl -L -q http://j.mp/scw-skeleton | DL=curl bash -e

# Alternative URL
wget -qO - https://raw.githubusercontent.com/scaleway/image-tools/master/scripts/install.sh | ... bash -e
```

A running instance can be updated by calling the same commands.
It is planned to to create packages (.deb) for distributions.


# Licensing

© 2014-2015 Scaleway - [MIT License](https://github.com/scaleway/image-tools/blob/master/LICENSE).
A project by [![Scaleway](https://avatars1.githubusercontent.com/u/5185491?v=3&s=42)](https://www.scaleway.com/)
