FROM alpine:3.15.4

LABEL maintainer="Cedric Roijakkers <cedric@roijakkers.be>"

# This container is a combination of the following two container sources:
# https://github.com/jessfraz/dockerfiles/tree/master/postfix
# https://github.com/juanluisbaptiste/docker-postfix
# Taking the best of both worlds, and making them work together

# Add postfix and other dependencies
RUN apk update && \
    apk upgrade && \
    apk add --no-cache tzdata ca-certificates libsasl postfix rsyslog runit coreutils cyrus-sasl cyrus-sasl-crammd5 \
    cyrus-sasl-digestmd5 cyrus-sasl-gs2 cyrus-sasl-gssapiv2 cyrus-sasl-login cyrus-sasl-ntlm cyrus-sasl-openrc \
    cyrus-sasl-scram cyrus-sasl-static opendkim opendkim-utils

# Install runit configuration files
COPY service /etc/service
COPY runit_bootstrap /usr/sbin/runit_bootstrap
# And the syslog configuration file
COPY rsyslog.conf /etc/rsyslog.conf

# Send all application logging to stdout, so it can be logged by Docker
RUN ln -sf /dev/stdout /var/log/mail.log && \
# And fix the permissions of the runit scripts
    chmod +x /usr/sbin/runit_bootstrap /etc/service/*/run

# The Docker stop signal
STOPSIGNAL SIGKILL

# Run the application(s) with runit
CMD ["/usr/sbin/runit_bootstrap"]

# Expose port 25 (SMTP)
EXPOSE 25