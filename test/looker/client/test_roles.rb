require_relative '../../helper'

describe LookerSDK::Client::Roles do

  before(:each) do
    reset_sdk
  end

  def with_role(&block)
    role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => ["administer"])
    role_domain = LookerSDK.create_role_domain(:name => mk_name("role_domain"), :models => "all")
    role = LookerSDK.create_role(:name => mk_name("role1"), :role_domain_id => role_domain.id, :role_type_id => role_type.id)
    begin
      yield role
    ensure
      LookerSDK.delete_role(role.id).must_equal true
      LookerSDK.delete_role_type(role_type.id).must_equal true
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
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
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => ["administer"])
      role_domain = LookerSDK.create_role_domain(:name => mk_name("role_domain"), :models => "all")
      role = LookerSDK.create_role(:name => mk_name("role1"), :role_domain_id => role_domain.id, :role_type_id => role_type.id)

      role.name.must_equal mk_name("role1")
      role.role_domain.id.must_equal role_domain.id
      role.role_type.id.must_equal role_type.id

      LookerSDK.delete_role(role.id).must_equal true
      LookerSDK.delete_role_type(role_type.id).must_equal true
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "requires a name to create" do
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => ["administer"])
      role_domain = LookerSDK.create_role_domain(:name => mk_name("role_domain"), :models => "all")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:role_domain_id => role_domain.id, :role_type_id => role_type.id)
      end

      LookerSDK.delete_role_type(role_type.id).must_equal true
      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "requires a valid role_type_id to create" do
      role_domain = LookerSDK.create_role_domain(:name => mk_name("role_domain"), :models => "all")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :role_domain_id => role_domain.id)
      end

      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :role_domain_id => role_domain.id, :role_type_id => 9999)
      end

      LookerSDK.delete_role_domain(role_domain.id).must_equal true
    end

    it "requires a valid role_domain_id to create" do
      role_type = LookerSDK.create_role_type(:name => mk_name("role_type_1"), :permissions => ["administer"])
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :role_type_id => role_type.id)
      end

      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_role(:name => mk_name("role1"), :role_type_id => role_type.id, :role_domain_id => 9999)
      end

      LookerSDK.delete_role_type(role_type.id).must_equal true
    end
  end

  describe ".update_role" do

    it "updates a role" do
      with_role do |role|
        user_count = LookerSDK.all_users.count

        role_type = LookerSDK.create_role_type(:name => mk_name("role_type_new"), :permissions => ["administer"])
        role_domain = LookerSDK.create_role_domain(:name => mk_name("role_domain_new"), :models => "all")

        updated_role = LookerSDK.update_role(role.id, {:name => mk_name("role_new"), :role_domain_id => role_domain.id, :role_type_id => role_type.id})

        updated_role.name.must_equal mk_name("role_new")
        updated_role.role_domain.id.must_equal role_domain.id
        updated_role.role_type.id.must_equal role_type.id
        LookerSDK.all_users.count.must_equal user_count

        LookerSDK.delete_role_type(role_type.id).must_equal true
        LookerSDK.delete_role_domain(role_domain.id).must_equal true
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
        new_role = LookerSDK.create_role(:name => mk_name("role_new"), :role_domain_id => role.role_domain.id, :role_type_id => role.role_type.id)
        assert_raises LookerSDK::UnprocessableEntity do
          LookerSDK.update_role(role.id, {:name => new_role.name})
        end
        LookerSDK.delete_role(new_role.id).must_equal true
      end
    end

    it "requires a valid role_type_id to update" do
      with_role do |role|
        assert_raises LookerSDK::UnprocessableEntity do
          LookerSDK.update_role(role.id, :role_type_id => 9999)
        end
      end
    end

    it "requires a valid role_domain_id to update" do
      with_role do |role|
        assert_raises LookerSDK::UnprocessableEntity do
          LookerSDK.update_role(role.id, :role_domain_id => 9999)
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
      admin_role.role_domain.name.must_equal "All"
      admin_role.role_type.name.must_equal "Admin"

      assert_raises LookerSDK::MethodNotAllowed do
        LookerSDK.delete_role(admin_role.id)
      end
    end
  end

  describe ".set_role_users" do
    it "sets users of role" do
      users = (1..5).map {|i| LookerSDK.create_user }
      with_role do |role|
        LookerSDK.set_role_users(role.id, users.map {|u| u.id })
        new_user_ids = LookerSDK.role_users(role.id).map {|user| user.id}

        users.map {|u| u.id}.each do |user_id|
          new_user_ids.must_include user_id
        end

      end
      users.each do |u|
        LookerSDK.delete_user(u.id)
      end
    end
  end
end
