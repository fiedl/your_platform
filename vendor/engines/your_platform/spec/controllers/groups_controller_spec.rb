require 'spec_helper'

describe GroupsController do
  context 'when not logged in' do
    describe 'GET #index' do
      it 'should return 302 not authorized' do
        get :index
        response.status.should eq(302)
      end
    end

    describe 'GET #show' do
      it 'should return 302 not authorized' do
        group = create(:group)
        get :show, id: group
        response.status.should eq(302)
      end
    end

    describe 'POST #create' do
      it 'should return 302 not authorized' do
        post :create
        response.status.should eq(302)
      end
    end

    describe 'PUT #update' do
      it 'should return 302 not authorized' do
        group = create (:group)
        put :update, id: group, group: attributes_for(:group)
        response.status.should eq(302)
      end
    end
  end

  context 'when logged in as admin' do
    login_admin

    describe 'GET #index' do
      it 'populates an array of groups' do
        group = create(:group)
        get :index
        assigns(:groups).should include(group)
      end

      it 'renders the :index view' do
        get :index
        response.should render_template :index
      end
    end

    describe 'GET #show' do
      it 'assigns the requested group to @group' do
        group = create(:group)
        get :show, id: group
        assigns(:group).should eq(group)
      end

      it 'renders the show template' do
        get :show, id: create(:group)
        response.should render_template :show
      end

      it 'assigns members of the requested group to @members' do
        group = create(:group, :with_members)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      it 'assigns hidden members to @members' do
        group = create(:group, :with_hidden_member)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      it 'assigns dead members to @members' do
        group = create(:group, :with_dead_member)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      # it 'assigns addresses of members of the requested group to @large_map_address_fields' do
      #   group = create(:group, :with_members)
      #   get :show, id: group
      #   assigns(:large_map_address_fields).should_not be_empty
      # end
      # 
      # it 'assigns addresses of hidden members to @large_map_address_fields' do
      #   group = create(:group, :with_hidden_member)
      #   get :show, id: group
      #   assigns(:large_map_address_fields).should_not be_empty
      # end
      
      describe "(list exports)" do
        let(:group) { create :group, :with_members }
        
        before do
          # Make sure it also works when users with empty birthday are present (bug fix).
          #
          @user_without_birthday = create :user
          @user_without_birthday.date_of_birth = nil
          @user_without_birthday.save
    
          group.assign_user @user_without_birthday, at: 2.seconds.ago
          group.reload
          
          # In order to create a phone list, the group needs a user with a phone number.
          #
          group.members.first.profile_fields.create label: 'phone', value: '1234-56', type: 'ProfileFieldTypes::Phone'
        end
        
        it 'generates an address label pdf' do
          get :show, id: group.id, format: 'pdf'
          response.content_type.should == 'application/pdf'
        end
      
        it 'generates excel name lists' do
          get :show, id: group.id, format: 'xls'
          response.content_type.should include 'application/xls'
        end
        
        ['name_list', 'birthday_list', 'phone_list', 'email_list', 'member_development'].each do |preset|
          it "generates an excel #{preset}" do
            get(:show, {id: group.id, list: preset, format: 'xls'})
            response.content_type.should include 'application/xls'
            response.body.should include group.members.first.last_name
          end
        end
        
        it 'generates csv name lists' do
          get :show, id: group.id, format: 'csv'
          response.content_type.to_s.should == 'text/csv'
        end
        
        ['name_list', 'birthday_list', 'phone_list', 'email_list', 'member_development'].each do |preset|
          it "generates an csv #{preset}" do
            get(:show, {id: group.id, list: preset, format: 'csv'})
            response.content_type.to_s.should == 'text/csv'
            response.body.should include group.members.first.last_name
          end
        end
      end
    end

    describe 'POST #create' do
      it 'saves the new group in the database' do
        expect{
          post :create
        }.to change(Group, :count).by(1)
      end

      it 'redirects to the new group' do
        post :create
        response.should redirect_to Group.last
      end
    end

    pending 'PUT #update' do
      before :each do
        @group = create(:group)
      end

      context 'valid attributes' do
        it 'respond with 200 success' do
          put :update, id: @group, group: attributes_for(:group)
          response.should be_success
        end

        it 'located the requested @contact' do
          put :update, id: @group, group: attributes_for(:group)
          assigns(:group).should eq(@group)
        end

        it "changes @contact's attributes" do
          put :update, id: @group, group: attributes_for(:group, name: 'newname')
          @group.reload
          @group.name.should eq('newname')
        end

        it 'redirects to the updated contact' do
          put :update, id: @group, group: attributes_for(:group)
          response.should redirect_to @group
        end
      end

      context 'invalid attributes' do
        it 'locates the requested @contact' do
          put :update, id: @group, group: attributes_for(:group, name: nil)
          assigns(:group).should eq(@group)
        end
        it "does not change @contact's attributes" do
          put :update, id: @group, group: attributes_for(:group, name: nil)
          @group.reload
          @group.name.should_not eq(nil)
        end

        it 're-renders the edit method' do
          put :update, id: @group, group: attributes_for(:group, name: nil)
          response.should render_template :edit
        end
      end
    end
  end

  context 'when logged in as regular user' do
    login_user

    describe 'GET #index' do
      it 'populates an array of groups' do
        pending 'a bug prevents @groups to be assigned for non admins'
        group = create(:group)
        get :index
        assigns(:groups).should include(group)
      end

      it 'returns 302 not authorized' do
        get :index
        response.status.should eq(302)
      end
    end

    describe 'GET #show' do
      it 'assigns the requested group to @group' do
        group = create(:group)
        get :show, id: group
        assigns(:group).should eq(group)
      end

      it 'renders the show template' do
        get :show, id: create(:group)
        response.should render_template :show
      end

      it 'assigns members of the requested group to @members' do
        group = create(:group, :with_members)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      # it 'assigns addresses of members of the requested group to @large_map_address_fields' do
      #   group = create(:group, :with_members)
      #   get :show, id: group
      #   assigns(:large_map_address_fields).should_not be_empty
      # end
      # 
      # it 'does not assign addresses of hidden members to @large_map_address_fields' do
      #   group = create(:group, :with_hidden_member)
      #   get :show, id: group
      #   assigns(:large_map_address_fields).should be_empty
      # end
    end

    describe 'POST #create' do
      it 'returns 302 not authorized' do
        post :create
        response.status.should eq(302)
      end
    end

    describe 'PUT #update' do
      it 'respond with 302 not authorized' do
        group = create(:group)
        put :update, id: group, group: attributes_for(:group)
        response.status.should eq(302)
      end
    end
  end
end