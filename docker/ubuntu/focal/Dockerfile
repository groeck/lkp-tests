FROM ubuntu:focal

# lkp install generates hosts/$HOSTNAME during create_host_config. Here it requires
# user to pass hostname arg to specify a consistent name instead of the container
# hostname when building the image.
ARG hostname=lkp-docker
ENV HOSTNAME=${hostname}

WORKDIR /lkp/lkp-tests

COPY . ./

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    # linux-tools-generic contains perf and turbostat
    linux-tools-generic \
    make \
    # procps installs vmstat, sysctl, etc to partially persistent commonly used dependencies
    procps \
    sudo && \
    make install && \
    lkp install && \
    # replace the turbostat and perf wrappers in /usr/bin with the ones installed from linux-tools-generic
    # because the wrappers have very restrictive kernel version dependency checks
    ln -sf $(find /usr/lib -name turbostat | head -n 1) /usr/bin/turbostat && \
    ln -sf $(find /usr/lib -name perf | head -n 1) /usr/bin/perf

ENTRYPOINT ["bash", "-c", "sleep infinity"]
