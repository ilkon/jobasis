# frozen_string_literal: true

require_relative 'string_boolean'

namespace :skills do
  desc 'Import skills from txt-file to database'
  task :import => :environment do
    pathname = Rails.root.join('import', 'skills.txt')

    unless pathname.exist?
      puts 'Import file does not exist'
      next
    end

    skills = []

    File.open(pathname, 'r') do |file|
      file.each_line do |line|
        names = line.split(',').map(&:strip).reject(&:empty?)
        next if names.empty?

        skills << names
      end
    end

    if skills.empty?
      puts 'No skills to import'
      next
    end

    status = Skill.import(skills)

    puts "#{skills.count} skills processed (#{%i[created updated deleted].map { |s| "#{s}: #{status[s]}" }.join(', ')})"
  end

  desc 'Export skills from database to txt-file'
  task :export => :environment do
    skills = Skill.export

    if skills.empty?
      puts 'No skills to export'
      next
    end

    filename = Rails.root.join('import', 'skills.txt').to_s

    File.open(filename, 'w') do |file|
      skills.each do |names|
        file.write("#{names.join(', ')}\n")
      end
    end

    puts "#{skills.count} skills exported"
  end
end
