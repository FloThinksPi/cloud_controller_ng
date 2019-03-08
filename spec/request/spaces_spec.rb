require 'spec_helper'

RSpec.describe 'Spaces' do
  let(:user) { FactoryBot.create(:user) }
  let(:user_header) { headers_for(user) }
  let(:admin_header) { admin_headers_for(user) }
  let(:organization)       { FactoryBot.create(:organization, name: 'Boardgames') }
  let!(:space1)            { FactoryBot.create(:space, name: 'Catan', organization: organization) }
  let!(:space2)            { FactoryBot.create(:space, name: 'Ticket to Ride', organization: organization) }
  let!(:space3)            { FactoryBot.create(:space, name: 'Agricola', organization: organization) }
  let!(:unaccesable_space) { FactoryBot.create(:space, name: 'Ghost Stories', organization: organization) }

  before do
    organization.add_user(user)
    space1.add_developer(user)
    space2.add_developer(user)
    space3.add_developer(user)
  end

  describe 'POST /v3/spaces' do
    it 'creates a new space with the given name and org' do
      request_body = {
        name: 'space1',
        relationships: {
          organization: {
            data: { guid: organization.guid }
          }
        },
        metadata: {
            labels: {
                hocus: 'pocus'
            },
            annotations: {
                boo: 'urns'
            }
        }
      }.to_json

      expect {
        post '/v3/spaces', request_body, admin_header
      }.to change {
        VCAP::CloudController::Space.count
      }.by 1

      created_space = VCAP::CloudController::Space.last

      expect(last_response.status).to eq(201)

      expect(parsed_response).to be_a_response_like(
        {
          'guid'          => created_space.guid,
          'created_at'    => iso8601,
          'updated_at'    => iso8601,
          'name'          => 'space1',
          'relationships' => {
            'organization' => {
              'data' => { 'guid' => created_space.organization_guid }
            }
          },
          'links' => {
            'self'         => { 'href' => "#{link_prefix}/v3/spaces/#{created_space.guid}" },
            'organization' => { 'href' => "#{link_prefix}/v3/organizations/#{created_space.organization_guid}" },
          },
          'metadata' => {
              'labels' => { 'hocus' => 'pocus' },
              'annotations' => { 'boo' => 'urns' },
          }
        }
      )
    end
  end

  describe 'GET /v3/spaces/:guid' do
    it 'returns the requested space' do
      get "/v3/spaces/#{space1.guid}", nil, user_header
      expect(last_response.status).to eq(200)

      parsed_response = MultiJson.load(last_response.body)
      expect(parsed_response).to be_a_response_like(
        {
            'guid' => space1.guid,
            'name' => 'Catan',
            'created_at' => iso8601,
            'updated_at' => iso8601,
            'relationships' => {
              'organization' => {
                'data' => { 'guid' => space1.organization_guid }
              }
            },
            'metadata' => {
                'labels' => {},
                'annotations' => {},
            },
            'links' => {
              'self' => {
                'href' => "#{link_prefix}/v3/spaces/#{space1.guid}"
              },
              'organization' => {
                'href' => "#{link_prefix}/v3/organizations/#{space1.organization_guid}"
              }
            },
        }
      )
    end
  end

  describe 'GET /v3/spaces' do
    context 'when a label_selector is not provided' do
      it 'returns a paginated list of spaces the user has access to' do
        get '/v3/spaces?per_page=2', nil, user_header
        expect(last_response.status).to eq(200)

        parsed_response = MultiJson.load(last_response.body)
        expect(parsed_response).to be_a_response_like(
          {
          'pagination' => {
            'total_results' => 3,
            'total_pages' => 2,
            'first' => {
              'href' => "#{link_prefix}/v3/spaces?page=1&per_page=2"
            },
            'last' => {
              'href' => "#{link_prefix}/v3/spaces?page=2&per_page=2"
            },
            'next' => {
              'href' => "#{link_prefix}/v3/spaces?page=2&per_page=2"
            },
            'previous' => nil
          },
          'resources' => [
            {
              'guid' => space1.guid,
              'name' => 'Catan',
              'created_at' => iso8601,
              'updated_at' => iso8601,
              'relationships' => {
                'organization' => {
                  'data' => { 'guid' => space1.organization_guid }
                }
              },
              'metadata' => {
                  'labels' => {},
                  'annotations' => {},
              },
              'links' => {
                'self' => {
                  'href' => "#{link_prefix}/v3/spaces/#{space1.guid}"
                },
                'organization' => {
                  'href' => "#{link_prefix}/v3/organizations/#{space1.organization_guid}"
                }
              }
            },
            {
              'guid' => space2.guid,
              'name' => 'Ticket to Ride',
              'created_at' => iso8601,
              'updated_at' => iso8601,
              'relationships' => {
                'organization' => {
                  'data' => { 'guid' => space2.organization_guid }
                }
              },
              'metadata' => {
                  'labels' => {},
                  'annotations' => {},
              },
              'links' => {
                'self' => {
                  'href' => "#{link_prefix}/v3/spaces/#{space2.guid}"
                },
                'organization' => {
                  'href' => "#{link_prefix}/v3/organizations/#{space2.organization_guid}"
                }
              }
            }
          ]
        }
        )
      end
    end

    context 'when a label_selector is provided' do
      let!(:spaceA) { FactoryBot.create(:space, organization: organization) }
      let!(:spaceAFruit) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'fruit', value: 'strawberry', space: spaceA) }
      let!(:spaceAAnimal) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'animal', value: 'horse', space: spaceA) }

      let!(:spaceB) { FactoryBot.create(:space, organization: organization) }
      let!(:spaceBEnv) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'env', value: 'prod', space: spaceB) }
      let!(:spaceBAnimal) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'animal', value: 'dog', space: spaceB) }

      let!(:spaceC) { FactoryBot.create(:space, organization: organization) }
      let!(:spaceCEnv) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'env', value: 'prod', space: spaceC) }
      let!(:spaceCAnimal) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'animal', value: 'horse', space: spaceC) }

      let!(:spaceD) { FactoryBot.create(:space, organization: organization) }
      let!(:spaceDEnv) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'env', value: 'prod', space: spaceD) }

      let!(:spaceE) { FactoryBot.create(:space, organization: organization) }
      let!(:spaceEEnv) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'env', value: 'staging', space: spaceE) }
      let!(:spaceEAnimal) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'animal', value: 'dog', space: spaceE) }

      it 'returns the correct spaces' do
        get '/v3/spaces?label_selector=!fruit,env=prod,animal in (dog,horse)', nil, admin_header
        expect(last_response.status).to eq(200)

        parsed_response = MultiJson.load(last_response.body)
        expect(parsed_response['resources'].map { |space| space['guid'] }).to contain_exactly(spaceB.guid, spaceC.guid)
      end
    end
  end

  describe 'PATCH /v3/spaces/:guid' do
    it 'updates the requested space' do
      request_body = {
        name: 'codenames',
        metadata: {
          labels: {
            label: 'value'
          },
          annotations: {
            potato: 'yellow'
          }
        }
      }.to_json
      patch "/v3/spaces/#{space1.guid}", request_body, admin_header
      expect(last_response.status).to eq(200)

      parsed_response = MultiJson.load(last_response.body)
      expect(parsed_response).to be_a_response_like(
        {
            'guid' => space1.guid,
            'name' => 'codenames',
            'created_at' => iso8601,
            'updated_at' => iso8601,
            'relationships' => {
                'organization' => {
                    'data' => { 'guid' => space1.organization_guid }
                }
            },
            'metadata' => {
                'labels' => {
                  'label' => 'value'
                },
                'annotations' => {
                  'potato' => 'yellow'
                }
            },
            'links' => {
                'self' => {
                    'href' => "#{link_prefix}/v3/spaces/#{space1.guid}"
                },
                'organization' => {
                    'href' => "#{link_prefix}/v3/organizations/#{space1.organization_guid}"
                }
            },
        }
      )
    end

    context 'removing labels' do
      let!(:space1Label) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'fruit', value: 'mango', space: space1) }
      let!(:space1Label) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'animal', value: 'monkey', space: space1) }

      it 'removes a label from a space when the value is set to null' do
        patch "/v3/spaces/#{space1.guid}", { metadata: { labels: { fruit: nil } } }.to_json, admin_header
        expect(last_response.status).to eq(200)

        parsed_response = MultiJson.load(last_response.body)
        expect(parsed_response).to be_a_response_like(
          {
            'guid' => space1.guid,
            'name' => space1.name,
            'created_at' => iso8601,
            'updated_at' => iso8601,
            'relationships' => {
              'organization' => {
                'data' => { 'guid' => space1.organization_guid }
              }
            },
            'metadata' => {
              'labels' => {
                'animal' => 'monkey'
              },
              'annotations' => {},
            },
            'links' => {
              'self' => {
                'href' => "#{link_prefix}/v3/spaces/#{space1.guid}"
              },
              'organization' => {
                'href' => "#{link_prefix}/v3/organizations/#{space1.organization_guid}"
              }
            },
          }
        )
      end
    end

    context 'updating labels' do
      let!(:space1_label) { VCAP::CloudController::SpaceLabelModel.make(key_name: 'fruit', value: 'mango', space: space1) }

      it 'Updates the spaces label' do
        patch "/v3/spaces/#{space1.guid}", { metadata: { labels: { fruit: 'strawberry' } } }.to_json, admin_header
        expect(last_response.status).to eq(200)

        parsed_response = MultiJson.load(last_response.body)
        expect(parsed_response).to be_a_response_like(
          {
            'guid' => space1.guid,
            'name' => space1.name,
            'created_at' => iso8601,
            'updated_at' => iso8601,
            'relationships' => {
              'organization' => {
                'data' => { 'guid' => space1.organization_guid }
              }
            },
            'metadata' => {
              'labels' => {
                'fruit' => 'strawberry'
              },
              'annotations' => {},
            },
            'links' => {
              'self' => {
                'href' => "#{link_prefix}/v3/spaces/#{space1.guid}"
              },
              'organization' => {
                'href' => "#{link_prefix}/v3/organizations/#{space1.organization_guid}"
              }
            },
          }
        )
      end
    end
  end
end
