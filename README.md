# About postfix-docker
This container runs the postfix mail server, and is a combination of the following two containers:

- [https://github.com/jessfraz/dockerfiles/tree/master/postfix](https://github.com/jessfraz/dockerfiles/tree/master/postfix)
- [https://github.com/juanluisbaptiste/docker-postfix](https://github.com/juanluisbaptiste/docker-postfix)

It combines both into one, using the alpine base and logging from the first container; and the configuration properties from the second.

It allows to run an SMTP server in a docker container, with various options:
* Send the mails directly, optionally signing them with DKIM
* Optionally rewrite headers
* Optionally relay the mails to an upstream mail server, optionally with authentication
* For advanced users: any arbitrary Postfix configuration and shell command can be added

# How to run it
The following env variable is mandatory to be passed to the container:
* `SERVER_HOSTNAME`: Server hostname for the Postfix container. Emails will appear to come from this domain.

This will start the mail server with the specified hostname on port 25 with a maximum of 1000 recipients per mail.

These two parameters can be changed with the following environment variables:
* `SMTP_PORT`: (Default value: 25) Port number of the upstream SMTP server to use.
* `RECIPIENT_LIMIT`: (Default value: 1000) Maximum number of recipients per mail.

If you wish to enable header rewriting, the following environment variables can be used:
* `SMTP_HEADER_TAG`: When set, will add a header for tracking messages upstream. Helpful for spam filters. Will appear as `RelayTag: ${SMTP_HEADER_TAG}` in the email headers.
* `REWRITE_DOMAIN`: When set, will change the part behind the `@` character in all from-adresses to the specified domain, this is handy when your upstream server requires mails to be sent from a specific domain only (do not add the `@` character itself).
* `REWRITE_HEADERS`: When set, will apply the regular expression(s) to all headers of all passing mails, enter the full regular expression; use seperator `\n` if you wish to apply multiple regexes (be sure to escape `$` with `\$` when using backreferences since this is an environment variable!)

If you wish to sign mails with DKIM, the following optional environment variabled can be used:
* `DKIM_DOMAIN`: All mails from this domain will be signed with DKIM, other domains will be untouched
* `DKIM_KEY`: Location of the file in the container with the DKIM private key (this needs to be mounted, see below)
* `DKIM_SELECTOR`: The name of the DKIM selector for the mail signature

If you wish to use an upstream server to send the mails, the following environment variables can be used:
* `SMTP_SERVER`: Server address of the upstream SMTP server to use.
* `SMTP_USERNAME`: Username to authenticate with.
* `SMTP_PASSWORD`: Password of the SMTP user.

# Adding arbitrary configuration properties
If the configuration options in the environment variables above do not suit your needs, you can specify a shell script which you can mount in the container that changes the postfix configuration file as much as you like.
There is a function in the `runit` file `add_config_value` that you can use fo this. Call it as follows:

```shell
add_config_value "key" "value"
```

For example:
```shell
add_config_value "smtp_use_tls" "yes"
```

To activate this option, mount a shell script in the container in a place of your liking, and specify the location of the script in the environment variable `ADDITIONAL_CONFIG`:

    docker run -d --name postfix -p "25:25"  \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           -e ADDITIONAL_CONFIG=/tmp/additional_config.sh \
           -v /path/to/addition_config.sh:/tmp/additional_config.sh \
           cedricroijakkers/postfix-docker:3.6.6

It will be loaded and fully executed at container boot time. You can use any command in there, but it is recommended to stick to `add_config_value` as this will automatically replace any existing configuration value with the same name in the postfix configuration file.

WARNING: This will execute the script as-is without checking any contents of it. Be sure to use it wisely!

# Starting the container: some examples

Here are some examples to use the mail server in various use cases:

To configure the mail server to relay mails directly, without any special configuration:

    docker run -d --name postfix -p "25:25"  \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           cedricroijakkers/postfix-docker:3.6.6

To configure the mail server to relay mails directly, and sign them for domain `helpdesk.mycompany.com` with DKIM selector `sel1` (be sure to add the required DNS records to avoid mails ending up in the SPAM folder!):

    docker run -d --name postfix -p "25:25"  \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           -e DKIM_DOMAIN=notification.vodafone.nl \
           -e DKIM_KEY=/var/db/dkim/helpdesk.mycompany.com.private \
           -e DKIM_SELECTOR=sel1 \
           -v /path/to/helpdesk.mycompany.com.private:/var/db/dkim/helpdesk.mycompany.com.private \
           cedricroijakkers/postfix-docker:3.6.6

To configure an upstream server without authentication:

    docker run -d --name postfix -p "25:25"  \ 
           -e SMTP_SERVER=smtp.bar.com \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           cedricroijakkers/postfix-docker:3.6.6

To configure an upstream server with authentication:

    docker run -d --name postfix -p "25:25"  \ 
           -e SMTP_SERVER=smtp.bar.com \
           -e SERVER_HOSTNAME=helpdesk.mycompany.com \
           -e SMTP_USERNAME=foo@bar.com \
           -e SMTP_PASSWORD=XXXXXXXX \
           cedricroijakkers/postfix-docker:3.6.6

# Maintainer
This container is built and maintained by [Cedric Roijakkers](mailto:cedric@roijakkers.be).