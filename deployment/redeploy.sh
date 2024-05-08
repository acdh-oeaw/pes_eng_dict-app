#!/bin/bash
# Run this script to update the Zuludict instance to the latest versions. 
# It ...
# * pulls the current code of the web application from github.
# * pulls the current content of the web application from github.
#
# Note: deploy-zuludict-data.bxs
# and this file are in the root directory of your basex setup.
# It assumes Zuludict data is in the zuludict-data directory
# and that the Zuludict app is in the webapp/zuludict-app directory

cd $(dirname $0)

if [ ! -f redeploy.settings ]
then echo Missing settings file. Please copy redeploy.settings.dist to redeploy.settings and fill in the credentials.
fi

. redeploy.settings

if [ "$local_username"x = x -o "$local_password"x = x ]; then echo Missing credentials for local BaseX; exit 1; fi
#------ Settings ---------------------
export USERNAME=$local_username
export PASSWORD=$local_password
#-------------------------------------

#------ Update XQuery code -----------
echo updating BaseX app code
if [ -d ${BUILD_DIR:-webapp/zuludict-app} ]
then
pushd ${BUILD_DIR:-webapp/zuludict-app}
git reset --hard
git checkout main
git pull
ret=$?
if [ $ret != "0" ]; then exit $ret; fi
if [ "$onlytags"x = 'truex' ]
then
uiversion=$(git describe --tags --always)
uipath=$(pwd)
echo checking out UI ${uiversion}
git -c advice.detachedHead=false checkout ${uiversion}
find ./ -type f -and \( -name '*.js' -or -name '*.html' \) -not \( -path './node_modules/*' -or -path './cypress/*' \) -exec sed -i "s~\@version@~$uiversion~g" {} \;
else
git checkout main
fi
popd
fi
#-------------------------------------

#------ Update content data from redmine git repository 
echo updateing data
if [ ! -d zuludict-data/.git ]
then echo "zuludict-data does not exist or is not a git repository"
else
pushd zuludict-data
git reset --hard
git checkout master
git pull
ret=$?
if [ $ret != "0" ]; then exit $ret; fi
if [ "$onlytags"x = 'truex' ]
then
dataversion=$(git describe --tags --always)
echo checking out data ${dataversion}
git -c advice.detachedHead=false checkout ${dataversion}
who=$(git show -s --format='%cN')
when=$(git show -s --format='%as')
message=$(git show -s --format='%B')
revisionDesc=$(sed ':a;N;$!ba;s/\n/\\n/g' <<EOF
  <change n="$dataversion" who="$who" when="$when">
    $message
  </change>
EOF
)
for d in $(ls -d dc_*__publ)
do echo "Directory $d:"
find "$d" -type f -and -name '*.xml' -exec sed -i "s~\(</revisionDesc>\)~$revisionDesc\\n\1~g" {} \;
done
find $uipath -type f -and \( -name '*.js' -or -name '*.html' \) -not \( -path './node_modules/*' -or -path './cypress/*' \) -exec sed -i "s~\@data-version@~$dataversion~g" {} \;
else
git checkout master
fi
popd
./execute-basex-batch.sh deploy-zuludict-data
fi
#-------------------------------------
