#
# Cookbook Name:: kubernetes_cluster
# Recipe:: default
#
# Copyright 2015, Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Warning -- watch out for a monkey patch from the lxc cookbook
# TODO: find a way to disable it!
# https://github.com/hw-cookbooks/lxc/blob/master/libraries/monkey.rb

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

# Note that the way in which kubernetes uses build requires more RAM
# on Linux -- go for at least 1024MB, prefereable 2048MB to avoid
# out of memory errors from gcc
include_recipe 'golang'

# Make sure we have go in the path
ENV['PATH'] = "#{ENV['PATH']}:/usr/local/go/bin"

# Get kubernetes itself from git -- use a specific version because
# I've seen that the latest master sometimes has bugs :). If you keep
# the revision nil, we will actually not upgrade the git checkout on
# each run to avoid instability. You can always explicitly specify
# 'master' if you want that behavior.
kubernetes_revision = 'v0.17.0'

git '/usr/local/kubernetes' do
  repository 'https://github.com/GoogleCloudPlatform/kubernetes/'
  checkout_branch kubernetes_revision
  depth 1
  only_if { ! kubernetes_revision.nil? }

end

# Do all the go compilation steps for kubectl and friends. This
# is done automatically when you spin up a cluster, but we'd like to
# pay this cost up front and do it now so cluster startup will be
# consistently faster.

bash 'build' do
  code '/usr/local/kubernetes/build/make-clean.sh;/usr/local/kubernetes/hack/build-go.sh'
  environment 'PATH' => "#{ENV['PATH']}:/usr/local/go/bin:/opt/go/bin", 'KUBE_SKIP_CONFIRMATIONS' => 'y'
  not_if '/usr/local/kubernetes/cluster/kubectl.sh --help'
end
