#!/bin/bash

. $LKP_SRC/lib/debug.sh
. $LKP_SRC/lib/reproduce-log.sh
. $LKP_SRC/lib/env.sh

build_libipt()
{
    cd $BENCHMARK_ROOT/$testcase/libipt && cmake . && make install
}

build_lkvs()
{
    cd $BENCHMARK_ROOT/$testcase/lkvs && make --keep-going
}

runtests()
{
    cd $BENCHMARK_ROOT/$testcase/lkvs || return

    case $test in
        tests-client)
            log_cmd ./runtests -f tests-client
            ;;
        tests-server)
            log_cmd ./runtests -f tests-server
            ;;
        cet)
            log_cmd ./runtests -f cet/tests
            ;;
        guest-test)
            log_cmd ./runtests -f guest-test/guest.test_launcher.sh
            ;;
        pt)
            log_cmd ./runtests -f pt/tests
            ;;
        ufs)
            log_cmd ./runtests -f ufs/tests
            ;;
        ifs)
            log_cmd ./runtests -f ifs/tests
            ;;
        rapl-client)
            log_cmd ./runtests -f rapl/tests-client
            ;;
        rapl-server)
            log_cmd ./runtests -f rapl/tests-server
            ;;
        tdx-compliance)
            log_cmd insmod tdx-compliance/tdx-compliance.ko
            echo all > /sys/kernel/debug/tdx/tdx-tests
            log_cmd cat /sys/kernel/debug/tdx/tdx-tests
            ;;
        umip)
            log_cmd ./runtests -f umip/tests
            ;;
        isst)
            log_cmd ./runtests -f isst/tests
            ;;
        th)
            log_cmd ./runtests -c "th/th_test 1"
            log_cmd ./runtests -c "th/th_test 2"
            ;;
        workload-xsave)
            log_cmd cd workload-xsave
            log_cmd mkdir build
            log_cmd cd build
            log_cmd cmake ..
            log_cmd make
            available_workloads=$(./yogini 2>&1 | grep "Available workloads" | cut -d: -f 2 | xargs)
            log_cmd ../start_test.sh -1 100 $available_workloads
            ;;
        thermal)
            log_cmd ./runtests -f thermal/thermal-tests
            ;;
        xsave)
            log_cmd ./runtests -f xsave/tests
            ;;
        fred)
            log_cmd insmod fred/fred_test_driver.ko
            # No doc about how to get the test result after loading the module
            ;;
        sdsi)
            log_cmd ./runtests -f sdsi/tests
            ;;
        cstate-client)
            log_cmd ./runtests -f cstate/tests-client
            ;;
        cstate-server)
            log_cmd ./runtests -f cstate/tests-server
            ;;
        topology-client)
            log_cmd ./runtests -f topology/tests-client
            ;;
        topology-server)
            log_cmd ./runtests -f topology/tests-server
            ;;
        pmu)
            log_cmd ./runtests -f pmu/tests
            ;;
        splitlock)
            cat /proc/cpuinfo | grep -q split_lock_detect || die "split_lock_detect not supported on current CPU"
            log_cmd ./runtests -f splitlock/tests
            ;;
    esac
}
