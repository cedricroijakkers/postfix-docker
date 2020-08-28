FROM alpine:3.10.5

LABEL maintainer="Cedric Roijakkers <cedric@roijakkers.be>"

# This container is a combination of the following two container sources:
# https://github.com/jessfraz/dockerfiles/tree/master/postfix
# https://github.com/juanluisbaptiste/docker-postfix
# Taking the best of both worlds, and making them work together

# Add postfix and other dependencies
RUN apk update && apk add --no-cache tzdata ca-certificates libsasl postfix rsyslog runit coreutils cyrus-sasl-plain \
cyrus-sasl-openrc cyrus-sasl-gs2 cyrus-sasl-scram cyrus-sasl-digestmd5 cyrus-sasl-login cyrus-sasl-crammd5

# Set the correct timezone inside the container (ENV can be overwritten at run-time)
ENV TZ=Europe/Amsterdam

# Install configuration files
COPY service /etc/service
COPY runit_bootstrap /usr/sbin/runit_bootstrap
COPY rsyslog.conf /etc/rsyslog.conf

# Make sure the logging goes to docker
RUN ln -sf /dev/stdout /var/log/mail.log

# The Docker stop signal
STOPSIGNAL SIGKILL

# Run the application
RUN chmod +x /usr/sbin/runit_bootstrap /etc/service/*/run
ENTRYPOINT ["/usr/sbin/runit_bootstrap"]

# Expose port 25 (SMTP)
EXPOSE 25