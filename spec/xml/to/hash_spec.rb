require 'spec_helper'
require 'json'

describe Xml::To::Hash do
  xml = Nokogiri::XML STR_XML

  it 'has a version number' do
    expect(Xml::To::Hash::VERSION).not_to be nil
  end

  it 'generate a to_hash method on Nokogiri::XML::Node' do
    expect(Nokogiri::XML::Node.method_defined? :to_hash).to eq(true)
  end

  it 'generates a hash from an XML string as in the example' do
    expect(PRECOMPILED_HASH).to eq(xml.root.to_hash)
  end

  it 'generates a hash an arbitrary XML node' do
   
  end
end
