require_relative '../../helper'

describe Looker::Client::Roles do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_roles", :vcr do
    it "returns all Looker roles" do

      roles = Looker.all_roles
      roles.must_be_kind_of Array
      roles.length.must_equal 2
      roles.each do |user|
        user.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".create_role", :vcr do
    it "creates a role" do
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => ["administer"])
      domain = Looker.create_domain(:name => "test_domain", :models => "all")
      role = Looker.create_role(:name => "test_role", :domain_id => domain.id, :role_type_id => role_type.id)
      role.name.must_equal "test_role"
      role.domain.id.must_equal domain.id
      role.role_type.id.must_equal role_type.id
      Looker.delete_role(role.id).must_equal true
      Looker.delete_role_type(role_type.id).must_equal true
      Looker.delete_domain(domain.id).must_equal true
    end

    it "requires a name to create" do
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => ["administer"])
      domain = Looker.create_domain(:name => "test_domain", :models => "all")
      assert_raises Looker::UnprocessableEntity do
        Looker.create_role(:domain_id => domain.id, :role_type_id => role_type.id)
      end

      Looker.delete_role_type(role_type.id).must_equal true
      Looker.delete_domain(domain.id).must_equal true
    end

    it "requires a valid role_type_id to create" do
      domain = Looker.create_domain(:name => "test_domain", :models => "all")
      assert_raises Looker::UnprocessableEntity do
        Looker.create_role(:name => "test_domain", :domain_id => domain.id)
      end

      assert_raises Looker::UnprocessableEntity do
        Looker.create_role(:name => "test_domain", :domain_id => domain.id, :role_type_id => 9999)
      end

      Looker.delete_domain(domain.id).must_equal true
    end

    it "requires a valid domain_id to create" do
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => ["administer"])
      assert_raises Looker::UnprocessableEntity do
        Looker.create_role(:name => "test_domain", :role_type_id => role_type.id)
      end

      assert_raises Looker::UnprocessableEntity do
        Looker.create_role(:name => "test_domain", :role_type_id => role_type.id, :domain_id => 9999)
      end

      Looker.delete_role_type(role_type.id).must_equal true
    end
  end
end
