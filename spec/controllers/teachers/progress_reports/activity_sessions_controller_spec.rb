require 'rails_helper'

describe Teachers::ProgressReports::ActivitySessionsController, :type => :controller do
  include ProgressReportHelper
  render_views

  let(:teacher) { FactoryGirl.create(:teacher) }

  describe 'GET #index' do
    let(:classroom) { FactoryGirl.create(:classroom_with_one_student, teacher: teacher) }
    let(:classroom_activity) { FactoryGirl.create(:classroom_activity, classroom: classroom, unit: classroom.units.first) }
    let(:activity_session) { FactoryGirl.create(:activity_session,
                                                state: 'finished',
                                                classroom_activity: classroom_activity) }

    before do
      session[:user_id] = teacher.id # sign in, is there a better way to do this in test?
    end

    it 'displays the html' do
      get :index, {}
      expect(response.status).to eq(200)
    end
  end

  context 'XHR GET #index' do
    before do
      setup_topics_progress_report
    end

    it 'requires a logged-in teacher' do
      get :index
      expect(response.status).to eq(401)
    end

    context 'when logged in' do
      let(:json) { JSON.parse(response.body) }

      before do
        session[:user_id] = teacher.id
      end

      it 'fetches a list of activity sessions' do
        xhr :get, :index
        expect(response.status).to eq(200)
        expect(json['activity_sessions'].size).to eq(@visible_activity_sessions.size)
        expect(json['activity_sessions'][0]['activity_classification_name']).to_not be_nil
      end

      it 'fetches classroom, unit, and student data for the filter options' do
        xhr :get, :index
        expect(json['classrooms'].size).to eq(1)
        expect(json['units'].size).to eq(1)
        expect(json['students'].size).to eq(@visible_students.size)
      end
    end
  end

end
