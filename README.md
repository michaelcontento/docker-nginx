# nginx

[nginx][] docker container with configuration imported from the awesome
[h5bp-nginx-config][] project.

# Advantages

First of all: this container is based on the [official nginx][] container! But
there are some differences that, IMHO, are pretty awesome :)

* [H5BP Nginx Config](#h5bp-nginx-config)
* [No default server](#no-default-server)
* [Volumes](#volumes)
* [Dynamic vhost config](#run-nginx-dynamic-vhost-files)

## H5BP Nginx Config

Just have a look at the [h5bp-nginx-config][] repository. All those files are
available at your fingertips with this container. And yes, we patched all
`access_log` and `error_log` statements to use `stdout`/`stderr`.

## No default server

This container **does not** comes with a default vhost and some *"pretty"*
default html file. Instead the [no-default] vhost is enabled and nginx responds
with `444 no response` to all requests that don't hit any configured vhost.

## Volumes

This container does expose some volumes similar to [dockerfiles/nginx][],
because, at least to me, this sounds like a good idea / benefit.

* `/etc/nginx/sites-enabled`
* `/etc/nginx/certs`
* `/etc/nginx/conf.d`

## run-nginx / dynamic vhost files

There is a small script present that runs just before [nginx][] and can be used
to establish dynamic vhost configs pretty easy. Imagine a simple setup like:

    +------+       +-------+       +-----------------------+
    | USER | ----> | nginx | ----> | application container |
    +------+       +-------+       +-----------------------+

How does the `nginx container` know about the `application container`? Or what
the vhost config should look like? Sure, you could re-use this container and end
with something similiar to this setup:

    +------+       +-------------------+       +-----------------------+
    | USER | ----> | application nginx | ----> | application container |
    +------+       +-------------------+       +-----------------------+
                            .
                           / \
                            |
                            |
                        +-------+
                        | nginx |
                        +-------+

But now you have to manage yet another container and, even worse, split the
application related configuration files! What if [nginx][] could somehow ask the
`application container` for the right vhost configuration? Would be pretty neat,
huh? Well, that's exactly what the `run-nginx` command is about! With it the
setup could be like this:

    +------+       +-------+       +-----------------------+
    | USER | ----> | nginx | ----> | application container |
    +------+       +-------+       +-----------------------+
                                    VOLUME /path/to/the/app

And all you have to do is run this [nginx][] container with the path to the
vhost config file (e.g. `/path/to/the/app/nginx.conf`). But how should you know
the `ip/port` of the docker link upfront? You don't have to. `run-nginx` supports
some very basic kind of templating for this. So if you `application container`
is linked with the name `web` to [nginx][] and exposes port `9000` you could
connect the two like this:

    $ cat /path/to/the/app/nginx.conf | grep "_TCP_"
    fastcgi_pass {WEB_PORT_9000_TCP_ADDR}:{WEB_PORT_9000_TCP_PORT};

    $ docker run --rm \
        --link application:web \
        --volumes-from application:ro \
        -t michaelcontento/nginx \
        /path/to/the/app/nginx.conf


Also you're allowed to replace the link name with `*` if you don't mind the
actual used link name:


    $ cat /path/to/the/app/nginx.conf | grep "_TCP_"
    fastcgi_pass {*_PORT_9000_TCP_ADDR}:{*_PORT_9000_TCP_PORT};

    $ docker run --rm \
        --link application:idontmindthis \
        --volumes-from application:ro \
        -t michaelcontento/nginx \
        /path/to/the/app/nginx.conf

But keep in mind that this will use the first docker link with port `9000`
exposed!


[dockerfiles/nginx]: https://registry.hub.docker.com/u/dockerfile/nginx/
[nginx]: http://nginx.com/
[h5bp-nginx-config]: https://github.com/h5bp/server-configs-nginx
[no-default]: https://github.com/h5bp/server-configs-nginx/blob/master/sites-available/no-default
[official nginx]: https://github.com/nginxinc/docker-nginx
