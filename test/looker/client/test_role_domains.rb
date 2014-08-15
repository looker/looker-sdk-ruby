require_relative '../../helper'

describe LookerSDK::Client::RoleDomains do

  before(:each) do
    LookerSDK.reset!
    @client = LookerSDK::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_role_domains", :vcr do
    it "returns all Looker role_domains" do
      role_domains = LookerSDK.all_role_domains
      role_domains.must_be_kind_of Array

      role_domains.each do |role_domain|
        role_domain.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".role_domain", :vcr do
    it "retrives single role_domain" do
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => "all")

      fetched_role_domain = LookerSDK.role_domain(role_domain.id)

      fetched_role_domain.name.must_equal role_domain.name
      role_domain.models.each do |m|
        fetched_role_domain.models.must_include m
      end
      fetched_role_domain.all_access.must_equal role_domain.all_access

      # clean up role_domain
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end
  end


  describe ".create_role_domain", :vcr do
    it "creates role_domain with models list" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => models)

      role_domain.name.must_equal "test_role_domain"
      role_domain.all_access.must_equal false
      models.each do |m|
        role_domain.models.must_include m
      end
      # clean up role_domain
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "creates role_domain with all models" do
      models = "all"
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => models)

      role_domain.name.must_equal "test_role_domain"
      role_domain.all_access.must_equal true
      # clean up role_domain
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "rejects duplicate name" do
      models = "all"
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => models)
      role_domain.name.must_equal "test_role_domain"
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role_domain(:name => role_domain.name, :models => models)
      end
      # clean up role_domain
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end
  end

  describe ".update_role_domain", :vcr do
    it "updates name" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => models)

      role_domain.name.must_equal "test_role_domain"

      role_domain = LookerSDK.update_role_domain(role_domain.id, {:name => "new_test_role_domain"})
      role_domain.name.must_equal "new_test_role_domain"

      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "updates role_domain from all to limited" do
      models = "all"
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => models)
      role_domain.all_access.must_equal true

      new_models = ["foo", "bar"]
      role_domain = LookerSDK.update_role_domain(role_domain.id, {:models => new_models})
      role_domain.all_access.must_equal false

      new_models.each do |m|
        role_domain.models.must_include m
      end

      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "updates role domain from limited to all" do
      models = ["foo", "bar"]
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => models)
      role_domain.all_access.must_equal false

      new_models = "all"
      role_domain = LookerSDK.update_role_domain(role_domain.id, {:models => new_models})
      role_domain.all_access.must_equal true

      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end
  end

  describe ".delete_role_domain", :vcr do
    it "deletes user created role_domain" do
      role_domain = LookerSDK.create_role_domain(:name => "test_role_domain", :models => "all")
      role_domain.name.must_equal "test_role_domain"

      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "will not delete (403) built in all role domain" do
      role_domains = LookerSDK.all_role_domains
      all_role_domain = role_domains.select {|d| d.name == "All"}.first

      all_role_domain.wont_be_nil
      all_role_domain.all_access.must_equal true
      assert_raises LookerSDK::ClientError do
        LookerSDK.delete_role_domain(all_role_domain.id)
      end
    end
  end

  # look TODO : get roles that include given role_domain.
  # test role_domain_roles(role_domain_id)
end
