# XML to Hash

Ruby gem to convert XML into Hash (and into JSON). 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xml-to-hash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xml-to-hash

## Usage

```ruby
include 'xml/to/hash'

xml_string = STR_XML = <<-EOS
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

xml = Nokogiri::XML STR_XML
hash = xml.to_hash

puts JSON.pretty_generate(hash)
```

produces

```json
{
  "type": "element",
  "name": "myRoot",
  "children": [
    {
      "type": "text",
      "content": "\n      some text\n      "
    },
    {
      "type": "comment",
      "content": "\n      In comments we can use ]]>\n      <\n      &, ', and \", but %MyParamEntity; will not be expanded"
    },
    {
      "type": "text",
      "content": "\n      "
    },
    {
      "type": "cdata",
      "content": "\n      Character Data block <!-- <, & ' \" -->  *and* %MyParamEntity;  \n      "
    },
    {
      "type": "text",
      "content": "\n      "
    },
    {
      "type": "pi",
      "name": "linebreak"
    },
    {
      "type": "text",
      "content": "\n      "
    },
    {
      "type": "element",
      "attrs": [
        {
          "name": "how-deep",
          "value": "very-deep"
        }
      ],
      "name": "deeper",
      "namespace": {
        "href": "lol://some-namespace"
      },
      "children": [
        {
          "type": "text",
          "content": "randomtext\n      "
        },
        {
          "type": "element",
          "attrs": [
            {
              "name": "my-attr",
              "value": "just an attribute",
              "namespace": {
                "href": "lol://my.name.space/",
                "prefix": "lol"
              }
            },
            {
              "name": "deeper",
              "value": "true"
            }
          ],
          "name": "even",
          "namespace": {
            "href": "lol://some-namespace"
          },
          "children": [
            {
              "type": "text",
              "content": "O"
            }
          ]
        }
      ]
    },
    {
      "type": "text",
      "content": "  \n"
    }
  ]
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/digitalheir/xml-to-hash. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

