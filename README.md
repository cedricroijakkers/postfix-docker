# About postfix-docker
This container runs the postfix mail server, and is a combination of the following two containers:

- [https://github.com/jessfraz/dockerfiles/tree/master/postfix](https://github.com/jessfraz/dockerfiles/tree/master/postfix)
- [https://github.com/juanluisbaptiste/docker-postfix](https://github.com/juanluisbaptiste/docker-postfix)

It combines both into one, using the alpine base and logging from the first container; and the configuration properties from the second.

# How to run it

The following env variables need to be passed to the container:

* `SMTP_SERVER` Server address of the SMTP server to use.
* `SMTP_PORT` (Optional, Default value: 587) Port address of the SMTP server to use.
* `SMTP_USERNAME` Username to authenticate with.
* `SMTP_PASSWORD` Password of the SMTP user.
* `SERVER_HOSTNAME` Server hostname for the Postfix container. Emails will appear to come from the hostname's domain.

The following env variable(s) are optional.

* `SMTP_HEADER_TAG` This will add a header for tracking messages upstream. Helpful for spam filters. Will appear as "RelayTag: ${SMTP_HEADER_TAG}" in the email headers.

To use this container from anywhere, the 25 port needs to be exposed to the docker host server:

    docker run -d --name postfix -p "25:25"  \ 
           -e SMTP_SERVER=smtp.bar.com \
           -e SMTP_USERNAME=foo@bar.com \
           -e SMTP_PASSWORD=XXXXXXXX \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           cedricroijakkers/postfix

# Maintainer
This container is built and maintained by [Cedric Roijakkers](mailto:cedric@roijakkers.be).