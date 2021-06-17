SET PASSWORD = PASSWORD('admin123'); 
update mysql.user set plugin = 'mysql_native_password' where User='root'; 
FLUSH PRIVILEGES;
