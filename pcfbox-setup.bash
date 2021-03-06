#!/usr/bin/env bash
#
# This script installs a selection of tools useful to operate a PCF
# platform. It is meant to work on an Ubuntu 16.04 machine.
set -e -x

# Basic tools
PACKAGES="docker.io git mysql-client traceroute"

# packages needed to install cf-uaac
PACKAGES="$PACKAGES ruby ruby-dev make g++"

BINARIES=(
    bosh
    pivnet
    om
    docker-compose
    fly
)
BIN_URLS=(
    "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.1.2-linux-amd64"
    "https://github.com/pivotal-cf/pivnet-cli/releases/download/v0.0.54/pivnet-linux-amd64-0.0.54"
    "https://github.com/pivotal-cf/om/releases/download/0.41.0/om-linux"
    "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-Linux-x86_64"
    "https://github.com/concourse/concourse/releases/download/v4.2.1/fly_linux_amd64"
)
BIN_SHAS=(
    "8afb3f5b64ba365aa38acb733a57bedd789b1e27"
    "fd4cbb924b50f4e3fb9487babd5c080f1d629569"
    "d0d8890b014514c9fa53b70badf574807b149efa"
    "9303600664184658b7124d0a65f9e12a4d672708"
    "7b0805adfba328d09cfa7ac377777cb6e270d66f"
)

function download_file() {
	BIN=$1
	SHA=$2
	URL=$3
	if [ ! -f $BIN ]; then
		echo "Downloading $BIN from $URL"
		wget -q -O $BIN $URL
	fi
	echo "$SHA $BIN" > ${BIN}.sha
	if ! sha1sum -c ${BIN}.sha; then
		echo "ERROR: ${BIN} checksum failed"
		exit 1
	fi
}

echo "!!! Beware !!! The packages available in Ubuntu Trusty 14.04 are too old to allow installing cf-uaac"
apt update
apt upgrade -y

echo "Installing distribution packages: $PACKAGES"
apt install -y $PACKAGES

echo "Installing binaries from internet"
for i in ${!BINARIES[@]}; do
	BIN=${BINARIES[$i]}
	if ! which $BIN; then
		download_file $BIN ${BIN_SHAS[$i]} ${BIN_URLS[$i]}
		chmod +x $BIN
		mv $BIN /usr/local/bin/
	fi
done

echo "Installing cf-cli package (not a distribution package)"
if ! which cf; then
	download_file cf-cli.deb "58f8a8207b20c3026abe648dc342e7f29f0b948e" "https://cli.run.pivotal.io/stable?release=debian64&source=github"
	dpkg -i cf-cli.deb
fi

echo "Installing terraform CLI (zip file)"
if ! which terraform; then
        download_file terraform.zip "db6209b633eb2b559b3139933378293820e90d70" "https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip"
        unzip terraform.zip
        mv terraform /usr/local/bin/
fi

echo "Install cf-uaac gem"
gem install cf-uaac


# Add every users to the docker group
for user in $(ls /home/); do
    addgroup --quiet $user docker
done

# Reboot if required
if [ -f /var/run/reboot-required ]; then
    cat /var/run/reboot-required
    cat /var/run/reboot-required.pkgs
    reboot
fi
