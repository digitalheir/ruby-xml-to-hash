# noinspection RubyResolve
require 'spec_helper'
require 'json'

describe Xml::To::Hash do
  it 'has a version number' do
    expect(Xml::To::Hash::VERSION).not_to be nil
  end

  it 'generate a to_hash method on Nokogiri::XML::Node' do
    expect(Nokogiri::XML::Node.method_defined? :to_hash).to eq(true)
  end

  ######
  # DTD
  ######
  DTD_HASH = Nokogiri::XML(STR_XML).to_hash


  it 'handles notations in the DTD' do
    field = :notations

    precompiled_hashes = FULL_DOC_HASH[:children][0][field]
    generated = DTD_HASH[:children][0][field]
    precompiled_hashes.each do |hash|
      expect(generated.include?(hash)).to eq(true)
    end
  end

  it 'handles entities in the DTD' do
    field=:entities

    precompiled_hashes = FULL_DOC_HASH[:children][0][field]
    generated = DTD_HASH[:children][0][field]
    precompiled_hashes.each do |hash|
      expect(generated.include?(hash)).to eq(true)
    end
  end
  it 'handles elements and atributes in the DTD' do
    field=:elements

    precompiled_hashes = FULL_DOC_HASH[:children][0][field]
    generated = DTD_HASH[:children][0][field]
    precompiled_hashes.each do |hash|
      expect(generated.include?(hash)).to eq(true)
    end
  end

  it 'handles elements' do
    expect(FULL_DOC_HASH[:children][1]).to eq(DTD_HASH[:children][1])
  end
end
