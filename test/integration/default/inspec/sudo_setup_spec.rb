describe file('/etc/sudoers.d/rkt') do
  it { should be_file }
  its('mode') { should eq 0600 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/usr/bin/rkt') do
  it { should be_executable }
  its('mode') { should eq 0750 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'rkt' }
end
