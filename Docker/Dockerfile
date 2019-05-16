FROM alpine:3.9

# add user filo
RUN addgroup -g 1000 filo && \
    adduser -D -u 1000 -G filo filo
#USER filo

# install packages
RUN apk update && \
  apk add --no-cache \
  terraform=0.11.8-r0 \
  git \
  python2 python2-dev py2-pip \
  python3 python3-dev py3-pip \
  openssh \
  go bzr \
  musl-dev libffi-dev openssl-dev \
  make \
  vim \
  bash

# make sure ansible is not installed by the system
RUN apk del ansible

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

# Copy custom inventory builder

COPY inventory_builder /baklava/inventory_builder

# clone kubespray repo
RUN git clone https://github.com/kubernetes-incubator/kubespray.git && \
    cd kubespray && git checkout 3f62492a15c96acae93e7571231f513a58f23f1f && cd ..

# install kubespray requirements
RUN pip2 install --upgrade pip && \
    pip2 uninstall ansible && \
    cd /baklava/kubespray && pip2 install -r requirements.txt && \
    cd /baklava/kubespray/contrib/inventory_builder && pip3 install -r requirements.txt && \
    pip2 install ansible-modules-hashivault && \
    cd /baklava

# set environment variables
ENV BAKLAVA_HOME /baklava
ENV BAKLAVA_CONFIG /baklava/config
#ENV ANSIBLE_LIBRARY /usr/lib/python2.7/site-packages/ansible/modules
#ENV ANSIBLE_MODULE_UTILS /usr/lib/python2.7/site-packages/ansible/module_utils
#export PATH=$PATH:/baklava/kubespray/library


COPY scripts/baklava-init.sh /usr/local/bin/
RUN ln -s usr/local/bin/baklava-init.sh / # back compatibility
ENTRYPOINT ["baklava-init.sh"]
CMD ["deploy"]