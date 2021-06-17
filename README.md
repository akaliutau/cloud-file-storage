
About 
=======

This is an implementation of cloud-based file storage, with primary backup on AWS S3.  


Overview
==========

Nextcloud is an open source software suite that can use storage capacity for saving, editing, and consuming a wide range of document types, including services like image/audio/video files hosting. Nextcloud also provides client applications that allow users on Linux/Windows/MacOS/Mobile OS to engage with media resources. 

Using Nextcloud, one can easily create your own private version of Dropbox or Google Drive, but on your terms and without having to worry about unexpected changes to availability or service/privacy agreements. Of course, there are some drawbacks - you have to support your own data-center.

Manual approach
================

Steps (1) and (2) can be omitted if you are already on Linux

1) Builds image with Ubuntu distribution and tag linux:20.04. Note the dot at the end of the command.
```
docker build -f Dockerfile-min -t linux:20.04 .
```

2) Instantiates container and connects it to standard console.
```
docker run -p 8100:80 -it linux:20.04 /bin/bash
```

3) Building a LAMP server 

Install core dependencies:
```
apt-get install -y apache2 php wget nano
```

Install extra dependencies:
```
apt-get install -y php7.4-gd php7.4-json php7.4-mysql php7.4-curl php7.4-mbstring php-intl php-imagick php7.4-xml php7.4-zip
```

Install maria db dependencies:
```
apt-get install -y mariadb-server systemctl
```

4) You can confirm the DB is running using direct command or systemctl:
```
mysql --version
mysql  Ver 15.1 Distrib 10.3.25-MariaDB, for debian-linux-gnu (x86_64) using readline 5.2
```

If not running, start it:
```
service mysql start
```

5) Securing DB

```
mysql -u root -p 
```

MariaDB might not let you log in unless you run the mysql command as sudo. If this happens, log in using sudo and provide the MariaDB password you created. Then run these three commands at the MySQL prompts (substituting your password for your-password):

```
SET PASSWORD = PASSWORD('admin123'); 
update mysql.user set plugin = 'mysql_native_password' where User='root'; 
FLUSH PRIVILEGES;
```

6) Configuring Apache

To ensure that Apache will be able to communicate with Nextcloud, there are a few relatively simple adjustments you’re going to have to make. First, you should enable a couple of Apache modules through the a2enmod tool (which is installed along with other apache packages). 

The rewrite module is used to rewrite URLs in real time as they’re moved between a client and the server. 
```
a2enmod rewrite
```

The headers module performs a similar function for HTTP headers.
```
a2enmod headers
```

After changing configuration activate it using the following command:
```
service apache2 restart
```

Make sure the apache is up and running by pointing the browser to the default public address:
```
http://localhost:8100/
```

7) Making custom apache configuration for Nextcloud

Placing Nextcloud’s data files in the default document root presents a potential security risk. I  prefer creating a new .conf file in the /etc/apache2/sites-available/ directory for each new service, so create a new config for Nextcloud using nextcloud.conf as a template:

```
docker cp nextcloud.conf <container_id>:/etc/apache2/sites-available/nextcloud.conf
```

Finally, create a symbolic link in the /etc/apache2/sites-enabled/ directory pointing to the nextcloud.conf file created in /etc/apache2/sites-available/:
```
ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf
```

When Apache starts, it reads the contents of /etc/apache2/sites-enabled/ looking for site configurations to load. Those configurations won’t actually exist in /etc/apache2/sites-enabled/, but there’ll be symbolic links to the real files in /etc/apache2/sites-available/

8) Downloading and unpacking Nextcloud 

Download the most recent Nextcloud package (19.0.7 in this case) from the Nextcloud Install page (https://nextcloud.com/install):

```
wget https://download.nextcloud.com/server/releases/nextcloud-19.0.7.tar.bz2
```

Unpacking a .tar.bz2 archive requires the xjf arguments, rather than the xzf you’d use for a .gz:
```
tar xjf nextcloud-19.0.7.tar.bz2
```

9) Installing Nextcloud

Copy the files recursively to include subdirectories and their contents:
```
cp -r nextcloud /var/www/
```
Apache will need full access to all the files in the Nextcloud directories in order to do its job. Many web servers use a special system user called www-data. The next command uses chown to turn the user and group ownership of all those files over to the web server user www-data:
```
chown -R www-data:www-data /var/www/nextcloud/
```

10) reboot the Apache:
```
service apache2 restart
```

and navigate browser to the  following address to open Nextcloud UI:
```
http://localhost:8100/nextcloud
```

The main page contains links to Nextcloud’s client apps and then dropped into the administration console you see in screenshots/nxc_main_page.png

11) Configuring Nextcloud

During the first start you have to create an admin's username/password and establish connection to db: provide username/password pair along with db name (f.e. cloud_db) and connection url, f.e. localhost:3306. 
Optionally one can install additional web apps (Calendar, etc).

Automated approach
===================

1) Use Dockerfile file to perform steps 1-10; perform step 11 manually:
```
docker build -f Dockerfile -t linux-nextcloud:20.04 .
```

2) Instantiate container and connects it to standard console.
```
docker run -p 8100:80 -it linux-nextcloud:20.04 /bin/bash
```

3) Execute the sql script:
```
mysql -u root -p < 010_init.sql;
```

5) Restart apache once again and navigate browser to the main page and complete the installation:
```
http://localhost:8100/nextcloud
```

References
===========
More about Nextcloud: [https://nextcloud.com/]


Notes
======

Useful commands

Get the list of images:

```
docker images -a
```

Get the list of containers:

```
docker ps
```

Clean up local docker registry:

```
docker image prune -a --force --filter "until=2021-01-04T00:00:00"
```

Clean up local docker registry from images with <none> tag:

```
docker rmi --force $(docker images -q --filter "dangling=true")
```


