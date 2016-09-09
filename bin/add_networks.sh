pushd /vagrant/utils/dnsgenerator
GEMDIR=`gem environment | grep INSTALLATION | awk '{print $4}'`
gem uninstall dns-generator
gem build dns-generator.gemspec
gem install dns-generator-0.0.0.gem
DGENERATOR=$GEMDIR/gems/dns-generator-0.0.0/lib/generator.rb

pushd /vagrant/utils/dnsgenerator/lib
#DGENERATOR=./generator

## Use -d for dry run 
$DGENERATOR --basename foo --start 21 --end 30 --network 10.211.55 --zone simplivt.vagrant 
$DGENERATOR --basename foo --start 31 --end 50 --network 10.211.55 --zone simplivt.vagrant --reversezone 55.211.10.in-addr.arpa 
$DGENERATOR --basename foo --start 101 --end 199 --network 10.211.55 --zone simplivt.vagrant --reversezone 55.211.10.in-addr.arpa 
$DGENERATOR --basename foo --start 200 --end 254 --network 10.211.55 --zone simplivt.vagrant --reversezone 55.211.10.in-addr.arpa 
popd
popd
