FROM ubuntu:latest

GOPATH=/home/go

ADD go.tar.gz /home/go
RUN tar -zxvf /home/go/go.tar.gz && \
    rm go.tar.gz

RUN cd $GOPATH/src/k8s.io/frakti && \
    make && make install && apt-get update && \
    apt-get install qemu libvirt0 docker.io -y && \
    curl -sSL https://hypercontainer.io/install | bash

ADD hyper.config /etc/hyper/config
RUN systemctl restart hyperd && \
    sudo mkdir -p /etc/cni/net.d  /opt/cni/bin && \
    cd $GOPATH/src/github.com/containernetworking/plugins && \
    ./build.sh && \
    sudo cp bin/* /opt/cni/bin/

ADD 10-mynet.conflist /etc/cni/net.d/10-mynet.conflist
ADD 99-loopback.conf etc/cni/net.d/99-loopback.conf

CMD ["frakti", "--v=3", "--logtostderr", "--listen=/var/run/frakti.sock", "--hyper-endpoint=127.0.0.1:22318"]

RUN cd $GOPATH/src/k8s.io/kubernetes && \
    chmod +x hack/install-etcd.sh
    hack/install-etcd.sh && \
    export PATH=$GOPATH/src/k8s.io/kubernetes/third_party/etcd:${PATH} && \
    export KUBERNETES_PROVIDER=local && \
    export CONTAINER_RUNTIME=remote && \
    export CONTAINER_RUNTIME_ENDPOINT=/var/run/frakti.sock && \
    chmod +x hack/local-up-cluster.sh
    hack/local-up-cluster.sh
