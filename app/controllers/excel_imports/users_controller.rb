class ExcelImports::UsersController < ExcelImportsController

  expose :group

  def new
    authorize! :import_users, group

    set_current_title t :import_users
    set_current_navable group
  end


end