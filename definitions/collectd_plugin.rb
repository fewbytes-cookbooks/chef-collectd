#
# Cookbook Name:: collectd
# Definition:: collectd_plugin
#
# Copyright 2010, Atari, Inc
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
#

define :collectd_plugin, :options => {}, :template => nil, :cookbook => nil do
  template "/etc/collectd/plugins/#{params[:name]}.conf" do
    owner "root"
    group "root"
    mode "644"
    if not params[:template]
      source "plugin.conf.erb"
      cookbook params[:cookbook] || "collectd"
    else
      source params[:template]
      cookbook params[:cookbook]
    end
    variables :name=>params[:name], :options=>params[:options]
    notifies :restart, resources(:service => "collectd")
  end
end

define :collectd_python_plugin, :options => {}, :module => nil, :path => nil do
  begin
    t = resources(:template => "/etc/collectd/plugins/python.conf")
  rescue ArgumentError, ::Chef::Exceptions::ResourceNotFound
    collectd_plugin "python" do
      options :paths=>[node[:collectd][:plugin_dir]], :modules=>{}
      template "python_plugin.conf.erb"
      cookbook "collectd"
    end
    retry
  end
  if params[:path]
    t.variables[:options][:paths] << params[:path]
  end
  t.variables[:options][:modules][params[:module] || params[:name]] = params[:options]
end

define :collectd_java_plugin, :options => {}, :module => nil, :classpath => nil, :class_name => nil do
  begin
    t = resources(:template => "/etc/collectd/plugins/java.conf")
  rescue ArgumentError, ::Chef::Exceptions::ResourceNotFound
    classpaths = %w(collectd-api generic-jmx).map{|j| "/usr/share/collectd/java/#{j}.jar"}
    collectd_plugin "java" do
      options :classpaths => classpaths, :plugins => {}
      template "java_plugin.conf.erb"
      cookbook "collectd"
    end
    retry
  end
  if params[:classpath]
    t.variables[:options][:classpaths] << params[:classpath]
  end
  params[:options][:_class_name] = params[:class_name] if params[:class_name]
  t.variables[:options][:plugins][params[:plugin] || params[:name]] = params[:options]
end
