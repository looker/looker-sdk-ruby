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

  describe ".update_role", :vcr do

    def with_role(&block)
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => ["administer"])
      domain = Looker.create_domain(:name => "test_domain", :models => "all")
      role = Looker.create_role(:name => "test_role", :domain_id => domain.id, :role_type_id => role_type.id)
      begin
        yield role
      ensure
        Looker.delete_role(role.id).must_equal true
        Looker.delete_role_type(role_type.id).must_equal true
        Looker.delete_domain(domain.id).must_equal true
      end
    end

    it "updates a role" do
      with_role do |role|
        role_type = Looker.create_role_type(:name => "new_test_role_type", :permissions => ["administer"])
        domain = Looker.create_domain(:name => "new_test_domain", :models => "all")

        new_role = Looker.update_role(role.id, {:name => "new_test_role", :domain_id => domain.id, :role_type_id => role_type.id})

        new_role.name.must_equal "new_test_role"
        new_role.domain.id.must_equal domain.id
        new_role.role_type.id.must_equal role_type.id

        Looker.delete_role_type(role_type.id).must_equal true
        Looker.delete_domain(domain.id).must_equal true
      end
    end

    it "allows update to same name" do
      with_role do |role|
        new_role = Looker.update_role(role.id, {:name => role.name})
        new_role.name.must_equal role.name
      end
    end

    it "rejects update with duplicate name" do
      with_role do |role|
        new_role = Looker.create_role(:name => "new_name", :domain_id => role.domain.id, :role_type_id => role.role_type.id)
        assert_raises Looker::UnprocessableEntity do
          Looker.update_role(role.id, {:name => new_role.name})
        end
        Looker.delete_role(new_role.id).must_equal true
      end
    end

    it "requires a valid role_type_id to update" do
      with_role do |role|
        assert_raises Looker::UnprocessableEntity do
          Looker.update_role(role.id, :role_type_id => 9999)
        end
      end
    end

    it "requires a valid domain_id to update" do
      with_role do |role|
        assert_raises Looker::UnprocessableEntity do
          Looker.update_role(role.id, :domain_id => 9999)
        end
      end
    end
  end

  describe ".delete_role", :vcr do
    it "deletes user created roles" do
      role_type = Looker.create_role_type(:name => "test_role_type", :permissions => ["administer"])
      domain = Looker.create_domain(:name => "test_domain", :models => "all")
      role = Looker.create_role(:name => "test_role", :domain_id => domain.id, :role_type_id => role_type.id)

      Looker.delete_role(role.id).must_equal true
      Looker.delete_role_type(role_type.id).must_equal true
      Looker.delete_domain(domain.id).must_equal true
    end

    it "will not delete (403) built in admin role" do
      roles = Looker.all_roles
      admin_role = roles.select {|d| d.name == "Admin"}.first

      admin_role.wont_be_nil
      admin_role.domain.name.must_equal "All"
      admin_role.role_type.name.must_equal "Admin"

      assert_raises Looker::Forbidden do
        Looker.delete_role(admin_role.id)
      end
    end
  end
end
