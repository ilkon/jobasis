# frozen_string_literal: true

require 'resque/pool/tasks'

namespace :resque do
  # this task will get called before resque:pool:setup
  # and preload the rails environment in the pool manager
  task setup: :environment do
    # generic worker setup, e.g. Hoptoad for failed jobs
  end

  task 'pool:setup' do
    # close any sockets or files in pool manager
    ActiveRecord::Base.connection.disconnect!
    # and re-open them in the resque worker parent
    Resque::Pool.after_prefork do |_job|
      ActiveRecord::Base.establish_connection
    end
  end
end
