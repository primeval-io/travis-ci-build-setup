#!/bin/bash

# Don't deploy pull requests
if [ "$TRAVIS_PULL_REQUEST" != false ];
then
	echo "Skipping snapshot deployment because it is a non-merged pull request"
	exit 0
fi

# Only deploy master
if [ "$TRAVIS_BRANCH" != "master" ];
then
	echo "Skipping snapshot deployment because branch is not master"
	exit 0
fi

# Usage: ./script [dir]

POM_LOC="pom.xml"
MVN_EXTRA_ARG=""
if [ -n "$1" ];
then
	POM_LOC="$1/pom.xml"
	MVN_EXTRA_ARG="-f $1"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VERSION=`python -c "import xml.etree.ElementTree as ET;  print(ET.parse(open('${POM_LOC}')).getroot().find('{http://maven.apache.org/POM/4.0.0}version').text)"`
echo "Found version $VERSION"

if [[ $VERSION == *-SNAPSHOT ]];
then
	echo "Deploying to OSSRH Snapshots..."
  	mvn clean deploy -Ddeploy $MVN_EXTRA_ARG -DaltDeploymentRepository=ossrh::default::https://oss.sonatype.org/content/repositories/snapshots -B --settings ${DIR}/deploy-settings.xml
else
	echo "Release version, deploy is manual."
fi
