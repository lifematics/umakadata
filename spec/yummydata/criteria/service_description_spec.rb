require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'ServiceDescription' do

      describe '#service_description' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::ServiceDescription } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com')
        end

        def read_file(file_name)
          cwd = File.expand_path('../../../data/yummydata/criteria/service_description', __FILE__)
          File.open(File.join(cwd, file_name)) do |file|
            file.read
          end
        end

        it 'should return service description object when valid response is retrieved of ttl format' do
          valid_ttl = read_file('good_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(valid_ttl)

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::TURTLE
          expect(service_description.text).to eq valid_ttl
          expect(service_description.modified).to eq "2016-01-01 10:00:00"
          expect(service_description.get_error("service_description_text")).to eq nil
        end

        it 'should return service description object when response is retrieved of xml format' do
          valid_ttl = read_file('good_xml_01.xml')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(valid_ttl)

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::RDFXML
          expect(service_description.text).to eq valid_ttl
          expect(service_description.modified).to eq "2016-01-01 10:00:00"
          expect(service_description.get_error("service_description_text")).to eq nil
        end

        it 'should return false description object when invalid response is retrieved' do
          invalid_ttl = read_file('bad_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(invalid_ttl)

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::UNKNOWN
          expect(service_description.text).to eq nil
          expect(service_description.get_error("service_description_text")).to eq "Neither turtle nor rdfxml"
        end

        it 'should return false description object when client error response is retrieved' do
          invalid_ttl = read_file('good_turtle_01.ttl')
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return("404 Not Found")

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::UNKNOWN
          expect(service_description.text).to eq nil
          expect(service_description.modified).to eq nil
          expect(service_description.response_header).to eq ''
          expect(service_description.response_header).to eq ''
          expect(service_description.get_error("service_description_text")).to eq '404 Not Found'
          expect(service_description.get_error("service_description_response_header")).to eq '404 Not Found'
        end

        it 'should return false description object when server error response is retrieved' do
          invalid_ttl = read_file('good_turtle_01.ttl')
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return("500 Server Error")

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::UNKNOWN
          expect(service_description.text).to eq nil
          expect(service_description.modified).to eq nil
          expect(service_description.response_header).to eq ''
          expect(service_description.response_header).to eq ''
          expect(service_description.get_error("service_description_text")).to eq '500 Server Error'
          expect(service_description.get_error("service_description_response_header")).to eq '500 Server Error'
        end

      end
    end
  end
end
