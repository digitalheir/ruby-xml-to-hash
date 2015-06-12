$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'xml/to/hash'
require 'xml-to-hash'

PRECOMPILED_HASH = {:type => :element, :name => 'myRoot', :children => [{:type => :text, :content => "\n      some text\n      "}, {:type => :comment, :content => "\n      In comments we can use ]]>\n      <\n      &, ', and \", but %MyParamEntity; will not be expanded"}, {:type => :text, :content => "\n      "}, {:type => :cdata, :content => "\n      Character Data block <!-- <, & ' \" -->  *and* %MyParamEntity;  \n      "}, {:type => :text, :content => "\n      "}, {:type => :pi, :name => 'linebreak'}, {:type => :text, :content => "\n      "}, {:type => :element, :attrs => [{:name => 'how-deep', :value => 'very-deep'}], :name => 'deeper', :namespace => {:href => 'lol://some-namespace'}, :children => [{:type => :text, :content => "randomtext\n      "}, {:type => :element, :attrs => [{:name => 'my-attr', :value => 'just an attribute', :namespace => {:href => 'lol://my.name.space/', :prefix => 'lol'}}, {:name => 'deeper', :value => 'true'}], :name => 'even', :namespace => {:href => 'lol://some-namespace'}, :children => [{:type => :text, :content => 'O'}]}]}, {:type => :text, :content => "  \n"}]}
STR_XML = <<-EOS
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE author [
  <!ELEMENT author (#PCDATA)>
  <!ENTITY MyParamEntity "Has been expanded">
  <!ENTITY js "Me">
]>
<myRoot>
      some text
      <!--
      In comments we can use ]]>
      <
      &, ', and ", but %MyParamEntity; will not be expanded-->
      <![CDATA[
      Character Data block <!-- <, & ' " -->  *and* %MyParamEntity;  
      ]]>
      <?linebreak?>
      <deeper xmlns="lol://some-namespace" how-deep="very-deep">randomtext
      <even 
        lol:my-attr="just an attribute" 
        xmlns:lol=\'lol://my.name.space/\' deeper="true">O</even></deeper>  
</myRoot>
EOS