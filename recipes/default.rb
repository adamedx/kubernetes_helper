#
# Cookbook Name:: kubernetes_cluster
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


include_recipe 'docker'

# Very strange things happen if you don't explicitly specify the etcd
# that you want to use -- the default recipe of the etcd cookbook
# tries to download one version but then assumes it is installing a
# different one if you don't specify an explicit version
node.default[:etcd][:version] = '2.1.0-alpha.0'
node.default[:etcd][:sha256] = 'd1c75ecefd809387fbf66a384349d64ab3e6302771d66da143d2047c1908eb41'
include_recipe 'etcd'

include_recipe 'curl'
include_recipe 'runit' # this will be used to run the kubernetes cluster

# TODO: Since I experienced some odd behaviors (including very slow
# compile times)  with the default recipe for
# golang, I'm going to use an alternative method of obtaining go
# that seems to work more reliably

# include_recipe 'golang'

# Get a specific version of go that is known to work
# with kubernetes
go_package_name = 'go1.4.2.linux-amd64.tar.gz'
go_package_path = ::File.join(Chef::Config[:file_cache_path], go_package_name)

remote_file go_package_path do
  source "https://storage.googleapis.com/golang/#{go_package_name}"
end

go_destination = '/usr/local'

bash 'unpack go' do
  code "tar -C '#{go_destination}' -xzf #{go_package_path}"
  not_if "bash -c #{go_destination}/go/bin/go version"
end

# Make sure we have go in the path
ENV['PATH'] = "#{ENV['PATH']}:/usr/local/go/bin"

# Get kubernetes itself from git
git '/usr/local/kubernetes' do
  repository 'https://github.com/GoogleCloudPlatform/kubernetes/'
  depth 1
  not_if { ::Dir.exist?('/usr/local/kubernetes/.git') }
end

# Do all the go compilation steps for kubectl and friends. This
# is done automatically when you spin up a cluster, but we'd like to
# pay this cost up front and do it now so cluster startup will be
# consistently faster.
bash 'build' do
  code '/usr/local/kubernetes/hack/build-go.sh'
  environment 'PATH' => "#{ENV['PATH']}:/usr/local/go/bin:/opt/go/bin", 'KUBE_SKIP_CONFIRMATIONS' => 'y'
  not_if '/usr/local/kubernetes/cluster/kubectl.sh --help'
end
