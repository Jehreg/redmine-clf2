require File.dirname(__FILE__) + '/../../../../test_helper'

class Clf2::Hooks::ProjectHooksTest < ActionController::TestCase
  include Redmine::Hook::Helper
  def controller
    @controller ||= WelcomeController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  def hook(args={})
    call_hook :view_projects_form, args
  end

  context "#view_projects_form" do
    setup do
      @form = mock
      @form.expects(:text_area)
      @form.expects(:text_field).returns('')
      @project = Project.generate!
    end

    should 'render a text area for the french description' do
      @response.body = hook(:project => @project, :form => @form)
    end

    should 'add a wiki toolbar for the french description' do
      @response.body = hook(:project => @project, :form => @form)
      assert_select "script", /wikiToolbar.*project_description_fr/
    end

    should 'render a text field for the french name' do
      @response.body = hook(:project => @project, :form => @form)
    end

    should 'include a label for the french name with the character limit' do
      @response.body = hook(:project => @project, :form => @form)
      assert_select 'em', /50 characters/
    end
  end
end
