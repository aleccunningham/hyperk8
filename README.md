# hyperk8

## Install

tar the go directory

```Bash
tar -cv go | gzip > go.tar.gz
```

```Bash
RUN cd $GOPATH/src/k8s.io/kubernetes && \
      export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig && \
      cluster/kubectl.sh
```
