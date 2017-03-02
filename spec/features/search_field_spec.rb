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
        within('.navbar-search') { fill_in 'query', with: "foo" }

        press_enter in: 'query'
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
        within('.navbar-search') { fill_in 'query', with: "foo" }
        press_enter in: 'query'
      end
      specify "searching for foo should list both users" do
        page.should have_content( I18n.t( :found_users ) )
        page.should have_content( "#{@user1.last_name}, #{@user1.first_name}" )
        page.should have_content( "#{@user1.last_name}, #{@user1.first_name}" )
      end
    end
    context "if there are more users matching" do
      before do
        @user1 = create( :user, last_name: "foo" )
        @user2 = create( :user, last_name: "blarzfoo" )
        @user3 = create( :user, last_name: "cannonfoo" )
        @user3.profile_fields.create( label: "Home Address", value: "Pariser Platz 1\n 10117 Berlin", type: "ProfileFieldTypes::Address" )
        @user3.profile_fields.create( label: "General Info", value: "Foo Bar", type: "ProfileFieldTypes::General")

        within('.navbar-search') { fill_in 'query', with: "foo" }
        press_enter in: 'query'
      end
      specify "searching for foo should list each user only once" do
        page.should have_content( I18n.t( :found_users ) )
        page.should have_content( @user1.last_name )
        page.should have_content( @user2.last_name )
        page.should have_content( @user3.last_name )
        u1 = find('div.users_found').all(:css, 'a', :text => @user1.last_name)
        u2 = find('div.users_found').all(:css, 'a', :text => @user2.last_name)
        u3 = find('div.users_found').all(:css, 'a', :text => @user3.last_name)
        u1.size.should == 1
        u2.size.should == 1
        u3.size.should == 1
      end
    end

    describe "by profile field" do
      before do
        @user1 = create :user
        @user1.profile_fields.create(type: 'ProfileFieldTypes::Address', value: 'Pariser Platz 1\n 10117 Berlin')
      end
      specify "searching for a string in a profile field should result in the corresponding user" do
        within('.navbar-search') { fill_in 'query', with: "Berlin" }
        press_enter in: 'query'

        page.should have_text @user1.title
      end
    end
  end

  describe "finding pages" do
    before do
      @page = create(:page, title: "foo", content: "some page content")
    end
    specify "searching for page titles should list the pages" do
      within('.navbar-search') { fill_in 'query', with: "foo" }
      press_enter in: 'query'
      page.should have_content @page.title
    end
    specify "searching for page contents (bodies) should list the pages" do
      within('.navbar-search') { fill_in 'query', with: "some page content" }
      press_enter in: 'query'
      page.should have_content @page.title
    end
  end

  describe "finding attachments" do
    before do
      @page = create(:page, title: "foo page")
      @attachment = @page.attachments.create(title: "bar attachment", description: "some attachment description")
    end
    specify "searching for attachment titles should list their parent pages" do
      within('.navbar-search') { fill_in 'query', with: 'bar attachment' }
      press_enter in: 'query'
      page.should have_content @page.title
    end
    specify "searching for attachment descriptions should list their parent pages" do
      within('.navbar-search') { fill_in 'query', with: 'some attachment description' }
      press_enter in: 'query'
      page.should have_content @page.title
    end
  end

  describe "finding groups" do
    before do
      @group = create( :group, name: "foo" )
      within('.navbar-search') { fill_in 'query', with: "foo" }
      press_enter in: 'query'
    end
    subject { page }
    it { should have_content( @group.title ) }
  end

  describe "a space should be interpreted as a wild card" do
    before do
      @page = create( :page, title: "foo some bar page" )
      within('.navbar-search') { fill_in 'query', with: "foo bar" }
      press_enter in: 'query'
    end
    subject { page }
    it { should have_content( @page.title ) }
  end

end


