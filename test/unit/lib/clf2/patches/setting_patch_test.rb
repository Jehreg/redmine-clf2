require File.dirname(__FILE__) + '/../../../../test_helper'

class Clf2::Patches::SettingPatchTest < ActionController::TestCase
  include Redmine::I18n

  ENGLISH_TEXT = "English welcome_text"
  FRENCH_TEXT = "French welcome_text"
  
  setup do
    Setting.welcome_text = ''
    Setting.plugin_redmine_clf2 = {'welcome_text_fr' => ''}
  end

  context "#english_welcome_text?" do
    should "be true if the English welcome_text is set" do
      with_settings :welcome_text => 'English welcome_text' do
        assert Setting.english_welcome_text?
      end
    end

    should "be false if the English welcome_text is empty" do
      with_settings :welcome_text => '' do
        assert !Setting.english_welcome_text?
      end
    end

    should "be false if the English welcome_text is nil" do
      with_settings :welcome_text => nil do
        assert !Setting.english_welcome_text?
      end
    end
  end

  context "#french_welcome_text?" do
    should "be true if the French welcome_text is set" do
      with_settings :plugin_redmine_clf2 => {'welcome_text_fr' => 'French welcome_text'} do
        assert Setting.french_welcome_text?
      end
    end

    should "be false if the French welcome_text is empty" do
      with_settings :plugin_redmine_clf2 => {'welcome_text_fr' => ''} do
        assert !Setting.french_welcome_text?
      end
    end

    should "be false if the French welcome_text is nil" do
      with_settings :plugin_redmine_clf2 => {'welcome_text_fr' => nil} do
        assert !Setting.french_welcome_text?
      end
    end
  end
  
  context "#welcome_text" do
    setup do
      set_language_if_valid(:en)
      Setting.welcome_text = ENGLISH_TEXT
      Setting.plugin_redmine_clf2 = {'welcome_text_fr' => FRENCH_TEXT}
    end

    context "default" do
      should "show the English welcome_text" do
        assert_equal ENGLISH_TEXT, Setting.welcome_text
      end
    end

    context "with :en as the current language" do
      should "show the English welcome_text" do
        set_language_if_valid(:en)
        assert_equal ENGLISH_TEXT, Setting.welcome_text
      end

      context "with an empty English welcome_text" do
        setup do
          Setting.welcome_text = nil
        end

        should "show nothing if there is no French welcome_text" do
          set_language_if_valid(:en)
          Setting.plugin_redmine_clf2 = {'welcome_text_fr' => nil}

          assert_equal '', Setting.welcome_text
        end
        
        should "show the French welcome_text" do
          set_language_if_valid(:en)

          assert_equal FRENCH_TEXT, Setting.welcome_text
        end
      end
      
    end

    context "with :fr as the current language" do
      should "show the French welcome_text" do
        set_language_if_valid(:fr)
        assert_equal FRENCH_TEXT, Setting.welcome_text
      end

      context "with an empty French welcome_text" do
        setup do
          Setting.plugin_redmine_clf2 = {'welcome_text_fr' => nil}
        end


        should "show nothing if there is no English welcome_text" do
          set_language_if_valid(:fr)
          Setting.welcome_text = nil

          assert_equal '', Setting.welcome_text
        end
        
        should "show the English welcome_text" do
          set_language_if_valid(:fr)

          assert_equal ENGLISH_TEXT, Setting.welcome_text
        end
      end
    end
  end
end
