#!/bin/bash
# ////////////////////////////////////////////////////////////////////////////////
# //BOCA Online Contest Administrator
# //    Copyright (C) 2003-2014 by BOCA Development Team (bocasystem@gmail.com)
# //
# //    This program is free software: you can redistribute it and/or modify
# //    it under the terms of the GNU General Public License as published by
# //    the Free Software Foundation, either version 3 of the License, or
# //    (at your option) any later version.
# //
# //    This program is distributed in the hope that it will be useful,
# //    but WITHOUT ANY WARRANTY; without even the implied warranty of
# //    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# //    GNU General Public License for more details.
# //    You should have received a copy of the GNU General Public License
# //    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ////////////////////////////////////////////////////////////////////////////////
# // Last modified 26/Aug/2015 by cassio@ime.usp.br
#///////////////////////////////////////////////////////////////////////////////////////////
echo "#############################################################"
echo "### $0 by cassio@ime.usp.br for Ubuntu 14.04.3 ###"
echo "### $0 modificado por rsaucedo@ipn.mx para Ubuntu 16.04 ###"
echo "#############################################################"

if [ "`id -u`" != "0" ]; then
  echo "Must be run as root"
  exit 1
fi

## REMOVE NOTIFICATIONS
# killall update-notifier
# if [ ! -f /usr/bin/update-notifier.orig ]; then
#   mv /usr/bin/update-notifier /usr/bin/update-notifier.orig
# fi
# echo "#!/bin/bash" >/usr/bin/update-notifier
# find /usr/lib -name notify-osd | xargs chmod -x
# killall notify-osd 2>/dev/null

echo "Instalando paquetes necesarios..."
apt-get -y install software-properties-common 2>/dev/null

for i in id chown chmod cut awk tail grep cat sed mkdir rm mv sleep apt-get add-apt-repository update-alternatives; do
  p=`which $i`
  if [ -x "$p" ]; then
    echo -n ""
  else
    echo command "$i" not found
    exit 1
  fi
done
sleep 2

echo "$0" | grep -q "install.*sh"
if [ $? != 0 ]; then
  echo "Make the install script executable (using chmod) and run it directly, like ./install.sh"
else  

if [ "$1" != "alreadydone" ]; then
  echo "It is recommended that you run the commands"
  echo "  apt-get update; apt-get upgrade"
  echo "by your own before running this script. If you have already done it,"
  echo "please run the script as"
  echo "   ./install.sh alreadydone"
  exit 1
fi

if [ ! -r /etc/lsb-release ]; then
  echo "File /etc/lsb-release not found. Is this a ubuntu or debian-like distro?"
  exit 1
fi
. /etc/lsb-release

echo "============================================================="
echo "========= UNINSTALLING SOME UNNECESSARY PACKAGES  ==========="
echo "============================================================="
apt-get -y purge libreoffice-common libreoffice-base-core 
apt-get -y purge thunderbird
apt-get -y purge unity-lens-shopping
apt-get -y purge unity-webapps-common
apt-get -y install sysvinit-utils
gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']" >/dev/null 2>&1
apt-get -y autoremove

echo "=============================================================="
echo "============== CHECKING FOR OTHER APT SERVERS  ==============="
echo "=============================================================="
echo "============== CHECKING FOR canonical.com APT SERVER  ========"
cd 
grep -q "^[^\#]*deb http://archive.canonical.com.* $DISTRIB_CODENAME .*partner" /etc/apt/sources.list
if [ $? != 0 ]; then
  add-apt-repository "deb http://archive.canonical.com/ubuntu $DISTRIB_CODENAME partner"
fi
apt-add-repository -y ppa:webupd8team/sublime-text-3

apt-get -y update
apt-get -y upgrade

libCppdev=`apt-cache search libstdc++ | grep "libstdc++6-.*-dev " | sort | tail -n1 | cut -d' ' -f1`
if [ "$libCppdev" == "" ]; then
  echo "libstdc++6-*-dev not found"
  exit 1
