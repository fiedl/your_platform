# The best_in_place gem, which we use for in-place editing, allows formatters ("display methods")
# that are applied to the values of in-place editing field. For example, we use a markdown formatter
# for certain textareas.
#
# Unfortunately, the formatter definitions are stored in a class variable by the gem, which is not
# shared between the unicorn worker instances of the application. Therefore, it is not ensured
# that all display methods required are loaded by the worker that responds to the ajax request
# of `respond_with_bip` in the controller.
#
# This initializer circumvents this problem by defining all needed definitions by hand in order to
# ensure that all worker instances have the same definitions.
#
# See also this issue on github:
# https://github.com/bernat/best_in_place/issues/321
#
# The following `BestInPlace::DisplayMethods` are defined here:
# https://github.com/bernat/best_in_place/blob/master/lib/best_in_place/display_methods.rb
#

# This calls the instance method on the model: ProfileField#display_html
#
BestInPlace::DisplayMethods.add_model_method(ProfileField, :value, :display_html)

# In order to use the helpers, make them available to ActionView::Base.
ActionView::Base.send :include, TagHelper

# This calls a helper method `markup(str)`.
#
BestInPlace::DisplayMethods.add_helper_method(Page, :content, :markup)
BestInPlace::DisplayMethods.add_helper_method(Group, :body, :markup)
BestInPlace::DisplayMethods.add_helper_method(Group, :welcome_message, :markup)
BestInPlace::DisplayMethods.add_helper_method(Event, :description, :markup)
BestInPlace::DisplayMethods.add_helper_method(ActsAsTaggableOn::Tag, :body, :markup)

BestInPlace::DisplayMethods.add_helper_method(Group, :direct_members_titles_string, :add_quick_links_to_comma_separated_list)
BestInPlace::DisplayMethods.add_helper_method(User, :corporation_name, :add_quick_link)
BestInPlace::DisplayMethods.add_helper_method(Page, :tag_list, :insert_links_into_tag_list)
BestInPlace::DisplayMethods.add_helper_method(BlogPost, :tag_list, :insert_links_into_tag_list)

BestInPlace::DisplayMethods.add_helper_method(ActsAsTaggableOn::Tag, :permalinks_list, :simple_format)
BestInPlace::DisplayMethods.add_helper_method(Page, :permalinks_list, :simple_format)
BestInPlace::DisplayMethods.add_helper_method(Blog, :permalinks_list, :simple_format)
BestInPlace::DisplayMethods.add_helper_method(BlogPost, :permalinks_list, :simple_format)

