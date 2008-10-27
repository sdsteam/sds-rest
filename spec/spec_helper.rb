RAILS_ROOT = ''
RAILS_ENV = ''

$:.reject! { |e| e.include? 'TextMate' }

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sds-rest'
require 'sds-activeresource'
require 'test/unit'
require 'rubygems'
require 'shoulda'

# set your connection information for your SSDS account here.
# if you have not created an authority you can use the SSDS object to do so
ENV['username'] = 'username'
ENV['password'] = "password"
ENV['url'] = "data.beta.mssds.com"
ENV['authority'] = 'authority'

def random(length=6)  
   chars = 'abcdefghjkmnpqrstuvwxyz'  
   randomstring = ''  
   length.times { |i| randomstring << chars[rand(chars.length)] }  
   randomstring  
 end