fi
libCppdbg=`apt-cache search libstdc++ | grep "libstdc++6-.*-dbg " | sort | tail -n1 | cut -d' ' -f1`
if [ "$libCppdbg" == "" ]; then
  echo "libstdc++6-*-dbg not found"
  exit 1
fi
libCppdoc=`apt-cache search libstdc++ | grep "libstdc++6-.*-doc " | sort | tail -n1 | cut -d' ' -f1`
if [ "$libCppdoc" == "" ]; then
  echo "libstdc++6-*-doc not found"
  exit 1
fi

echo "====================================================================="
echo "================= installing packages needed by BOCA  ==============="
echo "====================================================================="

apt-get -y install zenity apache2 eclipse-pde eclipse-rcp eclipse-platform eclipse-jdt eclipse-cdt eclipse emacs \
  evince g++ gcc gedit scite libstdc++6 makepasswd manpages-dev php5-cli php5-mcrypt openjdk-7-dbg openjdk-7-jdk \
  php5 php5-pgsql postgresql postgresql-client postgresql-contrib quota sharutils default-jdk openjdk-7-doc \
  vim-gnome geany geany-plugin-addons geany-plugins geany-plugin-debugger default-jre sysstat \
  vim xfce4 $libCppdev $libCppdoc $libCppdbg php5-gd stl-manual gcc-doc debootstrap schroot c++-annotations \
  sublime-text-installer libgnomekbd-common
if [ $? != 0 ]; then
  echo ""
  echo "ERROR running the apt-get -- must check if all needed packages are available"
  exit 1
fi
apt-get -y autoremove
apt-get -y clean

for i in makepasswd useradd update-rc.d; do
  p=`which $i`
  if [ -x "$p" ]; then
    echo -n ""
  else
    echo command "$i" not found
    exit 1
  fi
done


echo "=================================================================="
echo "=============  creating user icpc with password icpc ============="
echo "=================================================================="

