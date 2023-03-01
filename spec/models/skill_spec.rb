# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Skill do
  it 'has a valid factory' do
    obj = build(:skill)
    expect(obj).to be_valid
  end

  it 'can be stored' do
    obj = create(:skill)
    expect(obj.reload).to be_present
  end

  it 'is invalid without a name' do
    obj = build(:skill, name: nil)
    expect(obj).not_to be_valid
  end

  it 'is invalid with an empty name' do
    obj = build(:skill, name: '')
    expect(obj).not_to be_valid
  end

  it 'is invalid with duplicate name' do
    obj2 = create(:skill)
    obj  = build(:skill, name: obj2.name)
    expect(obj).not_to be_valid
  end

  it 'strips name before saving' do
    name = ' PHP   '
    obj = create(:skill, name:)
    expect(obj.name).to eql(name.strip)
  end

  describe '.export' do
    before :all do
      @skill_names = [
        %w[PHP PHP4 PHP7],
        %w[Kubernetes k8s],
        %w[AWS],
        %w[Rails ror]
      ]

      @skills = []
      @skill_names.each do |names|
        @skills << create(:skill, name: names[0], synonyms: names[1..])
      end
    end

    after :all do
      @skills.each(&:destroy)
    end

    it 'returns all skills' do
      res = described_class.export
      expect(res).to match_array(@skill_names)
    end

    it 'returns skills sorted by name' do
      sorted_names = @skill_names.sort_by(&:first)
      res = described_class.export
      res.each_with_index do |res_item, i|
        expect(res_item).to match_array(sorted_names[i])
      end
    end
  end

  describe '.import' do
    before do
      @skill_names = [
        %w[PHP PHP4 PHP7],
        %w[Kubernetes k8s],
        %w[AWS],
        %w[Rails RoR]
      ]

      @skills = []
      @skill_names.each do |names|
        @skills << create(:skill, name: names[0], synonyms: names[1..])
      end
    end

    after do
      @skills.each(&:destroy)
    end

    it 'returns status' do
      res = described_class.import(@skill_names)

      expect(res).to be_a(Hash)
      expect(res[:deleted]).to eq(0)
      expect(res[:created]).to eq(0)
      expect(res[:updated]).to eq(@skill_names.count)
    end

    it 'imports same skills without recreating models' do
      described_class.import(@skill_names)

      @skill_names.each_with_index do |names, i|
        model = described_class.find_by(name: names.first)
        expect(model).to be_truthy
        expect(model.id).to eql(@skills[i].id)
        expect(model.synonyms).to match_array(@skills[i].synonyms)
      end
    end

    it 'deletes models for skills missing in input' do
      skill_names = [%w[Rails RoR]]
      missing_skills = (@skill_names - skill_names)

      res = described_class.import(skill_names)

      expect(res[:deleted]).to eq(missing_skills.count)

      missing_skills.each do |names|
        model = described_class.find_by(name: names.first)
        expect(model).to be_nil
      end
    end

    it 'adds models for extra skills available in input' do
      extra_skills = [%w[Ruby], %w[Java J2EE J2SE]]
      all_skills = (@skill_names + extra_skills)

      res = described_class.import(all_skills)

      expect(res[:created]).to eq(extra_skills.count)

      extra_skills.each do |names|
        model = described_class.find_by(name: names.first)
        expect(model).to be_truthy
      end
    end

    it 'updates models in case of swapping name and synonym' do
      skill_names = {
        'PHP'        => %w[PHP7 PHP PHP4],
        'Kubernetes' => %w[k8s Kubernetes k28s]
      }
      orig_skills = skill_names.keys.map { |orig_name| described_class.find_by(name: orig_name) }

      described_class.import(skill_names.values)

      skill_names.values.each_with_index do |names, i|
        model = described_class.find_by(name: names.first)
        expect(model).to be_truthy
        expect(model.id).to eql(orig_skills[i].id)
      end
    end
  end
end
