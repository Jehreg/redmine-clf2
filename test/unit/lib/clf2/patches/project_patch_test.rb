require File.dirname(__FILE__) + '/../../../../test_helper'

class Clf2::Patches::ProjectPatchTest < ActionController::TestCase
  include Redmine::I18n

  context "#english_description?" do
    should "be true if the English description is set" do
      assert Project.generate!(:description => 'English description').english_description?
    end

    should "be false if the English description is empty" do
      assert !Project.generate!(:description => '').english_description?
    end

    should "be false if the English description is nil" do
      assert !Project.generate!(:description => nil).english_description?
    end
  end

  context "#french_description?" do
    should "be true if the French description is set" do
      assert Project.generate!(:description_fr => 'French description').french_description?
    end

    should "be false if the French description is empty" do
      assert !Project.generate!(:description_fr => '').french_description?
    end

    should "be false if the French description is nil" do
      assert !Project.generate!(:description_fr => nil).french_description?
    end
  end
  
  context "#description" do
    setup do
      @project = Project.generate!(:description => 'English description', :description_fr => 'French description')
    end

    context "default" do
      should "show the English description" do
        assert_equal "English description", @project.description
      end
    end

    context "with :en as the current language" do
      should "show the English description" do
        set_language_if_valid(:en)
        assert_equal "English description", @project.description
      end

      context "with an empty English description" do
        setup do
          @project.description = nil
        end

        should "show nothing if there is no French description" do
          set_language_if_valid(:en)
          @project.description_fr = nil

          assert_equal '', @project.description
        end
        
        should "show the French description" do
          set_language_if_valid(:en)

          assert_equal 'French description', @project.description
        end
      end
      
    end

    context "with :fr as the current language" do
      should "show the French description" do
        set_language_if_valid(:fr)
        assert_equal "French description", @project.description
      end

      context "with an empty French description" do
        setup do
          @project.description_fr = nil
        end


        should "show nothing if there is no English description" do
          set_language_if_valid(:fr)
          @project.description = nil

          assert_equal '', @project.description
        end
        
        should "show the English description" do
          set_language_if_valid(:fr)

          assert_equal 'English description', @project.description
        end
      end
    end
  end


  context "#english_name?" do
    should "be true if the English name is set" do
      assert Project.generate!(:name => 'English name').english_name?
    end
  end

  context "#french_name?" do
    should "be true if the French name is set" do
      assert Project.generate!(:name_fr => 'French name').french_name?
    end

    should "be false if the French name is empty" do
      assert !Project.generate!(:name_fr => '').french_name?
    end

    should "be false if the French name is nil" do
      assert !Project.generate!(:name_fr => nil).french_name?
    end
  end
  
  context "#name" do
    setup do
      set_language_if_valid(:en)
      @project = Project.generate!(:name => 'English name', :name_fr => 'French name')
    end

    context "default" do
      should "show the English name" do
        assert_equal "English name", @project.name
      end
    end

    context "with :en as the current language" do
      should "show the English name" do
        set_language_if_valid(:en)
        assert_equal "English name", @project.name
      end

      context "with an empty English name" do
        setup do
          @project.name = nil
        end

        should "show nothing if there is no French name" do
          set_language_if_valid(:en)
          @project.name_fr = nil

          assert_equal '', @project.name
        end
        
        should "show the French name" do
          set_language_if_valid(:en)

          assert_equal 'French name', @project.name
        end
      end
      
    end

    context "with :fr as the current language" do
      should "show the French name" do
        set_language_if_valid(:fr)
        assert_equal "French name", @project.name
      end

      context "with an empty French name" do
        setup do
          @project.name_fr = nil
        end


        should "show nothing if there is no English name" do
          set_language_if_valid(:fr)
          @project.name = nil

          assert_equal '', @project.name
        end
        
        should "show the English name" do
          set_language_if_valid(:fr)

          assert_equal 'English name', @project.name
        end
      end
    end
  end

end
