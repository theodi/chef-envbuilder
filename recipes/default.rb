#
# Cookbook Name:: envbuilder
# Recipe:: default
#
# Copyright 2013, The Open Data Institute
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

class Chef::Recipe
  include ODI::Envbuilder::Helpers
end

default_data = walk bag_item(
  node["envbuilder"]["data_bag"],
  node["envbuilder"]["base_dbi"]
)['content']

environment_data = walk bag_item(
  node["envbuilder"]["data_bag"],
  node["ENV"] || node.chef_environment
)['content']

master_list = walk bag_item(
  node["envbuilder"]["data_bag"],
  'master_list'
)['content']

merged_data = (default_data).update (environment_data)

merged_data.each do |k, v|
  if v == 'DEFAULT'
    merged_data[k] = master_list[k]
  end
end

content = dump_hash merged_data

group node["envbuilder"]["group"] do
  action :create
end

user node["envbuilder"]["owner"] do
  gid node["envbuilder"]["group"]
  shell "/bin/bash"
  home "/home/%s" % [
      node["envbuilder"]["owner"]
  ]
  supports :manage_home => true
  action :create
end

directory node["envbuilder"]["base_dir"] do
  mode "0755"
  owner node["envbuilder"]["owner"]
  group node["envbuilder"]["group"]

  recursive true
  action :create
end

file File.join(
         node["envbuilder"]["base_dir"],
         node["envbuilder"]["filename"]
     ) do
  mode node["envbuilder"]["file_permissions"]
  owner node["envbuilder"]["owner"]
  group node["envbuilder"]["group"]

  action :create
  content content
end
