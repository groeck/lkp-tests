FROM fedora:39

# lkp install generates hosts/$HOSTNAME during create_host_config. Here it requires
# user to pass hostname arg to specify a consistent name instead of the container
# hostname when building the image.
ARG hostname=lkp-docker
ENV HOSTNAME=${hostname}

WORKDIR /lkp/lkp-tests

COPY . ./

RUN dnf upgrade -y && \
    dnf install -y \
    # kernel-tools installs turbostat
    kernel-tools \
    make \
    # procps installs vmstat, sysctl, etc to partially persistent commonly used dependencies
    procps \
    perf \
    hostname && \
    make install && \
    lkp install

ENTRYPOINT ["bash", "-c", "sleep infinity"]
