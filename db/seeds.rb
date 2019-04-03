# frozen_string_literal: true

# Import technologies
pathname = Rails.root.join('import', 'technologies.txt')

technologies = []
File.open(pathname, 'r') do |file|
  file.each_line do |line|
    names = line.split(',').map(&:strip).reject(&:empty?)
    next if names.empty?

    technologies << names
  end
end

Technology.import(technologies)
