 #!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install XCache for LNMP V1.0  ,  Written by Licess \n"
printf "=======================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install XCache for lnmp \n"
printf "\n"
printf "more information please visit http://www.lnmp.org \n"
printf "=======================================================================\n"
cur_dir=$(pwd)
        
	ver="new"
	echo "Which version do you want to install:"
	echo "Install XCache 2.0.0 please type: old"
	echo "Install XCache 3.0.1 please type: new"
	read -p "Type old or new (Default install XCache 3.0.1):" ver
	if [ "$ver" = "" ]; then
		ver="new"
	fi

	if [ "$ver" = "old" ]; then
		echo "You will install XCache 2.0.0"
	elif [ "$ver" = "new" ]; then 
		echo "You will install XCache 3.0.1"
	else
		echo "Input error,please input old or new !"
		echo "Please Rerun $0"
		exit 1
	fi

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`


printf "=========================== Install xcache ======================\n"
if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/xcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/xcache.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/xcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/xcache.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/xcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/xcache.so
fi

cur_php_version=`/usr/local/php/bin/php -v`
if [[ "$cur_php_version" =~ "PHP 5.2." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/xcache.so"
elif [[ "$cur_php_version" =~ "PHP 5.3." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/xcache.so"
elif [[ "$cur_php_version" =~ "PHP 5.4." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/xcache.so"
fi

cpu_count=`cat /proc/cpuinfo |grep -c processor`

function install_old_xcache
{
if [ -s xcache-2.0.1 ]; then
	rm -rf xcache-2.0.1/
fi
wget -c http://soft.vpser.net/web/xcache/xcache-2.0.1.tar.gz
tar zxvf xcache-2.0.1.tar.gz
cd xcache-2.0.1/
/usr/local/php/bin/phpize
./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../

sed -i '/;xcache/,/;xcache end/d' /usr/local/php/etc/php.ini
cat >>/usr/local/php/etc/php.ini<<EOF
;xcache
[xcache-common]
zend_extension = $zend_ext

;[xcache.admin]
;xcache.admin.enable_auth = On
;xcache.admin.user = "admin"
;run: echo -n "yourpassword" |md5sum |awk '{print $1}' to get md5 password
;xcache.admin.pass = "md5 password"

[xcache]
xcache.shm_scheme =        "mmap"
xcache.size  =               20M
; set to cpu count (cat /proc/cpuinfo |grep -c processor)
xcache.count =                 $cpu_count
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            4M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.readonly_protection = Off
; for *nix, xcache.mmap_path is a file path, not directory. (auto create/overwrite)
; Use something like "/tmp/xcache" instead of "/dev/*" if you want to turn on ReadonlyProtection
; different process group of php won't share the same /tmp/xcache
xcache.mmap_path =    "/dev/zero"
xcache.coredump_directory =   ""
xcache.experimental =        Off
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =           Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager =          Off
xcache.coveragedump_directory = ""
;xcache end
EOF

#\cp -R $cur_dir/xcache-2.0.1/admin /home/wwwroot/default/xcache
}

function install_new_xcache
{
if [ -s xcache-3.0.1 ]; then
	rm -rf xcache-3.0.1/
fi
wget -c http://soft.vpser.net/web/xcache/xcache-3.0.1.tar.gz
tar zxvf xcache-3.0.1.tar.gz
cd xcache-3.0.1/
/usr/local/php/bin/phpize
./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../

sed -i '/;xcache/,/;xcache end/d' /usr/local/php/etc/php.ini
cat >>/usr/local/php/etc/php.ini<<EOF
;xcache
[xcache-common]
extension = xcache.so

;[xcache.admin]
;xcache.admin.enable_auth = On
;xcache.admin.user = "admin"
;run: echo -n "yourpassword" |md5sum |awk '{print $1}' to get md5 password
;xcache.admin.pass = "md5 password"

[xcache]
xcache.shm_scheme =        "mmap"
xcache.size  =               20M
; set to cpu count (cat /proc/cpuinfo |grep -c processor)
xcache.count =                 $cpu_count
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            4M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.readonly_protection = Off
; for *nix, xcache.mmap_path is a file path, not directory. (auto create/overwrite)
; Use something like "/tmp/xcache" instead of "/dev/*" if you want to turn on ReadonlyProtection
; different process group of php won't share the same /tmp/xcache
xcache.mmap_path =    "/dev/zero"
xcache.coredump_directory =   ""
xcache.experimental =        Off
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =           Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager =          Off
xcache.coveragedump_directory = ""
;xcache end
EOF

#\cp -R htdocs /home/wwwroot/default/xcache
}

if [ "$ver" = "old" ]; then
	install_old_xcache
else
	install_new_xcache
fi

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

printf "===================== install xcache completed ===================\n"
printf "Install xcache completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install xcache for LNMP V1.0  ,  Written by Licess \n"
printf "=======================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install xcache for lnmp \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "=======================================================================\n"