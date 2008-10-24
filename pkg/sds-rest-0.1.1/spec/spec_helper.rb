RAILS_ROOT = ''
RAILS_ENV = ''

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sds-rest'
require 'sds-activeresource'
require 'test/unit'
require 'rubygems'
require 'shoulda'

# set your connection information for your SSDS account here.
# if you have not created an authority you can use the SSDS object to do so
ENV['username'] = 'javery'
ENV['password'] = "YAnrZWh8a3y7vw9VfF8q"
ENV['url'] = "data.beta.mssds.com"
ENV['authority'] = 'infozerktest12'

def random(length=6)  
   chars = 'abcdefghjkmnpqrstuvwxyz'  
   randomstring = ''  
   length.times { |i| randomstring << chars[rand(chars.length)] }  
   randomstring  
 end

