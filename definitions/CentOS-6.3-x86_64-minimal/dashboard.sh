# Graphite dependencies
yum -y install pycairo mod_python Django django-tagging python-ldap python-memcached python-sqlite2 python-twisted bitmap bitmap-fonts python-devel python-crypto pyOpenSSL httpd mod_wsgi python-zope-interface memcached

# Install Node
NODE_VERSION=v0.8.15
wget http://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION.tar.gz
tar xvf node-$NODE_VERSION.tar.gz
pushd node-$NODE_VERSION
./configure
make install
popd
rm -rf node-$NODE_VERSION.tar.gz

# Install statsd 
pushd /opt
git clone git://github.com/etsy/statsd.git
popd

# Download and Install Graphite
GRAPHITE_BASE=0.9
GRAPHITE_VERSION=0.9.9
wget https://launchpad.net/graphite/$GRAPHITE_BASE/$GRAPHITE_VERSION/+download/whisper-$GRAPHITE_VERSION.tar.gz
wget https://launchpad.net/graphite/$GRAPHITE_BASE/$GRAPHITE_VERSION/+download/carbon-$GRAPHITE_VERSION.tar.gz
wget https://launchpad.net/graphite/$GRAPHITE_BASE/$GRAPHITE_VERSION/+download/graphite-web-$GRAPHITE_VERSION.tar.gz

tar xvf whisper-$GRAPHITE_VERSION.tar.gz
pushd whisper-$GRAPHITE_VERSION
sudo python setup.py install
popd
rm -rf whisper-$GRAPHITE_VERSION

tar xvf carbon-$GRAPHITE_VERSION.tar.gz
pushd carbon-$GRAPHITE_VERSION
sudo python setup.py install
popd
rm -rf carbon-$GRAPHITE_VERSION

tar xvf graphite-web-$GRAPHITE_VERSION.tar.gz
pushd graphite-web-$GRAPHITE_VERSION
sudo python setup.py install
popd
rm -rf graphite-web-$GRAPHITE_VERSION

# configure apache
cat > /etc/httpd/conf.d/graphite.conf <<EOF
 Listen 8080
<VirtualHost *:8080>
  DocumentRoot "/opt/graphite/webapp"
  ErrorLog logs/graphite_error_log
  TransferLog logs/graphite_access_log
  LogLevel warn
  WSGIDaemonProcess graphite processes=5 threads=5 display-name=" {GROUP}" inactivity-timeout=120
  WSGIProcessGroup graphite
  WSGIScriptAlias / /opt/graphite/conf/graphite.wsgi
  Alias /content/ /opt/graphite/webapp/content/
  <Location "/content/">
   SetHandler None
  </Location>
  Alias /media/ "/usr/lib/python2.6/site-packages/django/contrib/admin/media/"
  <Location "/media/">
   SetHandler None
  </Location>
  <Directory /opt/graphite/conf/>
   Order deny,allow
   Allow from all
  </Directory>
</VirtualHost>
EOF

echo "WSGISocketPrefix /var/run/wsgi" >> /etc/httpd/conf.d/wsgi.conf 


# configure graphite
pushd /opt/graphite/conf
cp carbon.conf.example carbon.conf
cp storage-schemas.conf.example storage-schemas.conf
cp graphite.wsgi.example graphite.wsgi
popd

pushd /opt/graphite/webapp/graphite/
python manage.py syncdb --noinput
popd

pushd /opt/graphite/webapp/graphite
cp local_settings.py.example local_settings.py
popd

# Need to setup permissions on the storage directory so apache can write to it
chown -R apache:apache /opt/graphite/storage/

cat > /etc/init.d/carbon-cache <<EOF
#!/bin/bash
#
# This is used to start/stop the carbon-cache daemon

# chkconfig: - 90 01
# description: Starts the carbon-cache daemon

# Source function library.
. /etc/init.d/functions

RETVAL=0
prog="carbon-cache"

start_relay () {
    /usr/bin/python /opt/graphite/bin/carbon-relay.py start
        RETVAL=\$?
        [ \$RETVAL -eq 0 ] && success || failure
        echo
        return \$RETVAL
}

start_cache () {
     /usr/bin/python /opt/graphite/bin/carbon-cache.py start
        RETVAL=\$?
        [ \$RETVAL -eq 0 ] && success || failure
        echo
        return \$RETVAL
}

stop_relay () {
    /usr/bin/python /opt/graphite/bin/carbon-relay.py stop
        RETVAL=\$?
        [ \$RETVAL -eq 0 ] && success || failure
        echo
        return \$RETVAL
}

