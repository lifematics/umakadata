require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'VoID' do

      describe '#void_on_well_known_uri' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::VoID } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com/.well-known/void')
        end

        def read_file(file_name)
          cwd = File.expand_path('../../../data/yummydata/criteria/void', __FILE__)
          File.open(File.join(cwd, file_name)) do |file|
            file.read
          end
        end

        it 'should return void object when valid response is retrieved of ttl format' do
          valid_ttl = read_file('good_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return(response)
          allow(target).to receive(:well_known_uri).and_return(@uri)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(valid_ttl)

          void = target.void_on_well_known_uri(@uri)

          expect(void.license.include?('http://creativecommons.org/licenses/by/2.1/jp/')).to be true
          expect(void.publisher.include?('http://www.example.org/Publisher')).to be true
          expect(void.modified.include?("2016-01-01 10:00:00")).to be true

        end

        it 'should return void object when valid response is retrieved of xml format' do
          valid_ttl = read_file('good_xml_01.xml')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return(response)
          allow(target).to receive(:well_known_uri).and_return(@uri)
          allow(response).to receive(:body).and_return(valid_ttl)

          void = target.void_on_well_known_uri(@uri)

          expect(void.license.include?('http://creativecommons.org/licenses/by/2.1/jp/')).to be true
          expect(void.publisher.include?('http://www.example.org/Publisher')).to be true
          expect(void.modified.include?("2016-01-01 10:00:00")).to be true
        end

        it 'should return false description object when invalid response is retrieved' do
          invalid_ttl = read_file('bad_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return(response)
          allow(target).to receive(:well_known_uri).and_return(@uri)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(invalid_ttl)

          void = target.void_on_well_known_uri(@uri)

          expect(void.license).to eq nil
          expect(void.publisher).to eq nil
          expect(void.modified).to eq nil
        end

        it 'should set error message when invalid response is retrieved' do
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return("500 Server Error")
          allow(target).to receive(:well_known_uri).and_return(@uri)

          void = target.void_on_well_known_uri(@uri)

          expect(void.get_error).to eq "500 Server Error"
          expect(void.license).to eq nil
          expect(void.publisher).to eq nil
          expect(void.modified).to eq nil
        end

        it 'should set error message when dcterms:modified is empty' do
          valid_ttl = read_file('good_turtle_02.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return(response)
          allow(target).to receive(:well_known_uri).and_return(@uri)
          allow(response).to receive(:body).and_return(valid_ttl)

          void = target.void_on_well_known_uri(@uri)

          expect(void.get_error).to eq "dcterms:modified is empty"
          expect(void.license.include?('http://creativecommons.org/licenses/by/2.1/jp/')).to be true
          expect(void.publisher.include?('http://www.example.org/Publisher')).to be true
          expect(void.modified).to eq nil
        end

      end
    end
  end
end
