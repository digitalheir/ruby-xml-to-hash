require 'nokogiri'

module Xml
  # noinspection RubyClassModuleNamingConvention
  module To
    module Hash
      VERSION = '1.0.3'

      def self.get_from_map_or_raise(map, int)
        if map[int]
          map[int]
        else
          raise "Could not handle #{int}"
        end
      end

      def self.add_children!(node, hash, blacklist=[])
        unless node.respond_to? :node_type and blacklist.include? node.node_type
          if node.children and node.children.length > 0
            children_nodes=[]
            node.children.each do |child|
              children_nodes << child.to_hash
            end
            hash[:children]=children_nodes
          end
        end
      end

      def self.set_object_array!(hash, meth)
        if respond_to? meth and send(meth) and send(meth).length > 0
          hash[meth] = []
          array = send(meth)
          case meth
            when :entities, :elements, :notations
              array = array.values
            else
          end
          array.each do |el|
            hash[meth] << el.to_hash
          end
        end
        hash
      end
    end
  end
end

module Nokogiri
  module XML
    class Notation
      def to_hash
        hash = {
        }
        add_if_respond_to!(hash, :name)
        add_if_respond_to!(hash, :public_id)
        add_if_respond_to!(hash, :system_id)
        hash
      end

      private
      def add_if_respond_to!(hash, method)
        if respond_to? method and self.send method
          hash[method]= self.send method
        end
        hash
      end
    end
    class Namespace
      def to_hash
        hash = {
            href: href
        }
        if prefix
          hash[:prefix] = prefix
        end
        hash
      end
    end
    class ElementContent
      OCCUR_TO_SYMBOL_MAP = {
          ONCE => :once,
          OPT => :opt,
          MULT => :mult,
          PLUS => :plus
      }
      TYPE_TO_SYMBOL_MAP={
          PCDATA => :pcdata,
          ELEMENT => :element,
          SEQ => :seq,
          OR => :or
      }

      def to_hash
        hash = {}
        if name
          hash[:name] = name
        end
        if prefix
          hash[:prefix] = prefix
        end
        if occur
          Xml::To::Hash.get_from_map_or_raise(OCCUR_TO_SYMBOL_MAP, occur)
        end
        if type
          Xml::To::Hash.get_from_map_or_raise(TYPE_TO_SYMBOL_MAP, type)
        end
        Xml::To::Hash::add_children! self, hash
        hash
      end
    end
    class Node
      ELEMENT_TO_SYMBOL_MAP = {
          # Element node type
          Nokogiri::XML::Node::ELEMENT_NODE => :element,
          # Attribute node type
          Nokogiri::XML::Node::ATTRIBUTE_NODE => :attribute,
          # Text node type, see Nokogiri::XML::Node#text?
          Nokogiri::XML::Node::TEXT_NODE => :text,
          # CDATA node type, see Nokogiri::XML::Node#cdata?
          Nokogiri::XML::Node::CDATA_SECTION_NODE => :cdata,
          # Entity reference node type
          Nokogiri::XML::Node::ENTITY_REF_NODE => :entity_ref,
          # Entity node type
          Nokogiri::XML::Node::ENTITY_NODE => :entity,
          # PI node type
          Nokogiri::XML::Node::PI_NODE => :pi,
          # Comment node type, see Nokogiri::XML::Node#comment?
          Nokogiri::XML::Node::COMMENT_NODE => :comment,
          # Document node type, see Nokogiri::XML::Node#xml?
          Nokogiri::XML::Node::DOCUMENT_NODE => :document,
          # Document type node type
          Nokogiri::XML::Node::DOCUMENT_TYPE_NODE => :document_type,
          # Document fragment node type
          Nokogiri::XML::Node::DOCUMENT_FRAG_NODE => :document_fragment,
          # Notation node type
          Nokogiri::XML::Node::NOTATION_NODE => :notation,
          # HTML document node type, see Nokogiri::XML::Node#html?
          Nokogiri::XML::Node::HTML_DOCUMENT_NODE => :html_doc,
          # DTD node type
          Nokogiri::XML::Node::DTD_NODE => :dtd,
          # Element declaration type
          Nokogiri::XML::Node::ELEMENT_DECL => :element_declaration,
          # Attribute declaration type
          Nokogiri::XML::Node::ATTRIBUTE_DECL => :attribute_declaration,
          # Entity declaration type
          Nokogiri::XML::Node::ENTITY_DECL => :entity_declaration,
          # Namespace declaration type
          Nokogiri::XML::Node::NAMESPACE_DECL => :namespace_declaration,
          # XInclude start type
          Nokogiri::XML::Node::XINCLUDE_START => :xinclude_start,
          # XInclude end type
          Nokogiri::XML::Node::XINCLUDE_END => :xinclude_end,
          # DOCB document node type
          Nokogiri::XML::Node::DOCB_DOCUMENT_NODE => :docb_document
      }

      # Returns node type as symbol instead of integer
      def self.get_symbol_for_type(int)
        Xml::To::Hash.get_from_map_or_raise(ELEMENT_TO_SYMBOL_MAP, int)
      end


      def set_attributes(hash)
        hash = hash.clone
        set_attributes!(hash)
        hash
      end

      def set_attributes!(hash)
        if respond_to? :attribute_nodes and attribute_nodes.length > 0
          hash[:attributes] = []
          attribute_nodes.each do |attr|
            hash[:attributes] << attr.to_hash
          end
        end
        hash
      end

      def set_content_in_hash!(hash, blacklist=[])
        unless blacklist.include? node_type
          if respond_to? :content and content
            c = content
            if c.class == String
              hash[:content] = c
            elsif c.is_a? Nokogiri::XML::ElementContent
              hash[:content] = c.to_hash
            else
              raise "Could not handle content class #{c.class}"
            end
          end
        end
        hash
      end

      def set_hash_if_responds!(hash, meth, blacklist=[])
        unless blacklist.include? node_type
          if respond_to? meth
            val = send(meth)
            if val
              # if Node.get_type(node_type).to_s == val
              #   puts "Consider blacklisting #{val} for #{meth}"
              # end
              if val.respond_to? :to_hash
                val = val.to_hash
              end
              hash[meth] = val
            end
          end
        end
      end

      # Serialize this Node to a hash
      #
      # Example:
      #    >> Nokogiri::XML('<xml>hello</xml>').root.to_hash
      #    => {:type=>:element, :name=>"xml", :children=>[{:type=>:text, :content=>"hello"}]}
      def to_hash
        # Initialize hash
        hash = {
            type: Node.get_symbol_for_type(node_type),
        }

        # Treat DTD nodes a little bit differently
        if node_type == Nokogiri::XML::Node::DTD_NODE
          Xml::To::Hash.set_object_array!(hash, :elements)
          Xml::To::Hash.set_object_array!(hash, :entities)
          Xml::To::Hash.set_object_array!(hash, :notations)
        end

        set_hash_if_responds! hash, :name, [Node::DOCUMENT_NODE, Node::TEXT_NODE, Node::COMMENT_NODE]
        set_hash_if_responds! hash, :external_id # For DTD, entity declarations
        set_hash_if_responds! hash, :original_content # For element and entity declarations
        set_hash_if_responds! hash, :entity_type # For Entity declarations
        set_hash_if_responds! hash, :system_id # For Entity declarations
        set_hash_if_responds! hash, :attribute_type # For attribute declarations
        set_hash_if_responds! hash, :default # For attribute declarations
        set_hash_if_responds! hash, :enumeration # For attribute declarations
        set_hash_if_responds! hash, :element_type # For element declarations
        set_hash_if_responds! hash, :prefix # For element declarations

        set_content_in_hash! hash, [Node::DOCUMENT_NODE, Node::ELEMENT_NODE]
        set_attributes! hash
        set_hash_if_responds! hash, :line
        if respond_to? :namespace and namespace
          hash[:namespace] = namespace.to_hash
        end

        # Recurse into children
        Xml::To::Hash.add_children! self, hash, [Nokogiri::XML::Node::DTD_NODE, Node::ATTRIBUTE_NODE]
        hash
      end
    end
  end
end
