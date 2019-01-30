FROM alpine:3.8

MAINTAINER Cedric Roijakkers <cedric@roijakkers.be>

# This container is a combination of the following two container sources:
# https://github.com/jessfraz/dockerfiles/tree/master/postfix
# https://github.com/juanluisbaptiste/docker-postfix
# Taking the best of both worlds, and making them work together

# Add postfix and other dependencies
RUN apk add --no-cache tzdata bash ca-certificates libsasl mailx postfix rsyslog runit coreutils

# Set the correct timezone inside the container (ENV can be overwritten at run-time)
ENV TZ=Europe/Amsterdam

# Install configuration files
COPY service /etc/service
COPY runit_bootstrap /usr/sbin/runit_bootstrap
COPY rsyslog.conf /etc/rsyslog.conf

# Make sure the logging goes to docker
RUN ln -sf /dev/stdout /var/log/mail.log

STOPSIGNAL SIGKILL

# Run the application
RUN chmod +x /usr/sbin/runit_bootstrap /etc/service/*/run
ENTRYPOINT ["/usr/sbin/runit_bootstrap"]
