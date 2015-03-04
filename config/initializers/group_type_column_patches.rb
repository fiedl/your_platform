#
# We've introduced the type column to the Group model.
# But, in the database, there might still be old records, where STI was used
# without type column.
#
# These records need to be updates. Otherwise the records can't be found anymore.
#
Group.corporations_parent.child_groups.update_all("type = 'Corporation'")