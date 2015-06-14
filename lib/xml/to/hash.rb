require 'nokogiri'

module Xml
  # noinspection RubyClassModuleNamingConvention
  module To
    module Hash
      VERSION = '1.0.1'

      def add_children!(node, hash, blacklist=[])
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
      include Xml::To::Hash

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
      include Xml::To::Hash

      def to_hash
        hash = {}
        if name
          hash[:name] = name
        end
        if prefix
          hash[:prefix] = prefix
        end
        if occur
          case occur
            when ONCE
              hash[:occur] = :once
            when OPT
              hash[:occur] = :opt
            when MULT
              hash[:occur] = :mult
            when PLUS
              hash[:occur] = :plus
            else
              raise "Could not handle occur value #{occur}"
          end
        end
        if type
          case type
            when PCDATA
              hash[:type] = :pcdata
            when ELEMENT
              hash[:type] = :element
            when SEQ
              hash[:type] = :seq
            when OR
              hash[:type] = :or
            else
              raise "Could not handle type value #{occur}"
          end
        end
        add_children! self, hash
        hash
      end
    end
    class Node
      include Xml::To::Hash
      # Returns node type as symbol instead of integer
      def self.get_type(int)
        case int
          # Element node type, see Nokogiri::XML::Node#element?
          when Nokogiri::XML::Node::ELEMENT_NODE
            return :element
          # Attribute node type
          when Nokogiri::XML::Node::ATTRIBUTE_NODE
            return :attribute
          # Text node type, see Nokogiri::XML::Node#text?
          when Nokogiri::XML::Node::TEXT_NODE
            return :text
          # CDATA node type, see Nokogiri::XML::Node#cdata?
          when Nokogiri::XML::Node::CDATA_SECTION_NODE
            return :cdata
          # Entity reference node type
          when Nokogiri::XML::Node::ENTITY_REF_NODE
            return :entity_ref
          # Entity node type
          when Nokogiri::XML::Node::ENTITY_NODE
            return :entity
          # PI node type
          when Nokogiri::XML::Node::PI_NODE
            return :pi
          # Comment node type, see Nokogiri::XML::Node#comment?
          when Nokogiri::XML::Node::COMMENT_NODE
            return :comment
          # Document node type, see Nokogiri::XML::Node#xml?
          when Nokogiri::XML::Node::DOCUMENT_NODE
            return :document
          # Document type node type
          when Nokogiri::XML::Node::DOCUMENT_TYPE_NODE
            return :document_type
          # Document fragment node type
          when Nokogiri::XML::Node::DOCUMENT_FRAG_NODE
            return :document_fraf
          # Notation node type
          when Nokogiri::XML::Node::NOTATION_NODE
            return :notation
          # HTML document node type, see Nokogiri::XML::Node#html?
          when Nokogiri::XML::Node::HTML_DOCUMENT_NODE
            return :html_doc
          # DTD node type
          when Nokogiri::XML::Node::DTD_NODE
            return :dtd
          # Element declaration type
          when Nokogiri::XML::Node::ELEMENT_DECL
            return :element_declaration
          # Attribute declaration type
          when Nokogiri::XML::Node::ATTRIBUTE_DECL
            return :attribute_declaration
          # Entity declaration type
          when Nokogiri::XML::Node::ENTITY_DECL
            return :entity_declaration
          # Namespace declaration type
          when Nokogiri::XML::Node::NAMESPACE_DECL
            return :namespace_declaration
          # XInclude start type
          when Nokogiri::XML::Node::XINCLUDE_START
            return :xinclude_start
          # XInclude end type
          when Nokogiri::XML::Node::XINCLUDE_END
            return :xinclude_end
          # DOCB document node type
          when Nokogiri::XML::Node::DOCB_DOCUMENT_NODE
            return :docb_document
          else
            raise "Could not handle node type #{int}"
        end
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

      # Serialize this Node to a hash
      #
      # Example:
      #    >> Nokogiri::XML('<xml>hello</xml>').root.to_hash
      #    => {:type=>:element, :name=>"xml", :children=>[{:type=>:text, :content=>"hello"}]}
      def to_hash
        def set_if_respond_to!(hash, meth, blacklist=[])
          unless blacklist.include? node_type
            if respond_to? meth
              val = send(meth)
              if val
                if Node.get_type(node_type).to_s == val
                  puts "Consider blacklisting #{val} for #{meth}"
                end
                if val.respond_to? :to_hash
                  val = val.to_hash
                end
                hash[meth] = val
              end
            end
          end
        end

        # Helper functions
        def set_object_array!(hash, meth)
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

        def set_content!(hash, blacklist=[])
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

        # Initialize hash
        hash = {
            type: Node.get_type(node_type),
        }

        # Treat elements a little bit differently
        case node_type
          when Nokogiri::XML::Node::DTD_NODE
            set_object_array!(hash, :elements)
            set_object_array!(hash, :entities)
            set_object_array!(hash, :notations)
          when Nokogiri::XML::Node::ELEMENT_DECL
          when Nokogiri::XML::Node::ENTITY_DECL
            set_if_respond_to! hash, :original_content
          else
        end

        set_if_respond_to! hash, :name, [Node::DOCUMENT_NODE, Node::TEXT_NODE, Node::COMMENT_NODE]
        set_if_respond_to! hash, :external_id # For DTD, entity declarations
        set_if_respond_to! hash, :entity_type # For Entity declarations
        set_if_respond_to! hash, :system_id # For Entity declarations
        set_if_respond_to! hash, :attribute_type # For attribute declarations
        set_if_respond_to! hash, :default # For attribute declarations
        set_if_respond_to! hash, :enumeration # For attribute declarations
        set_if_respond_to! hash, :element_type # For element declarations
        set_if_respond_to! hash, :prefix # For element declarations

        set_content! hash, [Node::DOCUMENT_NODE, Node::ELEMENT_NODE]
        set_attributes! hash
        set_if_respond_to! hash, :line
        if respond_to? :namespace and namespace
          hash[:namespace] = namespace.to_hash
        end

        # Recurse into children
        add_children! self, hash, [Nokogiri::XML::Node::DTD_NODE, Node::ATTRIBUTE_NODE]
        hash
      end
    end
  end
end
