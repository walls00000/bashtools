#!/bin/bash --

for param in $@
do
  cat <<FIN
  context 'with ${param} set to foo' do
    let(:params) do
        {
            :${param} => 'foo',
        }
      end
      it { should contain_class('${MYCLASS}').with(
          {
              :${param} => 'foo',
          }
      ) }
  end

FIN
done

echo
echo '  ################'
echo '  ## BAD PARAMS ##'
echo '  ################'
echo

for param in $@
do
  cat <<FIN
  context 'with bad ${param}' do
    let(:params) do { :${param} => ['foo'], } end
    it  { expect { should compile }.to raise_error( Puppet::Error, /is not a string/)}
  end

FIN
done
