# frozen_string_literal: true

class Technology < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { in: 1..250 }

  strip_attributes :name

  serialize :synonyms, ObjectToJsonbSerializer

  class << self
    def import(technologies)
      status = { created: 0, updated: 0, deleted: 0 }

      indexed_techs = all.index_by(&:id)
      named_ids = indexed_techs.values.each_with_object({}) do |tech, hash|
        hash[tech.name.downcase] = tech.id
        tech.synonyms.each { |syn| hash[syn.downcase] = tech.id }
      end

      processed_names = []

      technologies.each do |names|
        names.reject! { |name| processed_names.include?(name.downcase) }
        next if names.empty?

        processed_names.concat(names.map(&:downcase))

        ids = names.map do |name|
          id = named_ids[name.downcase]
          id && indexed_techs[id] ? id : nil
        end

        major_id = ids.compact.group_by(&:itself).max_by { |x| x[1].length }.try(:first)

        name = names.shift
        synonyms = names

        if major_id
          indexed_techs[major_id].update(name: name, synonyms: synonyms)
          status[:updated] += 1
          indexed_techs.delete(major_id)
        else
          create(name: name, synonyms: synonyms)
          status[:created] += 1
        end
      end

      status[:deleted] = indexed_techs.count
      indexed_techs.each do |_id, model|
        model.destroy
      end

      status
    end

    def export
      order(name: :asc).map { |tech| [tech.name] + tech.synonyms }
    end
  end
end
