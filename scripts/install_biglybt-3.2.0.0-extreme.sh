#!/bin/bash

set -e

BBTJAVAVERS=${BBTJAVAVERS:-17}
export DEBIAN_FRONTEND="noninteractive"
export BBTINSTSCR="/app/BiglyBT_Installer.sh"

if [ "$1" == "NOQUIET" ]; then
  unset BBTAUTOINST
else
  export BBTAUTOINST="-q"
fi

apt-get update
apt-get install -y --no-install-recommends openjdk-17-jre-headless webkit2gtk-driver libjna-java unzip
if grep -q '^assistive_technologies' /etc/java-17-openjdk/accessibility.properties; then
  sed -e 's/^assistive_technologies/#assistive_technologies/' -i /etc/java-17-openjdk/accessibility.properties
fi

chown ${SUDO_UID}:${SUDO_GID} /opt
sudo -u ${SUDO_USER} app_java_home="/usr/lib/jvm/java-17-openjdk-amd64/" ${BBTINSTSCR} ${BBTAUTOINST} -dir /opt/biglybt

# Install BiglyBT_3.2.0.0_20221014.zip
( set -e; cd /opt/biglybt; unzip -o /app/BiglyBT_3.2.0.0_20221014.zip )
echo "--patch-module=java.base=ghostfucker_utils.jar" >> ${HOME}/.biglybt/java.vmoptions
echo "--add-exports=java.base/sun.net.www.protocol=ALL-UNNAMED" >> ${HOME}/.biglybt/java.vmoptions
echo "--add-exports=java.base/sun.net.www.protocol.http=ALL-UNNAMED" >> ${HOME}/.biglybt/java.vmoptions
echo "--add-exports=java.base/sun.net.www.protocol.https=ALL-UNNAMED" >> ${HOME}/.biglybt/java.vmoptions
echo "--add-opens=java.base/java.net=ALL-UNNAMED" >> ${HOME}/.biglybt/java.vmoptions
echo "-Dorg.glassfish.jaxb.runtime.v2.bytecode.ClassTailor.noOptimize=true" >> ${HOME}/.biglybt/java.vmoptions
echo >> ${HOME}/.biglybt/java.vmoptions

chown -R ${SUDO_UID}:${SUDO_GID} ${HOME}/.biglybt /opt/biglybt
