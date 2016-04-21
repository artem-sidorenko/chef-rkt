describe file('/usr/bin/rkt') do
  it { should be_symlink }
  it { should be_linked_to '/opt/rkt/rkt' }
end

describe file('/opt/rkt/rkt') do
  it { should be_executable }
  its('mode') { should eq 0700 }
end
