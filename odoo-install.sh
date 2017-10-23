#!/bin/bash
################################################################################
# Script Instalacion Odoo 11.0 sobren Ubuntu 16.04 
#------------------------------------------------------------------------
# -----------------------------------------------------------------------
# Creamos un fichero de instalacion:
# sudo nano odoo-install.sh
# Lo convertimos en ejecutable
# sudo chmod +x odoo-install.sh
# Ejecutamos script de instalacion Odoo:
# ./odoo-install
################################################################################
##Parametros fijos
#odoo
OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
INSTALL_WKHTMLTOPDF="True"
OE_PORT="8069"
OE_VERSION="11.0"
OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"
##
###  WKHTMLTOPDF descarga de links
## === Ubuntu Trusty x64 & x32  
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Instalar  Dependencias
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install -y python3-pip
pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd
sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less less-plugin-clean-css
sudo apt-get install -y node-less
sudo apt-get install -y gdebi

#--------------------------------------------------
# Instalar Wkhtmltopdf 
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Instalar wkhtml ODOO 11 ----"
  #from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf No esta instalado debido a la eleccion del usuario!"
fi
	
echo -e "\n---- Crear usuario ODOO ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#Añadir usuario odoo al grupo sudo'ers.
sudo adduser $OE_USER sudo

echo -e "\n---- Crear directorios de Log ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Instalar ODOO
#--------------------------------------------------
echo -e "\n==== Instalacion ODOO Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/odoo $OE_HOME_EXT/

echo -e "\n---- Establecer permisos sobre las carpetas ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Crer configuracion del fichero del servidor"
sudo cp $OE_HOME_EXT/debian/odoo.conf /etc/${OE_CONFIG}.conf
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Cambiar configuracion del fichero configuracion del server"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/${OE_CONFIG}.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/${OE_CONFIG}.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
	

