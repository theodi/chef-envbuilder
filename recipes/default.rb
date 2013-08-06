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

# so it turns out I didn't remember how to recursively walk a nested hash like this :/
def walk hash, stack = [], output = {}
  hash.each do |key, val|
    stack << key
    if val.is_a?(Hash)
      walk val, stack, output
    else
      output[stack.join(node["envbuilder"]["joiner"]).upcase] = val
      stack.pop
    end
  end
  stack.pop

  output
end

def dump_hash hash
  s = ''
  hash.each do |key, val|
    s << "%s: %s\n" % [
        key,
        val
    ]
  end

  s
end

def use_encrypted_data_bag?
  !!node["envbuilder"]["use_encrypted_data_bag"]
end

def bag_item(bag_name, item_name)
  if use_encrypted_data_bag?
    Chef::EncryptedDataBagItem.load(bag_name, item_name)
  else
    data_bag_item(bag_name, item_name)
  end
end

default_item = bag_item(
  node["envbuilder"]["data_bag"],
  node["envbuilder"]["base_dbi"]
)

environment_item = bag_item(
  node["envbuilder"]["data_bag"],
  node["ENV"] || node.chef_environment
)

merged_item = (walk default_item["content"]).update (walk environment_item["content"])
content = dump_hash merged_item

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
  owner node["envbuilder"]["owner"]
  group node["envbuilder"]["group"]

  action :create
  content content
end
