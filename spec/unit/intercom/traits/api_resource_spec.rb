require "spec_helper"

describe Intercom::Traits::ApiResource do
  let(:object_json) do
    {"type"=>"company",
     "id"=>"aaaaaaaaaaaaaaaaaaaaaaaa",
     "app_id"=>"some-app-id",
     "name"=>"SuperSuite",
     "plan_id"=>1,
     "remote_company_id"=>"8",
     "remote_created_at"=>103201,
     "created_at"=>1374056196,
     "user_count"=>1,
     "custom_attributes"=>{},
     "metadata"=>{
       "type"=>"user",
       "color"=>"cyan"
     }}
  end
  let(:api_resource) { DummyClass.new.extend(Intercom::Traits::ApiResource)}

  before(:each) { api_resource.from_response(object_json) }

  it "does not set type on parsing json" do
    api_resource.wont_respond_to :type
  end

  it "coerces time on parsing json" do
    assert_equal Time.at(1374056196), api_resource.created_at
  end

  it "exposes string" do
    assert_equal Time.at(1374056196), api_resource.created_at
  end

  it "treats 'metadata' as a plain hash, not a typed object" do
    assert_equal Hash, api_resource.metadata.class
  end

  it "dynamically defines accessors when a non-existent property is called that looks like a setter" do
    api_resource.wont_respond_to :spiders
    api_resource.spiders = 4
    api_resource.must_respond_to :spiders
  end

  it "calls dynamically defined getter when asked" do
    api_resource.foo = 4
    assert_equal 4, api_resource.foo
  end

  it "accepts unix timestamps into dynamically defined date setters" do
    api_resource.foo_at = 1401200468
    assert_equal 1401200468, api_resource.instance_variable_get(:@foo_at)
  end

  it "exposes dates correctly for dynamically defined getters" do
    api_resource.foo_at = 1401200468
    assert_equal Time.at(1401200468), api_resource.foo_at
  end

  it "throws regular method missing error when non-existent getter is called that is backed by an instance variable" do
    api_resource.instance_variable_set(:@bar, 'you cant see me')
    proc { api_resource.bar }.must_raise NoMethodError
  end

  it "throws attribute not set error when non-existent getter is called that is not backed by an instance variable" do
    proc { api_resource.flubber }.must_raise Intercom::AttributeNotSetError
  end

  it "throws regular method missing error when non-existent method is called that cannot be an accessor" do
    proc { api_resource.flubber! }.must_raise NoMethodError
    proc { api_resource.flubber? }.must_raise NoMethodError
  end

  it "throws regular method missing error when non-existent setter is called with multiple arguments" do
    proc { api_resource.send(:flubber=, 'a', 'b') }.must_raise NoMethodError
  end

  it "an initialized ApiResource is equal to on generated from a response" do
    class ConcreteApiResource; include Intercom::Traits::ApiResource; end
    initialized_api_resource = ConcreteApiResource.new(object_json)
    except(object_json, 'type').keys.each do |attribute|
      assert_equal initialized_api_resource.send(attribute), api_resource.send(attribute)
    end
  end
  
  def except(h, *keys)
    keys.each { |key| h.delete(key) }
    h
  end
  
  class DummyClass; end
end
