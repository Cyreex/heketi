# set author and base
FROM fedora:27
MAINTAINER Heketi Developers <heketi-devel@gluster.org>

LABEL version="1.3.1"
LABEL description="Development build"

# let's setup all the necessary environment variables
ENV BUILD_HOME=/build
ENV GOPATH=$BUILD_HOME/golang
ENV PATH=$GOPATH/bin:$PATH
# where to clone from
ENV HEKETI_REPO="https://github.com/grig-tar/heketi.git"
ENV HEKETI_BRANCH="v9-with-fix1574"

# install dependencies, build and cleanup
RUN mkdir $BUILD_HOME $GOPATH && \
    dnf -y install glide golang git make mercurial findutils && \
    dnf -y update ca-certificates && \
    dnf -y clean all && \
    mkdir -p $GOPATH/src/github.com/heketi && \
    cd $GOPATH/src/github.com/heketi && \
    git clone -b $HEKETI_BRANCH $HEKETI_REPO && \
    cd $GOPATH/src/github.com/heketi/heketi && \
    glide install -v && \
    make && \
    mkdir -p /etc/heketi /var/lib/heketi && \
    make install prefix=/usr && \
    #cp /usr/share/heketi/container/heketi-start.sh /usr/bin/heketi-start.sh && \
    cp /usr/share/heketi/container/heketi.json /etc/heketi/heketi.json && \
    glide cc && \
    mkdir $BUILD_HOME/cyreex && \
    cd $BUILD_HOME/cyreex && \
    git clone -b master https://github.com/Cyreex/heketi && \
    cp $BUILD_HOME/cyreex/heketi/heketi-start.sh /usr/bin/heketi-start.sh && \
    chmod +x /usr/bin/heketi-start.sh && \
    cd && rm -rf $BUILD_HOME && \
    dnf -y remove git glide golang mercurial && \
    dnf -y autoremove && \
    dnf -y clean all

VOLUME /etc/heketi /var/lib/heketi

# expose port, set user and set entrypoint with config option
ENTRYPOINT ["/usr/bin/heketi-start.sh"]
EXPOSE 8080
