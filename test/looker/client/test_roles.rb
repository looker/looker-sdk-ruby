require_relative '../../helper'

describe 'Roles' do

  before(:each) do
   setup_sdk
  end

  after(:each) do
   teardown_sdk
  end

  def with_role(&block)
    permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => ["see_looks"])
    model_set = LookerSDK.create_model_set(:name => mk_name("model_set"), :models => "all")
    role = LookerSDK.create_role(:name => mk_name("role1"), :model_set_id => model_set.id, :permission_set_id => permission_set.id)
    begin
      yield role
    ensure
      LookerSDK.delete_role(role.id).must_equal true
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
      LookerSDK.delete_model_set(model_set.id).must_equal true
    end
  end

  describe ".all_roles" do
    it "returns all Looker roles" do

      roles = LookerSDK.all_roles
      roles.must_be_kind_of Array
      (roles.length >= 1).must_equal true
      roles.each do |user|
        user.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".create_role" do
    it "creates a role" do
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => ["see_looks"])
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set"), :models => "all")
      role = LookerSDK.create_role(:name => mk_name("role1"), :model_set_id => model_set.id, :permission_set_id => permission_set.id)

      role.name.must_equal mk_name("role1")
      role.model_set.id.must_equal model_set.id
      role.permission_set.id.must_equal permission_set.id

      LookerSDK.delete_role(role.id).must_equal true
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
      LookerSDK.delete_model_set(model_set.id).must_equal true
    end

    it "requires a name to create" do
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => ["see_looks"])
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set"), :models => "all")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:model_set_id => model_set.id, :permission_set_id => permission_set.id)
      end

      LookerSDK.delete_permission_set(permission_set.id).must_equal true
      LookerSDK.delete_model_set(model_set.id).must_equal true
    end

    it "requires a valid permission_set_id to create" do
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set"), :models => "all")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :model_set_id => model_set.id)
      end

      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :model_set_id => model_set.id, :permission_set_id => 9999)
      end

      LookerSDK.delete_model_set(model_set.id).must_equal true
    end

    it "requires a valid model_set_id to create" do
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_1"), :permissions => ["see_looks"])
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :permission_set_id => permission_set.id)
      end

      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :permission_set_id => permission_set.id, :model_set_id => 9999)
      end

      LookerSDK.delete_permission_set(permission_set.id).must_equal true
    end
  end

  describe ".update_role" do

    it "updates a role" do
      with_role do |role|
        user_count = LookerSDK.all_users.count

        permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set_new"), :permissions => ["see_looks"])
        model_set = LookerSDK.create_model_set(:name => mk_name("model_set_new"), :models => "all")

        updated_role = LookerSDK.update_role(role.id, {:name => mk_name("role_new"), :model_set_id => model_set.id, :permission_set_id => permission_set.id})

        updated_role.name.must_equal mk_name("role_new")
        updated_role.model_set.id.must_equal model_set.id
        updated_role.permission_set.id.must_equal permission_set.id
        LookerSDK.all_users.count.must_equal user_count

        LookerSDK.delete_permission_set(permission_set.id).must_equal true
        LookerSDK.delete_model_set(model_set.id).must_equal true
      end
    end

    it "allows update to same name" do
      with_role do |role|
        new_role = LookerSDK.update_role(role.id, {:name => role.name})
        new_role.name.must_equal role.name
      end
    end

    it "rejects update with duplicate name" do
      with_role do |role|
        new_role = LookerSDK.create_role(:name => mk_name("role_new"), :model_set_id => role.model_set.id, :permission_set_id => role.permission_set.id)
        assert_raises LookerSDK::UnprocessableEntity do
          LookerSDK.update_role(role.id, {:name => new_role.name})
        end
        LookerSDK.delete_role(new_role.id).must_equal true
      end
    end

    it "requires a valid permission_set_id to update" do
      with_role do |role|
        assert_raises LookerSDK::UnprocessableEntity do
          LookerSDK.update_role(role.id, :permission_set_id => 9999)
        end
      end
    end

    it "requires a valid model_set_id to update" do
      with_role do |role|
        assert_raises LookerSDK::UnprocessableEntity do
          LookerSDK.update_role(role.id, :model_set_id => 9999)
        end
      end
    end
  end

  describe ".delete_role" do
    it "deletes user created roles" do
      with_role {}
    end

    it "will not delete (403) built in admin role" do
      roles = LookerSDK.all_roles
      admin_role = roles.select {|d| d.name == "Admin"}.first

      admin_role.wont_be_nil
      admin_role.model_set.name.must_equal "All"
      admin_role.permission_set.name.must_equal "Admin"

      assert_raises LookerSDK::MethodNotAllowed do
        LookerSDK.delete_role(admin_role.id)
      end
    end
  end

  describe ".set_role_users" do
    it "sets users of role" do
      users = (1..5).map {|i| LookerSDK.create_user }
      with_role do |role|
        LookerSDK.set_role_users(role.id, {:users => users.map {|u| u.id }})
        new_user_ids = LookerSDK.role_users(role.id).map {|user| user.id}

        users.map {|u| u.id}.each do |user_id|
          new_user_ids.must_include user_id
        end

      end
      users.each do |u|
        LookerSDK.delete_user(u.id)
      end
    end

    it "wont set duplicate roles" do
      users = (1..5).map { |i| LookerSDK.create_user }
      with_role do |role|
        # set the users to be all the user ids plus the first one twice.
        LookerSDK.set_role_users(role.id, {:users => users.map {|u| u.id } << users.first.id})

        new_user_ids = LookerSDK.role_users(role.id).map {|user| user.id}
        new_user_ids.select {|user_id| user_id == users.first.id}.length.must_equal 1
      end
      users.each do |u|
        LookerSDK.delete_user(u.id)
      end
    end
  end
end
