# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'User page', js: false do
  include SessionSteps
  include ProfileSteps

  subject { page }

  describe 'of a user with account' do

    background do
      User.destroy_all
      @user = create(:user_with_account, :with_corporate_vita, :with_address)
      @other_user = create(:user_with_account, :with_profile_fields, :with_corporate_vita, :with_address, :with_bank_account)
    end


    describe 'when not signed in' do
      background do
        visit user_path(@user)
      end

      it { should have_content I18n.t(:unauthorized_please_sign_in) }
    end


    describe 'when signed in as admin' do

      background do
        login(:admin)
        visit user_path(@user)
      end

      it { should have_selector('h1', text: I18n.t(:contact_information)) }
      it { should have_selector('h1', text: I18n.t(:about_myself)) }
      it { should have_selector('h1', text: I18n.t(:study_information)) }
      it { should have_selector('h1', text: I18n.t(:career_information)) }
      it { should have_selector('h1', text: I18n.t(:organizations)) }
      it { should have_selector('h1', text: I18n.t(:bank_account_information)) }
      it { should have_no_selector('h1', text: I18n.t(:description)) }
      it { should have_selector('h1', text: I18n.t(:corporate_vita)) }
      pending { should have_selector('h1', text: I18n.t(:relationships)) }
      it { should have_selector('h1', text: I18n.t(:communication)) }
      it { should have_selector('h1', text: I18n.t(:access_information)) }
      it { should have_selector('.workflow_triggers')}

      #it { should have_selector('title', text: 'Wingolfsplattform') } #can't get it to work on capybara 2.0

      scenario "the section #{I18n.t(:contact_information)} should be editable", js: true do
        within('.box.section.contact_information') do
          page.should have_selector('.wingolfspost', :visible => true)
          page.should have_no_selector('.radio', :visible => true )

          click_on I18n.t(:edit)

          page.should have_selector('.wingolfspost', :visible => true)
          page.should have_selector('.radio', :visible => true)

          page.should have_selector('a.add_button', visible: true)
        end
      end

      scenario "the section #{I18n.t(:organizations)} should be editable", js: true do
        within('.box.section.organizations') do
          click_on I18n.t(:edit)
          page.should have_selector('a.add_button', visible: true)

          click_on I18n.t(:add)
          wait_for_ajax

          page.should have_selector('.profile_field')
          within first '.profile_field' do
            #
            # Fields: Organization, From, To, Role  -> 4 fields
            # Sub labels not editable.
            #
            page.should have_selector('input[type=text]', count: 4)
          end

          find('.remove_button').click
          page.should have_no_selector('li')
        end
      end
      
      scenario "editing the 'study information' box", js: true do
        within '.box.section.study_information' do
          
          # Adding a study profile field.
          #
          click_on I18n.t :edit
          click_on I18n.t :add
          fill_in 'label', with: 'Undergraduate Studies'
          within('.profile_field.from')       { fill_in 'value', with: "2006" }
          within('.profile_field.to')         { fill_in 'value', with: "2008" }
          within('.profile_field.university') { fill_in 'value', with: "FAU Erlangen" }
          within('.profile_field.subject')    { fill_in 'value', with: "Physics" }
          find('.save_button').click

          wait_for_ajax
          @user.profile_fields.where(type: 'ProfileFieldTypes::Study').count.should == 1
          study_field = @user.profile_fields.where(type: 'ProfileFieldTypes::Study').first.becomes(ProfileFieldTypes::Study)
          study_field.label.should == "Undergraduate Studies"
          study_field.from.should == "2006"
          study_field.to.should == "2008"
          study_field.university.should == "FAU Erlangen"
          study_field.subject.should == "Physics"
          study_field.specialization.should_not be_present
          
          # Changing the study field.
          #
          within '.profile_field.subject' do
            find('.best_in_place').click  # Physics
            fill_in 'value', with: "Theoretical and Experimental Physics\n"
          
            wait_for_ajax
            study_field.reload.subject.should == "Theoretical and Experimental Physics"
          end
          
          # Removing the study field.
          #
          click_on I18n.t :edit
          find('.remove_button').click
          find('.save_button').click
          
          wait_for_ajax
          @user.profile_fields.where(type: 'ProfileFieldTypes::Study').count.should == 0
        end
      end

      scenario "the section #{I18n.t(:career_information)} should be editable", js: true do
        within '.box.section.career_information' do
          click_on I18n.t(:edit)
          subject.should have_selector('a.add_button', visible: true)

          click_on I18n.t(:add)
          field_name = ProfileFieldTypes::Employment.name.demodulize.underscore
          subject.should have_selector("a#add_#{field_name}_field")
          field_name2 = ProfileFieldTypes::ProfessionalCategory.name.demodulize.underscore
          subject.should have_selector("a#add_#{field_name2}_field")

          click_on I18n.t(field_name)
          wait_for_ajax; wait_for_ajax
          wait_for_ajax; wait_for_ajax
          subject.should have_selector('.profile_field')
          within first '.profile_field' do
            #
            # Fields: Label, From, To, Organization, Position, Tasks -> 6 fields
            # Sub labels not editable.
            #
            subject.should have_selector('input[type=text]', count: 6)
          end

          find('.remove_button').click
          page.should have_no_selector('.profile_field')
        end
      end

      scenario "the section #{I18n.t(:access_information)}", js: true do
        within('.box.section.access') do

          click_on I18n.t(:edit)
          page.should have_button(I18n.t(:delete_account) )

          expect { click_on I18n.t(:delete_account) }.to change(UserAccount, :count).by -1
        end
      end

      scenario "the section #{I18n.t(:communication)} should be editable", js: true do
        within('.box.section.communication') do
          click_on I18n.t(:edit)
          page.should have_selector('select', :visible => true)
        end
      end

    end


    describe 'when signed in as a regular user' do
      describe 'and visiting another profile' do

        background do
          login(@user)
          visit user_path(@other_user)
        end

        scenario 'the profile sections should not be editable', js: true do
          within('.box.section.contact_information') do
            page.should have_selector('.wingolfspost', :visible => true)
            page.should have_no_selector('.radio', :visible => true)
            subject.should have_no_selector('a.edit_button', visible: true)
            subject.should have_no_selector('a.add_button', visible: true)
            subject.should have_no_selector('.remove_button', visible: true)
          end

          within '.box.section.career_information' do
            subject.should have_no_selector('a.edit_button', visible: true)
            subject.should have_no_selector('a.add_button', visible: true)
            subject.should have_no_selector('.remove_button', visible: true)
          end
        end

        scenario "the section #{I18n.t(:communication)} should not be editable", js: true do
          subject.should have_no_selector('a.edit_button', visible: true)
        end

        scenario 'the empty sections should not be visible' do
          subject.should have_no_selector('.box.section.organizations')
        end

        scenario 'the bank account section should not be visible' do
          subject.should have_no_selector('h1', text: I18n.t(:bank_account_information))

        end
      end

      describe 'and visiting the own profile' do
        
        background do
          login(@user)
          visit user_path(@user)
        end

        scenario 'the profile sections should be editable', js: true do
          section_should_be_editable(:contact_information, [ProfileFieldTypes::Address, ProfileFieldTypes::Email, ProfileFieldTypes::Phone, ProfileFieldTypes::Homepage, ProfileFieldTypes::Custom])
          section_should_be_editable(:about_myself)
          section_should_be_editable(:study_information)
          section_should_be_editable(:career_information, [ProfileFieldTypes::Employment, ProfileFieldTypes::ProfessionalCategory])
          section_should_be_editable(:organizations)
          section_should_be_editable(:bank_account_information)
        end


        it { should have_selector('h1', text: I18n.t(:contact_information)) }
        it { should have_selector('h1', text: I18n.t(:about_myself)) }
        it { should have_selector('h1', text: I18n.t(:study_information)) }
        it { should have_selector('h1', text: I18n.t(:career_information)) }
        it { should have_selector('h1', text: I18n.t(:organizations)) }
        it { should have_selector('h1', text: I18n.t(:bank_account_information)) }
        it { should have_no_selector('h1', text: I18n.t(:description)) }
        it { should have_selector('h1', text: I18n.t(:corporate_vita)) }
        pending { should have_selector('h1', text: I18n.t(:relationships)) }
        it { should have_selector('h1', text: I18n.t(:communication)) }
        it { should have_selector('h1', text: I18n.t(:access_information)) }
        it { should have_no_selector('.workflow_triggers')}

        scenario 'the empty sections should be visible' do
          subject.should have_selector('.box.section.organizations')
        end

        scenario "the section #{I18n.t(:contact_information)} should be editable", js: true do
          within('.box.section.contact_information') do
            page.should have_selector('.wingolfspost', :visible => true)
            page.should have_no_selector('.radio', :visible => true)

            click_on I18n.t(:edit)

            page.should have_selector('.wingolfspost', :visible => true)

            page.should have_selector('.radio', :visible => true)

            page.should have_selector('a.add_button', visible: true)
          end
        end
        scenario "the section #{I18n.t(:communication)} should be editable", js: true do
          within('.box.section.communication') do
            click_on I18n.t(:edit)
            page.should have_selector('select', :visible => true)
          end
        end

        scenario "the section #{I18n.t(:study_information)} should be editable", js: true do
          within('.box.section.study_information') do
            click_on I18n.t(:edit)
            page.should have_selector('a.add_button', visible: true)
            click_on I18n.t(:add)

            page.should have_selector('a.save_button', visible: true)
            page.should have_selector('.profile_field')
            within first '.profile_field' do
              #
              # Fields: Label, From, To, Uni, Fach, Spezialisierung -> 6 fields
              #
              page.should have_selector('input[type=text]', count: 6)
            end
            fill_in "label", with: "StudiumUniversale"
            click_on I18n.t(:save)
            wait_for_ajax; wait_for_ajax
            page.should have_content("StudiumUniversale")

            visit user_path(@user)
            page.should have_content("StudiumUniversale")
          end
        end
        
        scenario "Looking at the section 'access' and requesting a new password", js: true do
          within('.box.section.access') do
            page.should have_text @user.alias
            page.should have_text @user.name
            page.should have_text @user.email
            
            click_on I18n.t(:edit)
            page.should have_selector "input[type=text]", count: 3  # alias, first_name, email
            page.should have_text "Zugang zur Plattform"
            page.should have_text "Der Zugang zur Plattform (Benutzerkonto) wurde erstellt am"
            page.should have_text "Zuletzt wurde am"
            page.should have_text "ein neues Passwort per E-Mail übersandt."

            page.should have_link I18n.t(:change_password)
            page.should have_no_selector '.lock_account'
          end
        end
      end
    end
  end

  describe 'of a user without account' do
    describe 'when signed in as admin' do

      background do
        @user_wo_account = create(:user)
        login(:admin)
        visit user_path(@user_wo_account)
      end

      scenario 'the section for account information', js: true do
        within('.box.section.access') do
          page.should have_content(I18n.t :user_has_no_account)

          click_on I18n.t(:edit)
          page.should have_link(I18n.t(:create_account) )

          expect { click_on I18n.t(:create_account) }.to change(UserAccount, :count).by 1
          @user_wo_account.account should_not be_nil
        end
      end

    end
  end
end
