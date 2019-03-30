# frozen_string_literal: true

require_relative 'string_boolean'

namespace :technologies do
  desc 'Import technologies from txt-file to database'
  task :import, %i[] => :environment do
    pathname = Rails.root.join('import', 'technologies.txt')

    unless pathname.exist?
      puts 'No technologies to import'
      next
    end

    technologies = Technology.all
    indexed_techs = technologies.index_by(&:id)
    named_ids = technologies.each_with_object({}) do |tech, hash|
      hash[tech.name.downcase] = tech.id
      tech.synonyms.each { |syn| hash[syn.downcase] = tech.id }
    end

    created = updated = 0

    File.open(pathname, 'r') do |file|
      all_names = []

      file.each_line do |line|
        names = line.split(',').map(&:strip).reject { |name| name.empty? || all_names.include?(name.downcase) }

        next if names.empty?

        all_names.concat(names.map(&:downcase))

        ids = names.map do |name|
          id = named_ids[name.downcase]
          id && indexed_techs[id] ? id : nil
        end

        id = ids.compact.group_by(&:itself).max_by { |x| x[1].length }.try(:first)

        name = names.shift
        synonyms = names

        if id
          indexed_techs[id].update(name: name, synonyms: synonyms)
          updated += 1
          indexed_techs.delete(id)
        else
          Technology.create(name: name, synonyms: synonyms)
          created += 1
        end
      end
    end

    deleted = indexed_techs.count
    indexed_techs.each do |_id, model|
      model.destroy
    end

    puts "Technologies processed: #{created + updated} (records created: #{created}, updated: #{updated}, deleted: #{deleted})"
  end

  desc 'Export technologies from database to txt-file'
  task :export, %i[] => :environment do
    technologies = Technology.order(name: :asc)

    if technologies.empty?
      puts 'No technologies to export'
      next
    end

    filename = Rails.root.join('import', 'technologies.txt').to_s

    File.open(filename, 'w') do |file|
      technologies.each do |tech|
        file.write("#{([tech.name] + tech.synonyms).join(', ')}\n")
      end
    end

    puts "#{technologies.count} technologies exported"
  end
end
