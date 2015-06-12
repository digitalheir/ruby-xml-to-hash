require 'xml/to/hash/version'
require 'nokogiri'

module Xml
  module To
    module Hash
    end
  end
end
module Nokogiri
  module XML
    class Node

      # Returns node type as symbol instead of integer
      def self.get_type int
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
            return int
        end
      end

      # Serialize this Node to a hash
      #
      # Example:
      #    >> Nokogiri::XML '<xml>hello</xml>'
      #    => {:type=>:element, :name=>"xml", :children=>[{:type=>:text, :content=>"hello"}]}
      def to_hash
        Node.obj_for_node root
      end

      private
      # Given a Nokigiri XML node, create a Ruby hash 
      def self.obj_for_node node
        ret = {
            type: get_type(node.node_type),
        }
        if node.attributes and node.attributes.length > 0
          ret[:attrs] = []
          node.attributes
          node.attributes.each do |key|
            attr = key[1]
            attr_o = {
                name: key[0],
                value: attr.content
            }
            if attr.namespace
              attr_o[:namespace] = namespace_hash(attr.namespace)
            end
            ret[:attrs] << attr_o
          end
        end
        # Treat elements a little bit differently 
        case node.node_type
          when Nokogiri::XML::Node::ELEMENT_NODE, Nokogiri::XML::Node::PI_NODE
            ret[:name] = node.name
          else
            ret[:content]= node.content
        end
        if node.namespace
          ret[:namespace] = namespace_hash(node.namespace)
        end

        # Recurse into children
        if node.children and node.children.length > 0
          unless node.element?
            puts "W-What? Node had children, but was not an element (but a #{get_type node.node_type})"
          end
          ret[:children]=[]
          node.children.each do |child|
            ret[:children] << obj_for_node(child)
          end
        end
        ret
      end

      def self.namespace_hash(namespace)
        hash = {
            href: namespace.href
        }
        if namespace.prefix
          hash[:prefix] = namespace.prefix
        end
        hash
      end
    end
  end
end
