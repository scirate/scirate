require 'spec_helper'

describe "Search#migrate" do
  before :each do
    Search.drop
    Search.drop "scirate_test_old"
  end

  context "no current search index" do
    before do
      expect(Search.true_index_name).to be_nil
    end

    it "creates a new index" do
      Search.migrate
      expect(Search.true_index_name).to_not be_nil
    end
  end

  context "obsolete search mapping" do
    before do
      mappings = Search.mappings.dup
      mappings[:properties][:foo] = { type: 'text' }

      Search.create_index name: "scirate_test_old", mappings: mappings
      Search.add_alias    index: "scirate_test_old", alias_name: "scirate_test"

      expect(Search.true_index_name).to eq "scirate_test_old"
    end

    it "migrates to a new index with the right mapping" do
      Search.migrate
      expect(Search.true_index_name).to_not be_nil
      expect(Search.true_index_name).to_not eq "scirate_test_old"
    end
  end

  context "obsolete search settings" do
    before do
      settings = Search.settings.dup
      settings[:index][:analysis][:tokenizer][:category_path][:delimiter] = '/'

      Search.create_index name: "scirate_test_old", settings: settings
      Search.add_alias    index: "scirate_test_old", alias_name: "scirate_test"

      expect(Search.true_index_name).to eq "scirate_test_old"
    end

    it "migrates to a new index with the right settings" do
      Search.migrate
      expect(Search.true_index_name).to_not be_nil
      expect(Search.true_index_name).to_not eq "scirate_test_old"
    end
  end

  context "search mappings and settings are current" do
    before do
      Search.drop("scirate_test_v1")
      Search.drop("scirate_test_v2")
      Search.migrate('v1')
    end

    it "does not migrate to a new index" do
      index_name = Search.true_index_name
      Search.migrate('v2')
      expect(Search.true_index_name).to eq index_name
    end
  end
end
