#!/bin/bash -ex

YQ_RELEASE=v4.35.1
KIND_RELEASE=v0.20.0
GOLANG_RELEASE=1.21.1
HELM_RELEASE=v3.12.3

init() {
    export TZ="/usr/share/zoneinfo/America/Los_Angeles"
    export LC_ALL="C"
    export DEBIAN_FRONTEND=noninteractive
    apt update

    # Install OS dependencies
    apt install curl wget python3-pip unzip parallel -y

    # Install go
    if ! command -v go; then
        curl -Lo go1.21.1.linux-amd64.tar.gz https://go.dev/dl/go1.21.1.linux-amd64.tar.gz
        rm -rf /usr/local/go && tar -C /usr/local -xzf go$GOLANG_RELEASE.linux-amd64.tar.gz
        rm go1.21.1.linux-amd64.tar.gz
    fi

    # install tools (helm, kubectl)
    if ! command -v kubectl; then
        curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x /usr/local/bin/kubectl
    fi

    if ! command -v yq; then
        curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_RELEASE}/yq_linux_amd64
        chmod +x /usr/local/bin/yq
    fi

    if ! command -v helm; then
        curl -Lo helm-${HELM_RELEASE}-linux-amd64.tar.gz https://get.helm.sh/helm-${HELM_RELEASE}-linux-amd64.tar.gz
        tar zxvf helm-${HELM_RELEASE}-linux-amd64.tar.gz
        mv -vf linux-amd64/helm /usr/local/bin
        rm -rf linux-amd64
    fi

    # install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh

    # install kind
    if ! command -v kind; then
        curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/${KIND_RELEASE}/kind-linux-amd64
        chmod +x /usr/local/bin/kind
    fi

    # install aliases
    for f in .bashrc .pylintrc .screenrc .vimrc .kubectl_aliases
    do
        cp -f $f ~
    done

    cp -vf rfsrc /usr/local/bin

    ln -svf /root/rapidfort/functional-tests/devops/whatsnew.sh       /usr/local/bin/whatsnew
    ln -svf /root/rapidfort/functional-tests/devops/whereami.sh       /usr/local/bin/whereami
    ln -svf /root/rapidfort/functional-tests/devops/rfbuild.sh        /usr/local/bin/rfbuild
    ln -svf /root/rapidfort/functional-tests/devops/registry          /usr/local/bin/registry
    ln -svf /root/rapidfort/functional-tests/devops/registry-setup.sh /usr/local/bin/registry-setup.sh

    if test -s $HOME/.git-prompt.sh ; then
        curl -Lo $HOME/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
        source $HOME/.git-prompt.sh
    fi

    # pull code

    # Setup local container registry

    # Launch Cluster

    # Deploy application

}

init