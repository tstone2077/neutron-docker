FROM node
RUN apt-get update
RUN apt-get install -y git build-essential
RUN apt-get clean

# Need go 1.6, since the 1.3 version from apt-get fails to build neutron
RUN curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
RUN tar -xvf go1.6.linux-amd64.tar.gz
RUN mv go /usr/local
RUN rm go1.6.linux-amd64.tar.gz
RUN mkdir /go
ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# get the neutron code
RUN go get -u github.com/emersion/neutron

WORKDIR /go/src/github.com/emersion/neutron
RUN git submodule init
RUN git submodule update

# Fixing problem described here https://github.com/ProtonMail/WebClient/issues/1
# by editing the Makefile with:
#   removing the grunt-angular-gettext modification since the fix has been added (based on issue above)
#   adding npm install bower to install bower before the npm install grabs it
#   adding bower install manually since that grabs the appropriate files whereas npm install directoy won't.
RUN sed -i -e '/.*sed.*\/grunt-angular-gettext.git.*/d' -e '/nggettext_extract/a npm install bower && bin/bower install --allow-root -F && \\' Makefile
RUN make build-client

#is this needed?
EXPOSE 4000
EXPOSE 8080
CMD ["make", "start"]
