# frozen_string_literal: true

# Import skills
pathname = Rails.root.join('import/skills.txt')

skills = []
File.open(pathname, 'r') do |file|
  file.each_line do |line|
    names = line.split(',').map(&:strip).reject(&:empty?)
    next if names.empty?

    skills << names
  end
end

Skill.import(skills)
