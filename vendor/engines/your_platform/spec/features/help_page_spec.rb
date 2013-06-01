# -*- coding: utf-8 -*-
require 'spec_helper'
include SessionSteps


feature "Tasks" do
    background do
        login:user
        @help_page = Page.create_help_page
        @help_page.update_attributes( title: I18n.t( :help ) )
    end
    describe "get help page" do
        it "displays help page" do
            visit root_path
            click_on I18n.t( :help )
            page.should have_content(I18n.t(:attachments))
        end
    end

end
