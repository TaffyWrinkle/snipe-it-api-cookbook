require 'spec_helper'

describe 'snipeit_api::asset - delete action' do
  step_into :asset
  context 'when the asset exists' do
    before do
      stub_request(:get, "#{hardware_endpoint}/byserial/W80123456789")
        .to_return(
          body: {
            total: 1,
            rows: [
              {
                id: 1,
                serial: 'W80123456789',
              },
            ],
          }.to_json
        )
    end

    recipe do
      asset 'delete' do
        serial_number 'W80123456789'
        token chef_vault_item('snipe-it', 'api')['key']
        url node['snipeit']['api']['instance']
        action :delete
      end
    end

    it {
      is_expected.to delete_http_request('delete W80123456789')
        .with(
          url: ::File.join(hardware_endpoint, '1'),
          message: 'delete W80123456789',
          headers: headers
        )
    }
  end

  context 'when the asset exists and is already marked as deleted' do
    before do
      stub_request(:get, "#{hardware_endpoint}/byserial/W11123456789")
        .to_return(
          body: {
            total: 1,
            rows: [
              {
                id: 1,
                serial: 'W11123456789',
                deleted_at: {
                  date_time: '2018-11-24 12:30:12',
                  formatted: '2018-11-24 12:30 PM',
                },
              },
            ],
          }.to_json
        )
    end

    recipe do
      asset 'delete' do
        serial_number 'W11123456789'
        token chef_vault_item('snipe-it', 'api')['key']
        url node['snipeit']['api']['instance']
        action :delete
      end
    end

    it {
      is_expected.to_not delete_http_request('delete W11123456789')
        .with(
          url: ::File.join(hardware_endpoint, '1'),
          message: 'delete W11123456789',
          headers: headers
        )
    }
  end
end
