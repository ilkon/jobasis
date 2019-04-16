# frozen_string_literal: true

# Learn more: http://github.com/javan/whenever
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

if @environment == 'production'
  every 2.hours do
    rake 'posts:fetch'
  end

  every '5 * * * *' do
    rake 'vacancies:parse_new'
  end

  every '0 3 * * *' do
    rake 'skills:update_recent'
  end
end
