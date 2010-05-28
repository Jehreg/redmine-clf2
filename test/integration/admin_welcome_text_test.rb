require File.dirname(__FILE__) + '/../test_helper'

class AdminWelcomeText < ActionController::IntegrationTest
  include Redmine::I18n

  context "welcome text settings" do
    setup do
      setup_anonymous_role
      setup_non_member_role
      @user = User.generate_with_protected!(:admin => true, :password => 'test', :password_confirmation => 'test')
      @english_welcome = "hello"
      @french_welcome = "bonjour"
      Setting.welcome_text = @english_welcome
      Setting.plugin_redmine_clf2 = {'welcome_text_fr' => @french_welcome}
      log_user(@user.login, 'test')
    end

    context "in English" do
      setup do
        get "/settings"
      end

      should "show the english text in the welcome text field" do
        assert_select "#settings_welcome_text", :text => @english_welcome
      end
      
      should "show the french text in the welcome_fr text field" do
        assert_select "#settings_plugin_redmine_clf2_welcome_text_fr", :text => @french_welcome
      end

    end
    
    context "in French" do
      setup do
        get "/french"
        get "/settings"
      end

      should "show the english text in the welcome text field" do
        assert_select "#settings_welcome_text", :text => @english_welcome
      end
      
      should "show the french text in the welcome_fr text field" do
        assert_select "#settings_plugin_redmine_clf2_welcome_text_fr", :text => @french_welcome
      end
      

    end
  end
end
