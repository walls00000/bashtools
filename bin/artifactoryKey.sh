if [ ! -f ~/.artifactory ];then
  echo "~/.artifactory does not exist! Please put creds in ~/.artifactory"
fi
creds=`cat ~/.artifactory`
curl http://artifact.simplivt.local:8081/artifactory/api/gems/gems-foxhound-local/api/v1/api_key.yaml -u ${creds} > ~/.gem/credentials
chmod 600 ~/.gem/credentials

#Usage as source: Add this source URL to your ~/.gemrc or use:
gem sources -a http://artifact.simplivt.local:8081/artifactory/api/gems/gems-foxhound-local/
 
 
#Usage as target: Export RUBYGEMS_HOST with the target local repository:

if [ -z ${RUBYGEMS_HOST} ];then
  echo "exporting RUBYGEMS_HOST=http://artifact.simplivt.local:8081/artifactory/api/gems/gems-foxhound-local"
  export RUBYGEMS_HOST=http://artifact.simplivt.local:8081/artifactory/api/gems/gems-foxhound-local
else 
  echo "RUBYGEMS_HOST is already set: ${RUBYGEMS_HOST}"
fi

########################################################################
## To Build a gem
##   gem build <gemspec>
##
## To push a gem, do the following:
##   gem push <gemname> --host $RUBYGEMS_HOST
##
## To list all versions of a gem
##   gem list <gemname> --remote --all
########################################################################
