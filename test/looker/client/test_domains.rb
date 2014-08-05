require_relative '../../helper'

describe Looker::Client::Domains do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_domains", :vcr do
    it "returns all Looker domains" do
      domains = Looker.all_domains
      domains.must_be_kind_of Array

      domains.each do |domain|
        domain.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".domain", :vcr do
    it "retrives single domain" do
      domain = Looker.create_domain(:name => "test_domain", :models => "all")

      fetched_domain = Looker.domain(domain.id)

      fetched_domain.name.must_equal domain.name
      domain.models.each do |m|
        fetched_domain.models.must_include m
      end
      fetched_domain.all_access.must_equal domain.all_access

      # clean up domain
      Looker.delete_domain(domain.id).must_equal true
    end
  end


  describe ".create_domain", :vcr do
    it "creates domain with models list" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      domain = Looker.create_domain(:name => "test_domain", :models => models)

      domain.name.must_equal "test_domain"
      domain.all_access.must_equal false
      models.each do |m|
        domain.models.must_include m
      end
      # clean up domain
      Looker.delete_domain(domain.id).must_equal true
    end

    it "creates domain with all models" do
      models = "all"
      domain = Looker.create_domain(:name => "test_domain", :models => models)

      domain.name.must_equal "test_domain"
      domain.all_access.must_equal true
      # clean up domain
      Looker.delete_domain(domain.id).must_equal true
    end

    it "rejects duplicate name" do
      models = "all"
      domain = Looker.create_domain(:name => "test_domain", :models => models)
      domain.name.must_equal "test_domain"
      assert_raises Looker::UnprocessableEntity do
        Looker.create_domain(:name => domain.name, :models => models)
      end
      # clean up domain
      Looker.delete_domain(domain.id).must_equal true
    end
  end

  describe ".update_domain", :vcr do
    it "updates name" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      domain = Looker.create_domain(:name => "test_domain", :models => models)

      domain.name.must_equal "test_domain"

      domain = Looker.update_domain(domain.id, {:name => "new_test_domain"})
      domain.name.must_equal "new_test_domain"

      Looker.delete_domain(domain.id).must_equal true
    end

    it "updates domain from all to limited" do
      models = "all"
      domain = Looker.create_domain(:name => "test_domain", :models => models)
      domain.all_access.must_equal true

      new_models = ["foo", "bar"]
      domain = Looker.update_domain(domain.id, {:models => new_models})
      domain.all_access.must_equal false

      new_models.each do |m|
        domain.models.must_include m
      end

      Looker.delete_domain(domain.id).must_equal true
    end

    it "updates domain from limited to all" do
      models = ["foo", "bar"]
      domain = Looker.create_domain(:name => "test_domain", :models => models)
      domain.all_access.must_equal false

      new_models = "all"
      domain = Looker.update_domain(domain.id, {:models => new_models})
      domain.all_access.must_equal true

      Looker.delete_domain(domain.id).must_equal true
    end
  end

  describe ".delete_domain", :vcr do
    it "deletes user created domain" do
      domain = Looker.create_domain(:name => "test_domain", :models => "all")
      domain.name.must_equal "test_domain"

      Looker.delete_domain(domain.id).must_equal true
    end

    it "will not delete (403) built in all domain" do
      domains = Looker.all_domains
      all_domain = domains.select {|d| d.name == "All"}.first

      all_domain.wont_be_nil
      all_domain.all_access.must_equal true
      assert_raises Looker::Forbidden do
        Looker.delete_domain(all_domain.id)
      end
    end
  end

  # look TODO : get roles that include given domain.
  # test domain_roles(domain_id)
end
