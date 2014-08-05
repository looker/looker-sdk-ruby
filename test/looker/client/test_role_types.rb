require_relative '../../helper'

describe Looker::Client::RoleTypes do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_role_types", :vcr do
    it "returns all Looker role_types" do
      role_types = Looker.all_role_types
      role_types.must_be_kind_of Array

      role_types.each do |role_type|
        role_type.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".role_type", :vcr do
    it "retrives single role_type" do
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => "all")

      fetched_role_type = Looker.role_type(role_type.id)

      fetched_role_type.name.must_equal role_type.name
      role_type.permissions.each do |m|
        fetched_role_type.permissions.must_include m
      end
      fetched_role_type.all_access.must_equal role_type.all_access

      # clean up role_type
      Looker.delete_role_type(role_type.id).must_equal true
    end
  end


  describe ".create_role_type", :vcr do
    it "creates role_type with permissions list" do
      permissions = [:see_dashboards, :access_data, :administer]
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => permissions)

      role_type.name.must_equal "test_role_type"
      role_type.all_access.must_equal false
      permissions.each do |m|
        role_type.permissions.must_include m.to_s
      end
      # clean up role_type
      Looker.delete_role_type(role_type.id).must_equal true
    end

    it "creates role_type with all permissions" do
      permissions = "all"
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => permissions)

      role_type.name.must_equal "test_role_type"
      role_type.all_access.must_equal true
      # clean up role_type
      Looker.delete_role_type(role_type.id).must_equal true
    end

    it "rejects duplicate name" do
      permissions = "all"
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => permissions)
      role_type.name.must_equal "test_role_type"
      assert_raises Looker::UnprocessableEntity do
        Looker.create_role_type(:name => role_type.name, :permissions => permissions)
      end
      # clean up role_type
      Looker.delete_role_type(role_type.id).must_equal true
    end
  end

  describe ".update_role_type", :vcr do
    it "updates name" do
      permissions = [:see_dashboards, :access_data]
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => permissions)

      role_type.name.must_equal "test_role_type"

      role_type = Looker.update_role_type(role_type.id, {:name => "new_test_role_type"})
      role_type.name.must_equal "new_test_role_type"

      Looker.delete_role_type(role_type.id).must_equal true
    end

    it "updates role_type from all to limited" do
      permissions = "all"
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => permissions)
      role_type.all_access.must_equal true

      new_permissions = [:see_dashboards, :access_data]
      role_type = Looker.update_role_type(role_type.id, {:permissions => new_permissions})
      role_type.all_access.must_equal false

      new_permissions.each do |m|
        role_type.permissions.must_include m.to_s
      end

      Looker.delete_role_type(role_type.id).must_equal true
    end

    it "updates role_type from limited to all" do
      permissions = [:see_dashboards, :access_data]
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => permissions)
      role_type.all_access.must_equal false

      new_permissions = "all"
      role_type = Looker.update_role_type(role_type.id, {:permissions => new_permissions})
      role_type.all_access.must_equal true

      Looker.delete_role_type(role_type.id).must_equal true
    end
  end

  describe ".delete_role_type", :vcr do
    it "deletes user created role_type" do
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => "all")
      role_type.name.must_equal "test_role_type"

      Looker.delete_role_type(role_type.id).must_equal true
    end

    it "will not delete (403) built in all role_type" do
      role_types = Looker.all_role_types
      all_role_type = role_types.select {|d| d.name == "Admin"}.first

      all_role_type.wont_be_nil
      all_role_type.all_access.must_equal true
      assert_raises Looker::Forbidden do
        Looker.delete_role_type(all_role_type.id)
      end
    end
  end

  # look TODO : get roles that include given role_type.
  # test role_type_roles(role_type_id)
end
