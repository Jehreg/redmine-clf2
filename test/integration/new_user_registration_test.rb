# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class NewUserRegistrationTest < ActionController::IntegrationTest
  include Redmine::I18n

  context "new user registrations should show a flash message" do
    setup do
      setup_anonymous_role
      setup_non_member_role
    end

    should "in English" do
      visit "/account/register"

      fill_in "Login", :with => 'new-user'
      fill_in "Password", :with => 'test'
      fill_in "Confirmation", :with => 'test'
      fill_in "Firstname", :with => 'Test'
      fill_in "Lastname", :with => 'User'
      fill_in "Email", :with => 'test@example.com'
      click_button "Submit"

      assert_response :success
      assert_equal "http://www.example.com/login?lang=eng", current_url

      assert_select "div.flash.notice", :text => /Registrations are individually activated by our personnel/i
    end

    should "in French" do
      visit "/french"
      visit "/account/register"

      fill_in "Identifiant", :with => 'new-user'
      fill_in "Mot de passe", :with => 'test'
      fill_in "Confirmation", :with => 'test'
      fill_in "Prénom", :with => 'Test'
      fill_in "Nom", :with => 'User'
      fill_in "Email", :with => 'test@example.com'
      click_button "Soumettre"

      assert_response :success
      assert_equal "http://www.example.com/login?lang=fra", current_url

      assert_select "div.flash.notice", :text => /Les inscriptions sont activées individuellement par notre personnel./
    end

  end
end

