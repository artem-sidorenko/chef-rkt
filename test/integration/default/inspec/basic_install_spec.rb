describe file('/opt/rkt/rkt') do
  it { should be_executable }
end

describe file('/opt/rkt/stage1-coreos.aci') do
  it { should be_file }
end

describe group('rkt') do
  it { should exist }
end

describe file('/etc/rkt') do
  it { should be_directory }
  its('mode') { should eq 0755 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/usr/lib/rkt') do
  it { should be_directory }
  its('mode') { should eq 0755 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/var/lib/rkt') do
  it { should be_directory }
  its('mode') { should eq 0755 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end
