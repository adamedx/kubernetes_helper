# kubernetes_helper

A cookbook to try out kubernetes management use cases via Chef.

## Installation

To use the cookbook, upload it to your Chef Server using Berkshelf or
knife. You can add the following line to a Berksfile:

```
cookbook 'kubernetes_helper', git: 'https://github.com/adamedx/kubernetes_helper'
```

## Usage

Once this cookbook is uploaded to your Chef Server, add the `kubernetes_helper::default`
recipe to your runlist. This will install the components required to
locally host a kubernetes cluster on a node. It won't actually start a
cluster or start the kubernetes API server.

You can then write a recipe that uses the
`kubernetes_helper_compute_cluster` resource as in the following
example:

```ruby
kubernetes_helper_compute_cluster 'local cluster' do
end
```

This will then start a kubernetes cluster with API services exposed.

License and Authors
-------------------
Copyright:: Copyright (c) 2015 Adam Edwards

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



