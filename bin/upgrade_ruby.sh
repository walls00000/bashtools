#!/bin/bash --
force=""
if [ "X$1" = "Xforce" ];then
  force=true
fi

installRuby2() {
  targetversion="2.1.2p95"
  rubyversion=`ruby --version` 
  echo "${rubyversion}" | grep ${targetversion}
  ret=`echo $?`
  if [[ ${ret} -eq 0 && "X${force}" = "X" ]];then
    echo "Ruby is already at ${targetversion}"
    return
  else
    echo "Upgrading ruby version from ${rubyversion} to ${targetversion}"
    cd ~/.
    sudo yum -y remove ruby ruby-devel
    sudo yum -y groupinstall "Development Tools"
    sudo yum -y install openssl-devel
    wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
    tar xvfvz ruby-2.1.2.tar.gz
    cd ruby-2.1.2
    ./configure
    make
    sudo make install
  fi
}

installGems() {
  gems="bundler highline hiera-eyaml hiera-gpg" 
  gemcmd=`which gem`
  sudo ${gemcmd} update --system
  sudo ${gemcmd} update
  for gem in ${gems}
  do
    gem list | grep ${gem}
    ret=`echo $?`
    if [ ${ret} -eq 0 ];then
      echo "${gem} is already installed"
    else
      echo "Installing ${gem}"
      sudo ${gemcmd} install --no-ri --no-rdoc ${gem}
    fi
  done
  ## Remove old bundle executable
  if [ -f /usr/local/bin/bundle ];then
    sudo mv /usr/bin/bundle /usr/bin/bundle.old
    sudo ln -sf /usr/local/bin/bundle /usr/bin/bundle
  fi
}

installRuby2
installGems
