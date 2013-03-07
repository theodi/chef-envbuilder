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

directory node["envbuilder"]["base_dir"] do
  mode "0666"
  action :create
end

dbi = data_bag_item(
    node["envbuilder"]["data_bag"],
    node["ENV"]
)

# so it turns out I didn't remember how to recursively walk a nested hash like this :/
$l = []
$m = []

def walk hash
  hash.each do |key, val|
    $l << key
    if val.is_a?(Hash)
      walk val
    else
      $m << "%s: %s" % [
          $l.join("_").upcase,
          val
      ]
      $l.pop
    end
  end
  $l.pop
end

walk dbi["content"]

file File.join(
         node["envbuilder"]["base_dir"],
         node["envbuilder"]["filename"]
     ) do
  action :create
  content $m.join("\n")
end
