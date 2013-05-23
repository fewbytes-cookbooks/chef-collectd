#
# Cookbook Name:: collectd
# Library:: default
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

def collectd_key(key)
  return key.to_s.split('_').map{|x| x.capitalize}.join() if key.instance_of?(Symbol)
  "#{key}"
end

def collectd_option(option)
  return option if option.instance_of?(Fixnum) || option == true || option == false
  "\"#{option}\""
end

def collectd_settings(options, level=0)
  indent = '  ' * level
  return "#{indent}#{collectd_option(options)}" unless options.respond_to? :each
  output = []
  options.each do |key, value|
    case value
    when Array
      value.each do |subvalue|
        output << collectd_settings({key => subvalue}, level)
      end
    when Hash
      if value.has_key? :_name
        name = value.delete(:_name)
        output << "#{indent}<#{key} \"#{name}\">\n#{collectd_settings(value, level+1)}\n#{indent}</#{key}>"
      else
        output << "#{indent}<#{key}>\n#{collectd_settings(value, level+1)}\n#{indent}</#{key}>"
      end
    else
      output << "#{indent}#{key} #{collectd_option(value)}"
    end
  end
  output.join("\n")
end
