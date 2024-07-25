#!/bin/bash

make()
{
	echo "$(date +'%F %T') make -j $nr_cpu $*"

	/usr/bin/make -j $nr_cpu "$@"
}

make_config()
{
        (
        set -o pipefail
        { yes ''; true; } | make "$@"
        )
}

build_complete()
{
	echo "$(date +'%F %T') make finished"
}
