FROM nginx

# add own user
RUN useradd www

# we're based on the awesome work by the h5bp community
ADD https://github.com/h5bp/server-configs-nginx/archive/master.tar.gz /tmp/
RUN cd /tmp \
    && gunzip -c master.tar.gz | tar xopf - \
    && cp -rf server-configs-nginx-master/* /etc/nginx/ \
    && rm -rf /tmp/* \
    && rm -f /etc/nginx/conf.d/*

# and add / configure some additional stuff
RUN CFG="/etc/nginx/nginx.conf" \
    && sed -i -e '0,/include sites/s//include conf.d\/*.conf;\n  include sites/' $CFG \
    && sed -i -e 's/error_log .*/error_log \/dev\/stderr warn;/' $CFG \
    && sed -i -e 's/access_log .*/access_log \/dev\/stdout main;/' $CFG \
    && ln -s ../sites-available/no-default /etc/nginx/sites-enabled/

# define some missing volumes similar to dockerfiles/ngnix
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d"]
