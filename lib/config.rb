# frozen_string_literal: true

require 'logger'
require 'syslogger'

class Config
  class << self
    def setup_logger(log_name = nil)
      self.logger =
        if log_name.present?
          # writing to syslog with given name as tag
          Syslogger.new(log_name, Syslog::LOG_PID, Syslog::LOG_LOCAL1).tap do |logger|
            logger.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
          end
        else
          # writing to stdout
          Logger.new($stdout).tap do |logger|
            logger.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
            logger.formatter = proc do |_severity, datetime, _progname, msg|
              "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} - #{msg}\n"
            end
          end
        end
    end

    attr_accessor :logger
  end
end