mkdir -p /etc/skel/Desktop/
cat <<EOF > /etc/skel/Desktop/javadoc.desktop
[Desktop Entry]
Version=1
Name=Java API
Comment=Java API
Exec=firefox /usr/share/doc/openjdk-7-jre-headless/api/index.html
Terminal=false
Type=Application
EOF
cat <<EOF > /etc/skel/Desktop/stldoc.desktop
[Desktop Entry]
Version=1
Name=C++ STL
Comment=C++ STL
Exec=firefox /usr/share/doc/stl-manual/html/index.html
Terminal=false
Type=Application
EOF
cat <<EOF > /etc/skel/Desktop/cppannotations.desktop
[Desktop Entry]
Version=1
Name=C++ Annotations
Comment=C++ Annotations
Exec=firefox /usr/share/doc/c++-annotations/html/index.html
Terminal=false
Type=Application
EOF
[ -f /usr/share/applications/eclipse.desktop ] && cp /usr/share/applications/eclipse.desktop /etc/skel/Desktop/
[ -f /usr/share/applications/gedit.desktop ] && cp /usr/share/applications/gedit.desktop /etc/skel/Desktop/
[ -f /usr/share/applications/emacs23.desktop ] && cp /usr/share/applications/emacs23.desktop /etc/skel/Desktop/
[ -f /usr/share/applications/emacs24.desktop ] && cp /usr/share/applications/emacs24.desktop /etc/skel/Desktop/
cp /usr/share/applications/gnome-terminal.desktop /etc/skel/Desktop/
chmod 755 /etc/skel/Desktop/*.desktop

if [ "`which gconftool`" != "" ]; then
	su - icpcadmin -c "gconftool -s -t bool /apps/update-notifier/auto_launch false"
	su - icpc -c "gconftool -s -t bool /apps/update-notifier/auto_launch false"
fi

grep -q icpcadmin /etc/ssh/sshd_config
if [ "$?" != "0" ]; then
	echo "DenyUsers icpc icpcadmin" >> /etc/ssh/sshd_config
	ps auxw |grep sshd|grep -vq grep
	if [ "$?" == "0" ]; then
		service ssh reload
	fi
fi

pass=`echo -n icpc | makepasswd --clearfrom - --crypt-md5 | cut -d'$' -f2-`
pass=\$`echo $pass`
id -u icpc >/dev/null 2>/dev/null
if [ $? != 0 ]; then
 useradd -d /home/icpc -k /etc/skel -m -p "$pass" -s /bin/bash -g users icpc
else
 usermod -d /home/icpc -p "$pass" -s /bin/bash -g users icpc
 echo "user icpc already exists"
fi

lightdmfile=/etc/lightdm/lightdm.conf
if [ -d "`dirname $lightdmfile`" ]; then
  echo "=============================================================="
  echo "====== disabling guest account on lightdm  ========"
  echo "=============================================================="
  echo -e "[SeatDefaults]\n" > $lightdmfile
  echo -e "allow-guest=false\ngreeter-hide-users=true\ngreeter-show-remote-login=false\ngreeter-show-manual-login=true\n" >> $lightdmfile
fi

# echo "====================================================================================="
# echo "============ updating grub boot loader to make it password protected  ==============="
# echo "====================================================================================="

# grep -q "^[^\#]*password" /etc/grub.d/40_custom
# if [ $? != 0 ]; then
#   echo "updated with new password (if needed, see the password at /etc/grub.d/40_custom)"
#   echo -e "set superusers=\"root\"" >> /etc/grub.d/40_custom
#   echo -e "password root `makepasswd`" >> /etc/grub.d/40_custom
#   chmod go-rw /etc/grub.d/40_custom
#   grub-mkconfig > /boot/grub/grub.cfg
#   chmod go-rw /boot/grub/grub.cfg
# fi
# echo "grub loader configured with password (if needed, see the password at /etc/grub.d/40_custom)"



echo "=============================================================="
echo "============= INSTALLING SCRIPTS at /etc/icpc  ==============="
echo "=============================================================="
mkdir -p /etc/icpc
chown root.root /etc/icpc
chmod 755 /etc/icpc
cat <<EOF > /etc/icpc/installscripts.sh
#!/bin/bash
echo "================================================================================"
echo "========== downloading config files from www.ime.usp.br/~cassio/boca  =========="
echo "================================================================================"
iptables -F
wget -O /tmp/.boca.tmp "http://www.ime.usp.br/~cassio/boca/icpc.etc.date.txt"
echo ">>>>>>>>>>"
echo ">>>>>>>>>> Downloading scripts release \`cat /tmp/.boca.tmp\`"
echo ">>>>>>>>>>"

if [ "\$1" == "" ]; then
wget -O /tmp/.boca.tmp "http://www.ime.usp.br/~cassio/boca/icpc.etc.ver.txt"
icpcver=\`cat /tmp/.boca.tmp\`
else
icpcver=\$1
fi
echo "Looking for version \$icpcver from http://www.ime.usp.br/~cassio/boca/"

rm -f /tmp/icpc.etc.tgz
wget -O /tmp/icpc.etc.tgz "http://www.ime.usp.br/~cassio/boca/download.php?filename=icpc-\$icpcver.etc.tgz"
if [ "\$?" != "0" -o ! -f /tmp/icpc.etc.tgz ]; then
  echo "ERROR downloading file icpc-\$icpcver.etc.tgz. Aborting *****************"
  exit 1
fi
grep -qi "bad parameters" /tmp/icpc.etc.tgz
if [ "\$?" == "0" ]; then
  echo "ERROR downloading file icpc-\$icpcver.etc.tgz. Aborting *****************"
  exit 1
fi

cd /etc
di=\`date +%s\`

echo "=============================================================="
echo "====================== BACKUPING CONFIG FILES ==============="

for i in \`tar tvzf /tmp/icpc.etc.tgz | awk '{ print \$6; }'\`; do
  if [ -f "\$i" ]; then
    bn=\`basename \$i\`
    dn=\`dirname \$i\`
    mv \$i \$dn/.\$bn.bkp.\$di
    chmod 600 \$dn/.\$bn.bkp.\$di
  fi
done

echo "=============================================================="
echo "====================== EXTRACTING CONFIG FILES ==============="
tar -xkvzf /tmp/icpc.etc.tgz
for i in \`tar tvzf /tmp/icpc.etc.tgz | awk '{ print \$6; }'\`; do
  chown root.root \$i
  chmod o-w,u+rx \$i
done
EOF
chmod 750 /etc/icpc/installscripts.sh
/etc/icpc/installscripts.sh $3

service procps start

grep -q "quota" /etc/fstab
if [ $? != 0 ]; then
  cp -f /etc/fstab /etc/fstab.bkp.$di
  sed "s/relatime/quota,relatime/" < /etc/fstab.bkp.$di > /etc/fstab.bkp.$di.1
  sed "s/errors=remount-ro/quota,errors=remount-ro/" < /etc/fstab.bkp.$di.1 > /etc/fstab
fi

echo "============================================================"
echo "===================== SETTING UP USER QUOTA  ==============="
echo "============================================================"

for i in `mount | grep gvfs | cut -d' ' -f3`; do
  umount $i
done

mount / -o remount
quotaoff -a 2>/dev/null
quotacheck -M -a
quotaon -a
setquota -u postgres 0 3000000 0 10000 -a
setquota -u icpc 0 500000 0 10000 -a
setquota -u nobody 0 500000 0 10000 -a
setquota -u www-data 0 1500000 0 10000 -a

echo "=============================================================="
echo "================= UPDATING rc.local symlinks   ==============="
echo "=============================================================="

#update-rc.d rc.local defaults
update-rc.d -f cups remove
apt-get -y clean

#echo "=============================================================="
#echo "====================== SETTING UP IPs and PASSWORDs (server config follows)  ==============="
#
/etc/icpc/restart.sh
#/etc/icpc/setup.sh

startscript="NOTOK"
if [ -d "`dirname $lightdmfile`" ]; then
  startscript="OK"
  [ -f $lightdmfile ] && grep -q "^[^\#]*greeter-setup-script=/etc/icpc/setup.sh" $lightdmfile
  if [ $? != 0 ]; then
    echo "greeter-setup-script=/etc/icpc/setup.sh" >> $lightdmfile
  fi
fi
if [ -d /etc/gdm/Init ]; then
  startscript="OK"
  echo "======================================================================================"
  echo "========== UPDATING /etc/gdm/Init/Default TO PROVIDE CONFIG AT STARTUP ==============="
  echo "======================================================================================"
  echo -e "#!/bin/bash\n[ -x /etc/icpc/setup.sh ] && /etc/icpc/setup.sh\n\n" > /tmp/.boca.tmp
  cat /etc/gdm/Init/Default >> /tmp/.boca.tmp
  mv /tmp/.boca.tmp /etc/gdm/Init/Default
  chmod 755 /etc/gdm/Init/Default
fi
if [ "$startscript" != "OK" ]; then
  echo "************ STARTUP CALL OF SCRIPTS NOT CONFIGURED **************"
  echo "****** neither /etc/gdm/Init nor /etc/lightdm/lightdm.conf were found ************"
fi

if [ -f /etc/icpc/createbocajail.sh ]; then
	chmod 750 /etc/icpc/createbocajail.sh
	if [ "$2" != "notbuildjail" ]; then
		/etc/icpc/createbocajail.sh
	fi
else
	echo "************** SCRIPT TO CREATE BOCAJAIL NOT FOUND -- SOMETHING LOOKS WRONG ***************"
fi

# BOCA CONFIG
if [ -f /etc/icpc/installboca.sh ]; then
	chmod 750 /etc/icpc/installboca.sh
    /sbin/iptables -F
	/etc/icpc/installboca.sh "$3" "$4"
else
	echo "************* SCRIPT TO INSTALL BOCA NOT FOUND -- SOMETHING IS WRONG -- I CANT INSTALL BOCA **************"
fi

fi
