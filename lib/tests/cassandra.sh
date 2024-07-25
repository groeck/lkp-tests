#!/bin/sh

. $LKP_SRC/lib/debug.sh
. $LKP_SRC/lib/env.sh

setup_java_home()
{
	if [ -d /usr/lib/jvm/java-1.11.0-openjdk ]; then
		export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk
		export CASSANDRA_USE_JDK11=true
	elif [ -d /usr/lib/jvm/java-11-openjdk-amd64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
		export CASSANDRA_USE_JDK11=true
	elif [ -d /usr/lib/jvm/java-1.8.0-openjdk ]; then
		export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
	elif [ -d /usr/lib/jvm/java-8-openjdk-amd64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	elif [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
	else
		die "NO available JAVA_HOME"
	fi

	echo "JAVA_HOME=$JAVA_HOME"
}

# mainly to resolve "/usr/bin/env: ‘python’: No such file or directory"
setup_python()
{
	has_cmd python && return

	if has_cmd python2; then
		ln -sf $(cmd_path python2) /usr/bin/python
	elif has_cmd python3; then
		ln -sf $(cmd_path python3) /usr/bin/python
	else
		die "No python found"
	fi

	echo "python: $(ls -l /usr/bin/python)"
}
