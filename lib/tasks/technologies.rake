# frozen_string_literal: true

require_relative 'string_boolean'

namespace :technologies do
  desc 'Import technologies from txt-file to database'
  task :import => :environment do
    pathname = Rails.root.join('import', 'technologies.txt')

    unless pathname.exist?
      puts 'Import file does not exist'
      next
    end

    technologies = []

    File.open(pathname, 'r') do |file|
      file.each_line do |line|
        names = line.split(',').map(&:strip).reject(&:empty?)
        next if names.empty?

        technologies << names
      end
    end

    if technologies.empty?
      puts 'No technologies to import'
      next
    end

    status = Technology.import(technologies)

    puts "#{technologies.count} technologies processed (#{%i[created updated deleted].map { |s| "#{s}: #{status[s]}" }.join(', ')})"
  end

  desc 'Export technologies from database to txt-file'
  task :export => :environment do
    technologies = Technology.export

    if technologies.empty?
      puts 'No technologies to export'
      next
    end

    filename = Rails.root.join('import', 'technologies.txt').to_s

    File.open(filename, 'w') do |file|
      technologies.each do |names|
        file.write("#{names.join(', ')}\n")
      end
    end

    puts "#{technologies.count} technologies exported"
  end
end
