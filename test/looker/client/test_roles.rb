require_relative '../../helper'

describe Looker::Client::Roles do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  def role_options
    {
      :models => 'all',
      :name => 'test_role',
      :permissions => [:access_data, :explore, :see_dashboards]
    }
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

  describe ".update_role", :vcr do
    it "correctly updates role name" do
      role = Looker.create_role(role_options)
      role = Looker.update_role(role.id, {:name => "test_role9"})
      role.name.must_equal "test_role9"
    end

    it "correctly updates role permissions" do
      permissions_list = [:access_data, :explore, :see_dashboards]
      role = Looker.create_role(role_options)
      role = Looker.update_role(role[:id], {:permissions => permissions_list})
      permissions_list.each do |permission|
        role.permissions.must_include permission.to_s
      end
    end

    it "it will not add permissions that do not exist" do
      permission = :not_a_permission
      role = Looker.create_role(role_options)
      assert_raises Looker::UnprocessableEntity do
        Looker.update_role(role[:id], { :permissions => [permission] })
      end
    end

    it "correctly updates role models when all" do
      models = "all"
      role = Looker.create_role(role_options.merge(:models => ["thelook", "everything_is_awesome"]))
      role = Looker.update_role(role.id, {:models => models})
      role.models.access.must_equal "all"
    end

    it "correctly updates role models with limited set" do
      # look TODO only allow for models that exist?
      models = ["thelook", "model_1"]
      role = Looker.create_role(role_options)
      role = Looker.update_role(role.id, {:models => models})
      role.models.access.must_equal "limited"
      role_models = Looker.role_models(role.id)
      names = role_models.map(&:name)
      models.each do |model|
        names.must_include model
      end
    end
  end
  describe ".create_role", :vcr do
    it "creates role" do
      role = Looker.create_role(role_options)
      role.must_be_kind_of Sawyer::Resource
      role.name.must_equal 'test_role'
      role.permissions.must_include "access_data"
      role.models.access.must_equal 'all'
    end
  end
end
