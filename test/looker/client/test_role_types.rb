require_relative '../../helper'

describe LookerSDK::Client::RoleTypes do

  before(:each) do
    reset_sdk
  end

  describe ".all_role_types", :vcr do
    it "returns all Looker role_types" do
      role_types = LookerSDK.all_role_types
      role_types.must_be_kind_of Array

      role_types.each do |role_type|
        role_type.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".role_type", :vcr do
    it "retrives single role_type" do
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => "all")

      fetched_role_type = LookerSDK.role_type(role_type.id)

      fetched_role_type.name.must_equal role_type.name
      role_type.permissions.each do |p|
        fetched_role_type.permissions.must_include p.to_s
      end
      fetched_role_type.all_access.must_equal role_type.all_access

      # clean up role_type
      LookerSDK.delete_role_type(role_type.id).must_equal true
    end
  end

  describe ".create_role_type", :vcr do
    it "creates role_type with permissions list" do
      permissions = [:see_dashboards, :access_data, :administer]
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)

      role_type.name.must_equal mk_name("role_type_1")
      role_type.all_access.must_equal false
      permissions.each do |p|
        role_type.permissions.must_include p.to_s
      end
      # clean up role_type
      LookerSDK.delete_role_type(role_type.id).must_equal true
    end

    it "creates role_type with all permissions" do
      permissions = "all"
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)

      role_type.name.must_equal mk_name("role_type_1")
      role_type.all_access.must_equal true
      # clean up role_type
      LookerSDK.delete_role_type(role_type.id).must_equal true
    end

    it "rejects duplicate name" do
      permissions = "all"
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)
      role_type.name.must_equal mk_name("role_type_1")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role_type(:name => role_type.name, :permissions => permissions)
      end
      # clean up role_type
      LookerSDK.delete_role_type(role_type.id).must_equal true
    end

    # TODO - this constraint does not exist in the API - either add the constraint or whack this test.
    # it "rejects invalid permissions" do
    #   permissions = [:see_dashboards, :not_a_permission]
    #   assert_raises LookerSDK::UnprocessableEntity do
    #     LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)
    #   end
    # end
  end

  describe ".update_role_type", :vcr do
    it "updates name" do
      permissions = [:see_dashboards, :access_data]
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)

      role_type.name.must_equal mk_name("role_type_1")

      role_type = LookerSDK.update_role_type(role_type.id, {:name => mk_name("role_type_new")})
      role_type.name.must_equal mk_name("role_type_new")

      LookerSDK.delete_role_type(role_type.id).must_equal true
    end

    it "updates role_type from all to limited" do
      permissions = "all"
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)
      role_type.all_access.must_equal true

      new_permissions = [:see_dashboards, :access_data]
      role_type = LookerSDK.update_role_type(role_type.id, {:permissions => new_permissions})
      role_type.all_access.must_equal false

      new_permissions.each do |p|
        role_type.permissions.must_include p.to_s
      end

      LookerSDK.delete_role_type(role_type.id).must_equal true
    end

    it "updates role_type from limited to all" do
      permissions = [:see_dashboards, :access_data]
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => permissions)
      role_type.all_access.must_equal false

      new_permissions = "all"
      role_type = LookerSDK.update_role_type(role_type.id, {:permissions => new_permissions})
      role_type.all_access.must_equal true

      LookerSDK.delete_role_type(role_type.id).must_equal true
    end
  end

  describe ".delete_role_type", :vcr do
    it "deletes user created role_type" do
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => "all")
      role_type.name.must_equal mk_name("role_type_1")

      LookerSDK.delete_role_type(role_type.id).must_equal true
    end

    it "will not delete (403) built in all role_type" do
      role_types = LookerSDK.all_role_types
      all_role_type = role_types.select {|d| d.name == "Admin"}.first

      all_role_type.wont_be_nil
      all_role_type.all_access.must_equal true
      assert_raises LookerSDK::MethodNotAllowed do
        LookerSDK.delete_role_type(all_role_type.id)
      end
    end
  end

  # look TODO : get roles that include given role_type.
  # test role_type_roles(role_type_id)

end
