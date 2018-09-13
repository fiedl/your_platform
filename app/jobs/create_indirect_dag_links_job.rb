class CreateIndirectDagLinksJob < ApplicationJob
  queue_as :dag_links

  def perform(user_id)
    User.find(user_id).create_indirect_dag_links
  end
end