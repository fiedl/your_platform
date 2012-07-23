namespace :reconstruct_indirect_dag_links do

  desc "Reconstruct Indirect DagLinks"
  task reconstruct_indirect_dag_links: :environment do
    STDOUT.sync = true
    p "Task: Reconstruct Indirect DagLinks"


    all_links_before_wipe = DagLink.with_deleted.where( :direct => true ).all
    num_of_dag_links_before_deletion = DagLink.with_deleted.all.count

    DagLink.transaction do

      DagLink.delete_all!

      for template_link in all_links_before_wipe

        new_link = DagLink.create( ancestor_id: template_link.ancestor_id,
                                   ancestor_type: template_link.ancestor_type,
                                   descendant_id: template_link.descendant_id,
                                   descendant_type: template_link.descendant_type,
                                   direct: true )
        new_link.created_at = template_link.created_at
        new_link.deleted_at = template_link.deleted_at if template_link.deleted_at
        new_link.save

        print ".".green

      end

    end

    print "\n"
    p "#{all_links_before_wipe.count} direct links reconstructed."
    p "There are #{DagLink.with_deleted.all.count} links in total now, including deleted."
    p "Before reconstruction, there have been #{num_of_dag_links_before_deletion}."

  end

  desc "Run all tasks"
  task :all => [
                :reconstruct_indirect_dag_links,
               ]

end
