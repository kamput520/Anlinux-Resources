#!/data/data/com.termux/files/usr/bin/bash
folder=centos-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
wget https://github.com/kamput520/Anlinux-Resources/blob/master/Rootfs/CentOS/amd64/centos-rootfs-amd64.tar.xz
#wget "https://raw.githubusercontent.com/EXALAB/AnLinux-Resources/master/Rootfs/CentOS/${archurl}/centos-rootfs-${archurl}.tar.xz" -O $tarball
#wget "https://raw.github.com/kamput520/bold/AnLinux-Resources/master/Rootfs/CentOS/${archurl}/centos-rootfs-${archurl}.tar.xz" -O $tarball
#wget "https://github.com/kamput520/Anlinux-Resources/tree/master/Rootfs/CentOS/amd64/centos-rootfs-amd64.tar.xz" -O $tarball

	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xJf ${cur}/${tarball} --exclude='dev'||:
	
	echo "Setting up name server"
	echo "127.0.0.1 localhost" > etc/hosts
    echo "nameserver 8.8.8.8" > etc/resolv.conf
    echo "nameserver 8.8.4.4" >> etc/resolv.conf
	cd "$cur"
fi
mkdir -p centos-binds
mkdir -p centos-fs/tmp
bin=start-centos.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A centos-binds)" ]; then
    for f in centos-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b centos-fs/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball
echo "You can now launch CentOS with the ./${bin} script"
