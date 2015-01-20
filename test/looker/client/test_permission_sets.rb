require_relative '../../helper'

describe 'PermissionSets' do

  before(:each) do
   setup_sdk
  end

  after(:each) do
   teardown_sdk
  end

  describe ".all_permission_sets" do
    it "returns all Looker permission_sets" do
      permission_sets = LookerSDK.all_permission_sets
      permission_sets.must_be_kind_of Array

      permission_sets.each do |permission_set|
        permission_set.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".permission_set" do
    it "retrives single permission_set" do
      permissions = [:see_dashboards, :access_data]
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => permissions)

      fetched_permission_set = LookerSDK.permission_set(permission_set.id)

      fetched_permission_set.name.must_equal permission_set.name
      permission_set.permissions.each do |p|
        fetched_permission_set.permissions.must_include p.to_s
      end

      fetched_permission_set.all_access.must_equal permission_set.all_access

      # clean up permission_set
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
    end
  end

  describe ".create_permission_set" do
    it "creates permission_set with permissions list" do
      permissions = [:see_dashboards, :access_data]
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => permissions)

      permission_set.name.must_equal mk_name("permission_set_1")
      permission_set.all_access.must_equal false
      permissions.each do |p|
        permission_set.permissions.must_include p.to_s
      end
      # clean up permission_set
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
    end

    it "rejects duplicate name" do
      permissions = "all"
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => permissions)
      permission_set.name.must_equal mk_name("permission_set_1")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_permission_set(:name => permission_set.name, :permissions => permissions)
      end
      # clean up permission_set
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
    end

    # TODO - this constraint does not exist in the API - either add the constraint or whack this test.
    # it "rejects invalid permissions" do
    #   permissions = [:see_dashboards, :not_a_permission]
    #   assert_raises LookerSDK::UnprocessableEntity do
    #     LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => permissions)
    #   end
    # end
  end

  describe ".update_permission_set" do
    it "updates name" do
      permissions = [:see_dashboards, :access_data]
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => permissions)

      permission_set.name.must_equal mk_name("permission_set_1")

      permission_set = LookerSDK.update_permission_set(permission_set.id, {:name => mk_name("permission_set_new")})
      permission_set.name.must_equal mk_name("permission_set_new")

      LookerSDK.delete_permission_set(permission_set.id).must_equal true
    end

  end

  describe ".delete_permission_set" do
    it "deletes user created permission_set" do
      permissions = [:see_dashboards, :access_data]
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => permissions)
      permission_set.name.must_equal mk_name("permission_set_1")

      LookerSDK.delete_permission_set(permission_set.id).must_equal true
    end

    it "will not delete (403) built in all permission_set" do
      permission_sets = LookerSDK.all_permission_sets
      all_permission_set = permission_sets.select {|d| d.name == "Admin"}.first

      all_permission_set.wont_be_nil
      all_permission_set.all_access.must_equal true
      assert_raises LookerSDK::MethodNotAllowed do
        LookerSDK.delete_permission_set(all_permission_set.id)
      end
    end
  end

  # look TODO : get roles that include given permission_set.
  # test permission_set_roles(permission_set_id)

end
