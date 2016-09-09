#!/bin/bash --

if [ -z $1 ];then
  echo "Please provide a module name!"
  exit 1
fi

module="$1"
moduledir="/vagrant/modules/${module}"
cat <<FIN
module => ${module}
moduledir => ${moduledir}
FIN

sudo gem install bundler
sudo gem install rake
sudo yum -y install git
sudo yum -y install xterm.x86_64

write_keymaster_prep() {
  #prep file for keymaster
  if [ "X${module}" = "Xkeymaster" ];then
    mkdir -p ${moduledir}/prep
    cat << FIN > ${moduledir}/prep/prep.sh
echo "Running Prep Script"
mkdir -p /var/lib/keymaster/openssh/tester_at_test.example.org
mkdir -p /var/lib/keymaster/host_key/test.example.org
mkdir -p /var/lib/keymaster/x509/test.example.org
echo 'ssh-rsa THISISAFAKERSAHASH foo@baa' > /var/lib/keymaster/openssh/tester_at_test.example.org/key.pub
echo '-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----' > /var/lib/keymaster/host_key/test.example.org/key
echo 'ssh-rsa THISISAFAKERSAHASH foo@baa' > /var/lib/keymaster/host_key/test.example.org/key.pub
echo '-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----' > /var/lib/keymaster/x509/test.example.org/key.pem
echo '-----BEGIN CERTIFICATE REQUEST-----THISISAFAKEHASH-----END CERTIFICATE REQUEST-----' > /var/lib/keymaster/x509/test.example.org/request.csr
echo '-----BEGIN CERTIFICATE-----THISISAFAKEHASH-----END CERTIFICATE-----' > /var/lib/keymaster/x509/test.example.org/certificate.crt
echo '-----BEGIN CERTIFICATE-----THISISAFAKEPEM-----END CERTIFICATE-----' > /var/lib/keymaster/x509/test.example.org/certificate.pem
echo '-----BEGIN CERTIFICATE-----THISISAFAKEP12-----END CERTIFICATE-----' > /var/lib/keymaster/x509/test.example.org/certificate.p12
echo '-----BEGIN CERTIFICATE-----THISISAFAKEPFX-----END CERTIFICATE-----' > /var/lib/keymaster/x509/test.example.org/certificate.pfx
echo "Done Running Prep Script"
FIN
  fi
}

exec_keymaster_prep() {
  chmod +x ${moduledir}/prep/prep.sh
  sudo ${moduledir}/prep/prep.sh
  ###########################################################
  ## On a puppet master these files should be owned by puppet
  ## But where we're executing as vagrant, they need to be 
  ## accessible by vagrant
  sudo chmod -R 755   /var/lib/keymaster
}

write_gemfile() {
  cat << FIN > ${moduledir}/Gemfile
source 'https://rubygems.org'

gem 'puppet', '3.7.5'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '< 1.1.0'
gem 'facter', '>= 1.7.0'
gem 'rspec',       '< 3'
gem 'rspec-puppet', '2.2.0'
FIN
}

write_fixtures_yml() {
  cat << FIN > ${moduledir}/.fixtures.yml
fixtures:
  symlinks:
    puppet:       "#{source_dir}/../puppet"
    ${module}:    "#{source_dir}"
    stdlib:       "#{source_dir}/../stdlib"
  forge_modules:
    ssh:
      repo: "saz/ssh"
      ref: "2.8.1"

FIN
}
if [[ -n "${module}" &&  -d ${moduledir} ]];then
  echo "######################## ${module} #########################"
  echo "Installing  vendor gems in module dir  ${moduledir}"
  echo "############################################################"
  #write_gemfile
  rm -rf ${moduledir}/vendor
  rm -f ${moduledir}/Gemfile.lock
  pushd ${moduledir} && bundle install --path vendor/gems
  popd
  write_fixtures_yml
  write_keymaster_prep
  exec_keymaster_prep
else
  echo "The module '${module}' is not defined or module dir '${moduledir}' does not exist"
fi


echo "This should now work"
echo "cd ${moduledir} &&  bundle exec rake spec 2>&1 | less"
