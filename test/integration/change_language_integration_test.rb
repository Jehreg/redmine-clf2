require File.dirname(__FILE__) + '/../test_helper'

class ChangeLanguageIntegrationTest < ActionController::IntegrationTest
  include Redmine::I18n
  
  context "can change language by visiting a url" do
    setup do
      setup_anonymous_role
      setup_non_member_role
      User.current = User.anonymous
    end
    
    should "change to french when visiting /french" do
      get '/'
      assert_response :success
      assert_template "welcome/index"
      assert_equal nil, session[:language]
      
      get '/french'
      assert_response :redirect
      assert_redirected_to :controller => 'welcome', :action => 'index'
      assert_equal 'fr', session[:language]
    end

    should "change to english when visiting /english" do
      get '/'
      assert_response :success
      assert_template "welcome/index"
      assert_equal nil, session[:language]
      
      get '/english'
      assert_response :redirect
      assert_redirected_to :controller => 'welcome', :action => 'index'
      assert_equal 'en', session[:language]
    end
  end
end
