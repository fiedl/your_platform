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
        group = create(:group, :with_users)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      it 'assigns hidden members to @members' do
        group = create(:group, :with_hidden_user)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      it 'assigns dead members to @members' do
        group = create(:group, :with_dead_user)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      it 'assigns addresses of members of the requested group to @map_address_fields' do
        group = create(:group, :with_users)
        get :show, id: group
        assigns(:map_address_fields).should_not be_empty
      end

      it 'assigns addresses of hidden members to @map_address_fields' do
        group = create(:group, :with_hidden_user)
        get :show, id: group
        assigns(:map_address_fields).should_not be_empty
      end

      it 'assigns addresses of dead members to @map_address_fields' do
        group = create(:group, :with_dead_user)
        get :show, id: group
        assigns(:map_address_fields).should_not be_empty
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
        group = create(:group, :with_users)
        get :show, id: group
        assigns(:members).should_not be_empty
      end

      it 'assigns addresses of members of the requested group to @map_address_fields' do
        group = create(:group, :with_users)
        get :show, id: group
        assigns(:map_address_fields).should_not be_empty
      end

      it 'does not assign addresses of hidden members to @map_address_fields' do
        group = create(:group, :with_hidden_user)
        get :show, id: group
        assigns(:map_address_fields).should be_empty
      end

      it 'does not assign addresses of dead members to @map_address_fields' do
        group = create(:group, :with_dead_user)
        get :show, id: group
        assigns(:map_address_fields).should be_empty
      end
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