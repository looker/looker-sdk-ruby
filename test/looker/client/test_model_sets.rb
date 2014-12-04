require_relative '../../helper'

describe 'ModelSets' do

  before(:each) do
   setup_sdk
  end

  after(:each) do
   teardown_sdk
  end

  describe ".all_model_sets" do
    it "returns all Looker model_sets" do
      model_sets = LookerSDK.all_model_sets
      model_sets.must_be_kind_of Array

      model_sets.each do |model_set|
        model_set.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".model_set" do
    it "retrives single model_set" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set_1"), :models => models)

      fetched_model_set = LookerSDK.model_set(model_set.id)

      fetched_model_set.name.must_equal model_set.name
      model_set.models.each do |m|
        fetched_model_set.models.must_include m
      end
      fetched_model_set.all_access.must_equal model_set.all_access

      # clean up model_set
      LookerSDK.delete_model_set(model_set.id).must_equal true
    end
  end


  describe ".create_model_set" do
    it "creates model_set with models list" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set_1"), :models => models)

      model_set.name.must_equal mk_name("model_set_1")
      model_set.all_access.must_equal false
      models.each do |m|
        model_set.models.must_include m
      end
      # clean up model_set
      LookerSDK.delete_model_set(model_set.id).must_equal true
    end

    it "rejects duplicate name" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set_1"), :models => models)

      model_set.name.must_equal mk_name("model_set_1")
      assert_raises LookerSDK::UnprocessableEntity do
        LookerSDK.create_model_set(:name => model_set.name, :models => models)
      end
      # clean up model_set
      LookerSDK.delete_model_set(model_set.id).must_equal true
    end
  end

  describe ".update_model_set" do
    it "updates name" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set_1"), :models => models)

      model_set.name.must_equal mk_name("model_set_1")

      model_set = LookerSDK.update_model_set(model_set.id, {:name => mk_name("model_set_new")})
      model_set.name.must_equal mk_name("model_set_new")

      LookerSDK.delete_model_set(model_set.id).must_equal true
    end

  end

  describe ".delete_model_set" do
    it "deletes user created model_set" do
      models = ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwxyz"]
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set_1"), :models => models)
      model_set.name.must_equal mk_name("model_set_1")

      LookerSDK.delete_model_set(model_set.id).must_equal true
    end

    it "will not delete (403) built in all role domain" do
      model_sets = LookerSDK.all_model_sets
      all_model_set = model_sets.select {|d| d.name == "All"}.first

      all_model_set.wont_be_nil
      all_model_set.all_access.must_equal true
      assert_raises LookerSDK::MethodNotAllowed do
        LookerSDK.delete_model_set(all_model_set.id)
      end
    end
  end

  # look TODO : get roles that include given model_set.
  # test model_set_roles(model_set_id)
end
