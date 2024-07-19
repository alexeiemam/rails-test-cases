# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", '~> 7.1'
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3", '~> 1.4'
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :versions, force: true do |t|
    t.string :name
    t.string :descriptor
  end

  create_table :organisations, primary_key: [:version_id, :local_id], force: true do |t|
    t.bigint :version_id
    t.bigint :local_id
    t.string :name
  end

  create_table :fathers, primary_key: [:version_id, :organisation_id, :local_id], force: true do |t|
    t.bigint :version_id
    t.bigint :organisation_id
    t.bigint :local_id
    t.string :name
  end

  create_table :mothers, primary_key: [:version_id, :organisation_id, :local_id], force: true do |t|
    t.bigint :version_id
    t.bigint :organisation_id
    t.bigint :local_id 
    t.string :name
  end

  create_table :kids, primary_key: [:version_id, :organisation_id, :local_id], force: true do |t|
    t.bigint :version_id
    t.bigint :organisation_id
    t.bigint :local_id
    t.string :name
    t.integer :medals
    t.bigint :father_id 
    t.bigint :mother_id 
  end
end

class Version < ActiveRecord::Base
  has_many :organisations 
end 

class Organisation < ActiveRecord::Base 
  self.primary_key = [:version_id, :local_id]

  belongs_to :version 
end 

class Mother < ActiveRecord::Base
  self.primary_key = [:version_id, :organisation_id, :local_id]

  belongs_to :version 

  belongs_to :organisation,  
  query_constraints: [:version_id, :organisation_id]

  has_many :kids, 
    query_constraints: [:version_id, :organisation_id, :mother_id]

  has_many :entanglements, through: :kids, source: :father
end

class Father < ActiveRecord::Base
  self.primary_key = [:version_id, :organisation_id, :local_id]

  belongs_to :version 

  belongs_to :organisation,  
  query_constraints: [:version_id, :organisation_id]

  has_many :kids, 
    query_constraints: [:version_id, :organisation_id, :father_id]

  has_many :entanglements, through: :kids, source: :mother
end

class Kid < ActiveRecord::Base
  self.primary_key = [:version_id, :organisation_id, :local_id]

  belongs_to :version 

  belongs_to :organisation,  
  query_constraints: [:version_id, :organisation_id]

  belongs_to :mother, 
    query_constraints: [:version_id, :organisation_id, :mother_id]

  belongs_to :father, 
    query_constraints: [:version_id, :organisation_id, :father_id]
end

class BugTest < Minitest::Test
  def test_associations
    version = Version.create!(name: 'K-Swiss', descriptor: 'Rcudgel Xmin for the foreseeable')
    organisation = Organisation.create!(name: 'Effaclar', local_id: 9234, version: version)

    base_version_organisation_details = {
      version: version, 
      organisation: organisation
    }
    mother = 
      Mother.create!(base_version_organisation_details.merge(
        local_id: 98,
        name: 'Mariana'
      )) 

    father = 
      Father.create!(base_version_organisation_details.merge(
        local_id: 117,
        name: 'Carlito'
      )) 

    father_2 = Father.create!(base_version_organisation_details.merge(
      local_id: 1982,
      name: 'Abdel-aziz'
    ))

    ### Can pass mother/father objects and let Rails figure it out
    kid_1 = Kid.create!(base_version_organisation_details.merge(
      local_id: 1,
      name: 'Jim',
      mother: mother,
      father: father,
      medals: 5
    ))

    ### Can pass specific mother/father Local IDs
    kid_2 = Kid.create!(base_version_organisation_details.merge(
      local_id: 2,
      name: 'Jesse',
      mother_id: mother.local_id,
      father_id: father.local_id,
      medals: 9
    ))

    kid_3 = Kid.create!(base_version_organisation_details.merge(
      local_id: 29,
      name: 'Sinbad',
      mother: mother,
      father: father_2,
      medals: 11
    ))
    
    puts "assert_equal 1, Father.count" 
    assert_equal 2, Father.count 
    puts "assert_equal 1, Mother.count"
    assert_equal 1, Mother.count
    puts "assert_equal 2, Kid.count"  
    assert_equal 3, Kid.count  
    puts "assert_equal 2, father.kids.count"
    assert_equal 2, father.kids.count
    puts "assert_equal 2, mother.kids.count"
    assert_equal 3, mother.kids.count
    puts "assert_equal father.kids.to_a, mother.kids.to_a " 
    assert_equal kid_1.father, father
    puts "assert_equal 25, mother.kids.sum(:medals)"
    assert_equal 25, mother.kids.sum(:medals)
    puts "assert_equal kid_1.father.entanglements.count, kid_2.father.entanglements.count"
    assert_equal kid_1.father.entanglements.count, kid_2.father.entanglements.count
    puts "assert_equal kid_2.mother.entanglements.count, kid_1.mother.entanglements.count"
    assert_equal kid_2.mother.entanglements.count, kid_1.mother.entanglements.count
    puts "assert_equal 3, kid_3.mother.entanglements.count"
    assert_equal 3, kid_3.mother.entanglements.count
    puts "assert_equal 1, kid_3.father.entanglements.count"
    assert_equal 1, kid_3.father.entanglements.count
    puts "assert_equal 2, kid_2.father.entanglements.count"
    assert_equal 2, kid_2.father.entanglements.count
  end
end