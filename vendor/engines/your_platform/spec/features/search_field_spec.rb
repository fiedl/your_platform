# -*- coding: utf-8 -*-
require 'spec_helper'

feature "Search Field", js: true do
  include SessionSteps

  before do
    user = create( :user_with_account )
    login user

    visit root_path
  end

  describe "finding users" do
    context "if there is only one matching user" do
      before do
        @user1 = create( :user, last_name: "foo" )
        fill_in 'query', with: "foo\n" # \n hits enter
      end
      specify "searching for foo should redirect to the user page" do
        page.should have_content( @user1.title )
        page.should have_content( I18n.t( :name ) )
        page.should have_content( I18n.t( :contact_information ) )
      end
    end
    context "if there are more users matching" do
      before do
        @user1 = create( :user, last_name: "foo" )
        @user2 = create( :user, last_name: "foobar" )
        fill_in 'query', with: "foo\n" # \n hits enter
      end
      specify "searching for foo should list both users" do
        page.should have_content( I18n.t( :found_users ) )
        page.should have_content( @user1.title )
        page.should have_content( @user2.title )
      end
    end
  end

  describe "finding pages" do
    before do
      @page = create( :page, title: "foo" )
      fill_in 'query', with: "foo\n"
    end
    subject { page }
    it { should have_content( @page.title ) }
  end

  describe "finding groups" do
    before do
      @group = create( :group, name: "foo" )
      fill_in 'query', with: "foo\n"
    end
    subject { page }
    it { should have_content( @group.title ) }
  end

  describe "a space should be interpreted as a wild card" do
    before do
      @page = create( :page, title: "foo some bar page" )
      fill_in 'query', with: "foo bar\n"
    end
    subject { page }
    it { should have_content( @page.title ) }
  end

  def hit_enter_in(selector)
    page.execute_script("var input = $(\"#{selector}\"); input.trigger('keypress', [13]);")
  end

end


