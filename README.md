# About postfix-docker
This container runs the postfix mail server, and is a combination of the following two containers:

- [https://github.com/jessfraz/dockerfiles/tree/master/postfix](https://github.com/jessfraz/dockerfiles/tree/master/postfix)
- [https://github.com/juanluisbaptiste/docker-postfix](https://github.com/juanluisbaptiste/docker-postfix)

It combines both into one, using the alpine base and logging from the first container; and the configuration properties from the second.

It allows to run an SMTP server in a docker container, which can relay mails via another upstream SMTP server. Optionally, you can specify a user name and password for the upstream server, and this container will take care of the authentication. This container can be used when you want to have a single mail queue, and do not want to configure SMTP authentication in your application, but want this container to handle that for you.

# How to run it
The following env variables are mandatory to be passed to the container:
* `SMTP_SERVER`: Server address of the upstream SMTP server to use.
* `SERVER_HOSTNAME`: Server hostname for the Postfix container. Emails will appear to come from the hostname's domain.

The following env variables are optional, if you upstream server uses authentication:
* `SMTP_USERNAME`: Username to authenticate with.
* `SMTP_PASSWORD`: Password of the SMTP user.

The following env variable(s) are optional.
* `SMTP_PORT`: (Default value: 25) Port number of the upstream SMTP server to use.
* `RECIPIENT_LIMIT`: (Default value: 1000) Maximum number of recipients per mail.
* `SMTP_HEADER_TAG`: When set, will add a header for tracking messages upstream. Helpful for spam filters. Will appear as `RelayTag: ${SMTP_HEADER_TAG}` in the email headers.

To use this container from anywhere, the 25 port needs to be exposed to the docker host server:

To configure an upstream server without authentication:

    docker run -d --name postfix -p "25:25"  \ 
           -e SMTP_SERVER=smtp.bar.com \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           cedricroijakkers/postfix:3.4.5

To configure an upstream server with authentication:

    docker run -d --name postfix -p "25:25"  \ 
           -e SMTP_SERVER=smtp.bar.com \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           -e SMTP_USERNAME=foo@bar.com \
           -e SMTP_PASSWORD=XXXXXXXX \
           cedricroijakkers/postfix:3.4.5

# Maintainer
This container is built and maintained by [Cedric Roijakkers](mailto:cedric@roijakkers.be).