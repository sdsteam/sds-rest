require 'net/http'
require 'net/https'
require 'rexml/document'
require 'yaml'

module SDSRest
  
   ssds_config = "#{RAILS_ROOT}/config/ssds.yml"

   if File.exist?(ssds_config)
     SSDSCONFIG = YAML.load_file(ssds_config)[RAILS_ENV] 
     ENV['username'] = SSDSCONFIG['username']
     ENV['password'] = SSDSCONFIG['password']
     ENV['url'] = SSDSCONFIG['url']
     ENV['authority'] = SSDSCONFIG['authority']
   end
  
  
  class Service
   
   def initialize(options={})
     @username = options[:username] || ENV['username']
     @password = options[:password] || ENV['password']
     @url = options[:url] || ENV['url']
     @authority = options[:authority] || ENV['authority']
   end
   
   def authority=(value)
     @authority = value
   end
   
   def create_authority(authority)   
     request_xml = REXML::Document.new()
     request_xml.add_element('s:Authority')
     request_xml.root().add_attribute('xmlns:s', 'http://schemas.microsoft.com/sitka/2008/03/')
     request_xml.root().add_element("s:Id")
     request_xml.root().elements["s:Id"].text = authority
     req = create_post(request_xml)
     execute_request req
   end
   
   def get_authority(authority)
     @authority = authority
     get(get_request_url)
   end
   
   def create_container(container)
     request_xml = REXML::Document.new()
     request_xml.add_element('s:Container')
     request_xml.root().add_attribute('xmlns:s', 'http://schemas.microsoft.com/sitka/2008/03/')
     request_xml.root().add_element("s:Id")
     request_xml.root().elements["s:Id"].text = container
     req = create_post(request_xml)
     execute_request req     
   end
   
   def delete_container(container)
     delete(get_request_url(container))
   end
   
   def get_container(container)
     get(get_request_url(container))
   end
   
   def create_entity(container, entity, id, options={})
     request_xml = REXML::Document.new()
     request_xml.add_element(entity)
     request_xml.root().add_attribute('xmlns:s', 'http://schemas.microsoft.com/sitka/2008/03/')
     request_xml.root().add_attribute('xmlns:x', 'http://www.w3.org/2001/XMLSchema')
     request_xml.root().add_attribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance' ) 
     request_xml.root().add_element('s:Id')
     request_xml.root().elements['s:Id'].text = id
     
     options.each { |key, value|
       request_xml.root().add_element(key.to_s)
       request_xml.root().elements[key.to_s].add_attribute('xsi:type', infer_type(value))
       request_xml.root().elements[key.to_s].text = value
     }
     req = create_post(request_xml, container)
     execute_request req
   end

   # passing in a version number means that SSDS will only delete the entity if the version
   # number equals the current version number. 
   def delete_entity(container, id, version = nil)
     url = get_request_url(container, id)
     delete(url, version)
   end
   
   # passing in a version number means that SSDS will only delete the entity if the version
   # number equals the current version number. 
   def get_entity(container, id, version = nil)
     url = get_request_url(container, id)
     get(url, version)
   end
   
   # passing in a version number means that SSDS will only delete the entity if the version
   # number equals the current version number. 
   def update_entity(container, entity, id, version = nil, options={})
     results = get_entity container, id
     entity = REXML::Document.new(results.body)
     
     options.each { |key, value|
        if(entity.root().elements[key.to_s].nil?)
          entity.root().add_element(key.to_s)
          entity.root().elements[key.to_s].add_attribute('xsi:type', infer_type(value))
        end
        
        entity.root().elements[key.to_s].text = value
      }
     url = get_request_url(container, id)
     put(url, entity, version)
   end
   
   #sends a query using the SSDS query syntax
   # 
   # examples:
   #   from c in entities select c - selects all entities
   #   from c in entities where c.Kind = 'Car' select c - select all entities of type 'Car'
   #   from c in entities where c["Make"] = 'Toyota' - select all entities with property Make that equals Toyota
   def query(container, query)
     url = get_request_url(container) + "?q=" + URI.escape(query)
     get(url)
   end
   
   def create_blob(container, blob, id)
     url = get_request_url(container)
     req = Net::HTTP::Post.new(url)       
     req.content_type = 'text'
     req.content_length = blob.to_s.size.to_s
     req['slug'] = id
     req.basic_auth @username, @password
     req.body = blob.to_s
     execute_request(req)     
   end
   
   def update_blob(container, blob, id)
      url = get_request_url(container, id)
      req = Net::HTTP::Put.new(url)       
      req.content_type = 'text'
      req.content_length = blob.to_s.size.to_s
      req['slug'] = id
      req.basic_auth @username, @password
      req.body = blob.to_s
      execute_request(req)     
    end
    
    def delete_blob(container, id)
        delete(get_request_url(container, id))   
      end
    
    def get_blob(container, id)
      get(get_request_url(container, id))
    end
    
    def infer_type(value)
      if(value.is_a?(Integer) || value.is_a?(Float))
        'x:decimal'
      elsif(value.is_a?(true.class) || value.is_a?(false.class))
        'x:boolean'
      elsif(value.is_a?(DateTime))
        'x:dateTime'
      else
        'x:string' 
      end
    end
   
   
    private
      #execute a request
      def execute_request(req)
        http = Net::HTTP.new(get_url, 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = File.join(File.dirname(__FILE__), "MSSA.pem")
        
        http.start {|http| 
          response = http.request(req)
          response
        }       
        
        #Net::HTTP.new(get_url).start {|http|
        #  response = http.request(req)
        #}
      end  
      
      #gets the base url to send the request to
      def get_url
        url = @url
        if(!@authority.nil?)
          url = @authority + "." + @url
        end

        url
      end
      
      #sends an HTTP delete request to SSDS
      def delete(url, version = nil)
        req = Net::HTTP::Delete.new(url)
        req.content_type = 'application/x-ssds+xml'
        
        if(!version.nil?)
          req['if-match'] = version;
        end
        
        req.basic_auth @username, @password
        execute_request(req)
      end
      
      #sends an HTTP get request to SSDS
      def get(url, version = nil)
        req = Net::HTTP::Get.new(url)
        req.content_type = 'application/x-ssds+xml'
        
        if(!version.nil?)
          req['if-none-match'] = version;
        end
        
        req.basic_auth @username, @password
        execute_request(req)
      end
      
      #sends an HTTP put request to SSDS
      def put(url, xml, version = nil)
        req = Net::HTTP::Put.new(url)
        req.content_type = 'application/x-ssds+xml'
        
        if(!version.nil?)
          req['if-match'] = version;
        end
        
        req.content_length = xml.to_s.size.to_s
        req.basic_auth @username, @password
        req.body = xml.to_s
        execute_request(req)
      end

      #determines the correct URL to use for a SSDS request
      def get_request_url(container = nil, id = nil)
        url = '/v1/'
        
        #add the container to the url
        if(!container.nil?)
          url = url + container
        end
        
        #add the id to the end of the url if it is present
        if(!id.nil?)
          url = url + "/" + id.to_s
        end
        
        url
      end
    
      def create_post(xml, container=nil)
        url = get_request_url(container)
        req = Net::HTTP::Post.new(url)       
        req.content_type = 'application/x-ssds+xml'
        req.content_length = xml.to_s.size.to_s
        req.basic_auth @username, @password
        req.body = xml.to_s
        req
      end
      
  end
end