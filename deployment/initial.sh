#!/bin/bash

cp -Rv ./deployment/* ${1:-../../}
# often needed
# npm install
# but we have all js dependencies in the source tree
cd ${1:-../../}
source data/credentials
local_password="${BASEX_admin_pw:-admin}"
echo "Got BaseX password $local_password"
mv redeploy.settings.dist redeploy.settings
sed -e "s~local_password=.*~local_password=$local_password~g" -i '' redeploy.settings
git clone https://github.com/acdh-oeaw/pes_eng_dict-data.git
if [ "${STACK}x" = "x" ]; then
pushd lib/custom
curl -LO https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/12.4/Saxon-HE-12.4.jar
popd
if [ "$OSTYPE" == "msys" -o "$OSTYPE" == "win32" ]
then
  cd bin
  start basexhttp.bat
else
  cd bin
  ./basexhttp &
fi
cd ..
fi
exec ./redeploy.sh
