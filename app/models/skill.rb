# frozen_string_literal: true

class Skill < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { in: 1..250 }

  strip_attributes :name

  serialize :synonyms, ObjectToJsonbSerializer

  class << self
    def export
      order(name: :asc).map { |skill| [skill.name] + skill.synonyms }
    end

    def import(skills)
      status = { created: 0, updated: 0, deleted: 0 }

      indexed_skills = all.index_by(&:id)
      named_ids = indexed_skills.values.each_with_object({}) do |skill, hash|
        hash[skill.name.downcase] = skill.id
        skill.synonyms.each { |syn| hash[syn.downcase] = skill.id }
      end

      processed_names = []

      skills.each do |names|
        names.reject! { |name| processed_names.include?(name.downcase) }
        next if names.empty?

        processed_names.concat(names.map(&:downcase))

        ids = names.map do |name|
          id = named_ids[name.downcase]
          id && indexed_skills[id] ? id : nil
        end

        major_id = ids.compact.group_by(&:itself).max_by { |x| x[1].length }.try(:first)

        name = names[0]
        synonyms = names[1..-1]

        if major_id
          indexed_skills[major_id].update(name: name, synonyms: synonyms)
          status[:updated] += 1
          indexed_skills.delete(major_id)
        else
          create(name: name, synonyms: synonyms)
          status[:created] += 1
        end
      end

      status[:deleted] = indexed_skills.count
      indexed_skills.each do |_id, model|
        model.destroy
      end

      status
    end
  end
end
