require 'rubygems'
require 'activesupport'
require 'activeresource'
require 'rexml/document'
require 'uri'
require 'sds-rest'

module SDSActiveResource
  
  class Base < ActiveResource::Base

    def self.connection(refresh = false)
        @connection = SDSConnection.new(super.site, super.format) if refresh || @connection.nil?
        @connection.user = user
        @connection.password = password
        @connection
    end
    
    #we don't want to create XML, we want to pass the attributes directly to the SDS service where the XML can be created
    def to_xml(options={})
      newattributes = {}
      newattributes.merge! attributes
      newattributes["entityname"] = self.class.element_name
      newattributes
    end

    def self.query(query)
      instantiate_collection(@connection.query(collection_path(), query))
    end
  end
  
  class SDSConnection < ActiveResource::Connection
    
    def service
      @service = SDSRest::Service.new :username => user, :password => password, :authority => get_authority(site), :url => get_url(site) if @service.nil?
      @service
    end
    
    def query(path, query)
      container = get_container(path)
      query.gsub!(/AND/i, "%26%26 ")
      response = service.query(container, query)
      entity = REXML::Document.new(response.body)
      entities = []
      
      entity.root().elements.each { |element| 
        options = {}      
        element.elements.each { |element2|       
          options[element2.name] = parse_value(element.attributes["xsi:type"], element2.text)
        }
        entities.push(options)
        }

      entities
    end
    
    def post(path, body = '', headers = {})
      container = get_container(path)
      response = service.create_entity(container, body["entityname"], body["Id"], body)
      response['location'] = "test/" + body["Id"].to_s
      response
    end   
    
    def delete(path, body = '', headers = {})
      container = get_container(path)
      id = get_id(path)
      service.delete_entity(container, id)
    end    
        
    def put(path, body = '', headers = {})
      container = get_container(path)  
      response = service.update_entity(container, body["name"], body["Id"], nil, body)
      response['location'] = "test/" + body["Id"].to_s
      response
    end
        
    def get(path, headers = {})
      container = get_container(path)
      entityname = get_entity(path)
      id = get_id(path)
      if(id.nil?)
        query = 'from e in entities where e.Kind == "' + entityname.singularize + '" select e'
        response = service.query(container, query)
        entity = REXML::Document.new(response.body)
        entities = []
        
        entity.root().elements.each { |element| 
          options = {}      
          element.elements.each { |element2|       
            options[element2.name] = parse_value(element2.attributes["xsi:type"], element2.text)
          }
          entities.push(options)
          }

        entities        
      else
        
      response = service.get_entity(container, id)
          
      entity = REXML::Document.new(response.body)
     
      options = {}      
      entity.root().elements.each { |element|      
          options[element.name] = parse_value(element.attributes["xsi:type"], element.text)
      }
      options['id'] = id
      options
      
      end
    end
        
    def get_authority(path)
     splitpath = URI::split(path.to_s)
     splitpath[2].split('.')[0]
    end
    
    def get_url(path)
      splitpath = URI::split(path.to_s)
      host = splitpath[2]
      host[get_authority(path) + "."] = ""
      host
    end
    
    def get_params(path)
      puts path
      if(path.include? "?")
        params = path.split('?')[1]  
        params || ""
      end
    end
      
    def get_container(path)
      container = path.to_s.split('/')[1]
      
      if(container.nil?)
        raise "no container found"
      end
      container
    end
    
    def get_entity(path)
      path.delete! '.xml'
      entity = path.split('/')[2]
      
      if(entity.include? "?")
        entity = entity.split('?')[0]  
      end
      
      if(entity.nil?)
        raise "no entity found"
      end
      entity
    end
    
    def parse_value(type, value)
      if(type == "x:decimal")
        if(value.include?("."))
          Float(value)
        else
          Integer(value)
        end
      elsif(type == "x:boolean")
        Boolean(value)
      elsif(type == "x:dateTime")
        DateTime.parse(value)
      else
        value
      end    
    end
    
    def get_id(path)
      path.delete! '.xml'
      path.to_s.split('/')[3]
    end
    
    def Boolean(string)
        return true if string == true || string =~ /^true$/i
        return false if string == false || string.nil? || string =~ /^false$/i
        raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
    end
  
  end
end