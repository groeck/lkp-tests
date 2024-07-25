FROM debian:bookworm

# lkp install generates hosts/$HOSTNAME during create_host_config. Here it requires
# user to pass hostname arg to specify a consistent name instead of the container
# hostname when building the image.
ARG hostname=lkp-docker
ENV HOSTNAME=${hostname}

WORKDIR /lkp/lkp-tests

COPY . ./

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    # linux-cpupower installs turbostat as default one
    linux-cpupower \
    make \
    # procps installs vmstat, sysctl, etc to partially persistent commonly used dependencies
    procps \
    sudo && \
    make install && \
    lkp install && \
    # replace the wrapper /usr/bin/perf with the link to actual perf like perf_4.19 as default one
    ln -sf $(echo /usr/bin/perf_* | cut -f1 -d" ") /usr/bin/perf

ENTRYPOINT ["bash", "-c", "sleep infinity"]