stop_cache () {
          /usr/bin/python /opt/graphite/bin/carbon-cache.py stop
        RETVAL=\$?
        [ \$RETVAL -eq 0 ] && success || failure
        echo
        return \$RETVAL
}

# See how we were called.
case "\$1" in
  start)
    #start_relay
    start_cache
        ;;
  stop)
    #stop_relay
    stop_cache
        ;;
  restart)
    #stop_relay
    stop_cache
    #start_relay
    start_cache
    ;;

  *)
        echo \$"Usage: \$0 {start|stop}"
        exit 2
        ;;
esac
EOF
chmod 0755 /etc/init.d/carbon-cache

# configure statsd
cat > /opt/statsd/local.js <<EOF
/*

Required Variables:

  port:             StatsD listening port [default: 8125]

Graphite Required Variables:

(Leave these unset to avoid sending stats to Graphite.
 Set debug flag and leave these unset to run in 'dry' debug mode -
 useful for testing statsd clients without a Graphite server.)

  graphiteHost:     hostname or IP of Graphite server
  graphitePort:     port of Graphite server


*/
{
  graphitePort: 2003
, graphiteHost: "33.33.33.10"
, port: 8125
, address: "33.33.33.10"
}
EOF

cat > /etc/init.d/statsd <<EOF
#!/bin/bash
#
# StatsD
#
# chkconfig: 345 99 01
#
# description: StatsD init.d
#
. /etc/rc.d/init.d/functions

lockfile=/var/lock/subsys/statsd
RETVAL=0
STOP_TIMEOUT=\${STOP_TIMEOUT-10}

start() {
	echo -n \$"Starting statsd: "
	cd /opt/statsd

	# See if it's already running. Look *only* at the pid file.
	if [ -f /var/run/statsd.pid ]; then
		failure "PID file exists for statsd"
		RETVAL=1
	else
		# Run as process
		/usr/local/bin/node ./stats.js /opt/statsd/local.js >> /var/log/statsd.log 2>> /var/log/statsderr.log &
		RETVAL=\$?

		# Store PID
		echo \$! > /var/run/statsd.pid

		# Success
		[ \$RETVAL = 0 ] && success "statsd started"
	fi

	echo
	return \$RETVAL
}

stop() {
	echo -n \$"Stopping statsd: "
	killproc -p /var/run/statsd.pid
	RETVAL=\$?
	echo
	[ \$RETVAL = 0 ] && rm -f /var/run/statsd.pid
}

# See how we were called.
case "\$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status -p /var/run/statsd.pid \${prog}
	RETVAL=\$?
	;;
  restart)
	stop
	start
	;;
  condrestart)
	if [ -f /var/run/statsd.pid ] ; then
		stop
		start
	fi
	;;
  *)
	echo \$"Usage: statsd {start|stop|restart|condrestart|status}"
	exit 1
esac

exit \$RETVAL
EOF
chmod 0755 /etc/init.d/statsd

# http://sergiy.kyrylkov.name/2012/02/26/phusion-passenger-with-apache-on-rhel-6-centos-6-sl-6-with-selinux/
yum -y install curl-devel httpd-devel apr-devel apr-util-devel
gem install rdoc
gem install bundler
gem install passenger
passenger-install-apache2-module -a
cat >> /etc/httpd/conf.d/passenger.conf  <<EOF
   LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-3.0.18/ext/apache2/mod_passenger.so
   PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-3.0.18
   PassengerRuby /usr/bin/ruby

   <VirtualHost *:80>
   RackAutoDetect On
   DocumentRoot /opt/gdash/public
   ErrorLog   /var/log/httpd/gdash_error_log
   CustomLog   /var/log/httpd/gdash_access_log combined
   <Directory /opt/gdash/>
      # This relaxes Apache security settings.
      AllowOverride all
      # MultiViews must be turned off.
      Options -MultiViews
      allow from all
   </Directory>
   </VirtualHost>
EOF
pushd /opt
git clone https://github.com/ripienaar/gdash.git
pushd /opt/gdash
bundle install
popd
cp /opt/gdash/config/gdash.yaml-sample /opt/gdash/config/gdash.yaml
sed -i 's/\/path\/to\/my\/graph\/templates/\/opt\/gdash\/graph_templates\/dashboards/g' /opt/gdash/config/gdash.yaml
sed -i 's/graphite.example.net/33.33.33.10:8080/g' /opt/gdash/config/gdash.yaml
sed -i 's/\/var\/lib\/carbon\/whisper/\/opt\/graphite\/storage\/whisper\//g' /opt/gdash/config/gdash.yaml
chown -R apache:apache /opt/gdash
popd 


# Start services
service httpd start
chkconfig httpd on 

service carbon-cache start 
chkconfig carbon-cache on 

service statsd restart
chkconfig statsd on



