class StoreMailAsPostsAndSendGroupMailJob < ActiveJob::Base
  queue_as :mailgate
  
  # Attention! At the moment, we can't store message strings in the 
  # redis database due to encoding issues that occur during serialization.
  #
  # Therefore, we only allow synchronous performance as a temporary
  # workaround.
  #
  def self.perform_later(*args)
    raise 'Only `perform_now` is allowed at the moment.'
  end
  def self.perform(*args)
    self.perform_now(*args)
  end
  
  def perform(message)
    sleep_a_random_time
    wait_for_unlock
    lock do
      received_post_mail = ReceivedPostMail.new(message)
      @posts = received_post_mail.store_as_posts_when_authorized
      received_post_mail.deliver_rejection_emails
    end
    @posts.each { |post| post.send_as_email_to_recipients }  # TODO: post deliveries table to avoid timeout and generate delivery reports.
  end
  
  # We have to lock post mail processing in a way that does not allow
  # synchronous processing of several messages. Otherwise, we can't 
  # ensure that duplicates are filtered out.
  # 
  # Using a sidekiq queue des not work due to serialization issues.
  # Therefore, use a file system lock.
  #
  def locked?
    locked
  end
  def lock_file_name
    File.join(Rails.root, 'tmp/lock_post_mail_processing')
  end
  def locked
    File.exist?(lock_file_name)
  end
  def locked=(new_lock_state)
    if new_lock_state
      File.touch lock_file_name
    else
      File.remove lock_file_name
    end
  end
  
  # Yield the given block, but put the file lock in place, first.
  # Remove the file lock afterwards.
  #
  def lock
    locked = true
    yield
    locked = false
  end
  
  # Wait until the lock has been removed by another process.
  # 
  def wait_for_unlock
    while locked?
      sleep 0.1
    end
  end
  
  # Sleep some random time between zero and one second.
  # We do that in order to ensure that two processes do not try to lock
  # at the very same time. Due to the random delay, one process will
  # be first.
  #
  def sleep_a_random_time
    sleep 1.0 * rand(100) / 100.0 
  end
    
end