# -*- coding: utf-8 -*-

# This will provide the +is_navable+ method for models.

require "navable"
ActiveRecord::Base.extend Navable
