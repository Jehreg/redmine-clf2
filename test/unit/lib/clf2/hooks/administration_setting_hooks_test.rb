require File.dirname(__FILE__) + '/../../../../test_helper'

class Clf2::Hooks::AdministrationSettingHooksTest < ActionController::TestCase
  include Redmine::Hook::Helper
  def controller
    @controller ||= SettingsController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  def hook(args={})
    call_hook :view_settings_general_form, args
  end

  context "#view_settings_general_form" do
    should 'render a text area for the french welcome text' do
      @response.body = hook
      assert_select "textarea[id=?]", /settings_plugin_redmine_clf2_welcome_text_fr/
    end

    should 'add a wiki toolbar for the french welcome text' do
      @response.body = hook
      assert_select "script", /wikiToolbar.*settings_plugin_redmine_clf2_welcome_text_fr/
    end
  end
end
