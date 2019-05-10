FROM alpine:latest

# install packages
RUN apk update && \
  apk add --no-cache \
  terraform \
  git \
  python3 python3-dev \
  openssh \
  go bzr \
  musl-dev libffi-dev openssl-dev \
  make \
  bash

# cleanup
RUN rm -rf /tmp/* /var/cache/apk/*

# opennebula provider
RUN go get -v github.com/runtastic/terraform-provider-opennebula && \
    go install -v github.com/runtastic/terraform-provider-opennebula

# add opennebula provider to .terraformrc
RUN echo -e 'providers {\n\
 opennebula = "/root/go/bin/terraform-provider-opennebula"\n\
 }'\
>> /root/.terraformrc

# change from sh to bash 
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

# WORKDIR
WORKDIR /baklava

# clone kubespray repo
RUN git clone https://github.com/kubernetes-incubator/kubespray.git

# install kubespray requirements
RUN pip3 install --upgrade pip && \
    pip3 install ansible && \
    pip3 install -r kubespray/requirements.txt

ENV BAKLAVA_HOME /baklava
ENV BAKLAVA_CONFIG /baklava/config

COPY scripts/baklava-init.sh /usr/local/bin/
RUN ln -s usr/local/bin/baklava-init.sh / # back compatibility
ENTRYPOINT ["baklava-init.sh"]
CMD ["deploy"]