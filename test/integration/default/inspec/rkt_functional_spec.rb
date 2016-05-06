describe command('rkt trust --prefix=coreos.com/etcd --trust-keys-from-https=true') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Added key for prefix "coreos.com/etcd" at' }
end

describe command('rkt fetch coreos.com/etcd:v2.3.1') do
  its('exit_status') { should eq 0 }
  its('stderr') { should match "image: signature verified:\n  CoreOS Application Signing Key <security@coreos.com>" }
  its('stdout') { should match 'sha512-' }
end

describe command('rkt image rm coreos.com/etcd') do
  its('exit_status') { should eq 0 }
  its('stderr') { should match "rm: 1 image(s) successfully removed\n" }
  its('stdout') { should match 'successfully removed aci for image: "sha512-' }
end

describe command('rkt --insecure-options=image run docker://busybox --exec /bin/true') do
  its('exit_status') { should eq 0 }
end

describe command('rkt run --trust-keys-from-https=true quay.io/coreos/alpine-sh --interactive --exec /bin/true') do
  its('exit_status') { should eq 0 }
end

describe command('rkt run --trust-keys-from-https=true quay.io/coreos/alpine-sh --interactive --exec /bin/false') do
  its('exit_status') { should eq 1 }
end
