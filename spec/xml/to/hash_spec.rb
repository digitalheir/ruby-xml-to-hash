require 'spec_helper'
require 'json'

describe Xml::To::Hash do

  it 'has a version number' do
    expect(Xml::To::Hash::VERSION).not_to be nil
  end

  it 'generate a to_hash method on Nokogiri::XML::Node' do
    expect(Nokogiri::XML::Node.method_defined? :to_hash).to eq(true)
  end
  
  it 'generates a hash from an XML string as in the example' do
    xml = Nokogiri::XML STR_XML
    expect(PRECOMPILED_HASH).to eq(xml.to_hash)
   puts (Nokogiri::XML '<xml>hello</xml>').to_hash
  end
end
