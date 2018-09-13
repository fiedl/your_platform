class RecreateIndirectDagLinksJob < ApplicationJob
  queue_as :dag_links

  def perform(user_id)
    User.find(user_id).recreate_indirect_dag_links
  end
end