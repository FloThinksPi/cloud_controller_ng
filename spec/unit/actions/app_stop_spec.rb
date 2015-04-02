require 'spec_helper'
require 'actions/app_stop'

module VCAP::CloudController
  describe AppStop do
    let(:app_stop) { AppStop.new(user, user_email) }
    let(:user) { double(:user, guid: 'diug') }
    let(:user_email) { 'guy@place.io' }

    describe '#stop' do
      let(:app_model) { AppModel.make(desired_state: 'STARTED') }
      let(:process1) { AppFactory.make(state: 'STARTED') }
      let(:process2) { AppFactory.make(state: 'STARTED') }

      before do
        app_model.add_process_by_guid(process1.guid)
        app_model.add_process_by_guid(process2.guid)
      end

      it 'sets the desired state on the app' do
        app_stop.stop(app_model)
        expect(app_model.desired_state).to eq('STOPPED')
      end

      it 'creates an audit event' do
        app_stop.stop(app_model)

        event = Event.last
        expect(event.type).to eq('audit.app.stop')
        expect(event.actor).to eq('diug')
        expect(event.actor_name).to eq(user_email)
        expect(event.actee_type).to eq('v3-app')
        expect(event.actee).to eq(app_model.guid)
      end

      it 'prepares the sub-processes of the app' do
        app_stop.stop(app_model)
        app_model.processes.each do |process|
          expect(process.started?).to eq(false)
          expect(process.state).to eq('STOPPED')
        end
      end
    end
  end
end
