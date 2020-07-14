# frozen_string_literal: true

require 'spec_helper'

describe Intercom::Traits::ApiResource do
  let(:object_json) do
    { 'type' => 'company',
      'id' => 'aaaaaaaaaaaaaaaaaaaaaaaa',
      'app_id' => 'some-app-id',
      'name' => 'SuperSuite',
      'plan_id' => 1,
      'remote_company_id' => '8',
      'remote_created_at' => 103_201,
      'created_at' => 1_374_056_196,
      'user_count' => 1,
      'custom_attributes' => {},
      'metadata' => {
        'type' => 'user',
        'color' => 'cyan'
      },
      'nested_fields' => {
        'type' => 'nested_fields_content',
        'field_1' => {
          'type' => 'field_content',
          'name' => 'Nested Field'
        }
      }
    }
  end

  let(:object_hash) do
    {
      type: 'company',
      id: 'aaaaaaaaaaaaaaaaaaaaaaaa',
      app_id: 'some-app-id',
      name: 'SuperSuite',
      plan_id: 1,
      remote_company_id: '8',
      remote_created_at: 103_201,
      created_at: 1_374_056_196,
      user_count: 1,
      custom_attributes: { type: 'ping' },
      metadata: {
        type: 'user',
        color: 'cyan'
      },
      nested_fields: {
        type: 'nested_fields_content',
        field_1: {
          type: 'field_content',
          name: 'Nested Field'
        }
      }
    }
  end

  let(:api_resource) { DummyClass.new.extend(Intercom::Traits::ApiResource) }

  before(:each) { api_resource.from_response(object_json) }

  it 'coerces time on parsing json' do
    assert_equal Time.at(1_374_056_196), api_resource.created_at
  end

  it 'exposes string' do
    assert_equal Time.at(1_374_056_196), api_resource.created_at
  end

  it "treats 'metadata' as a plain hash, not a typed object" do
    assert_equal Hash, api_resource.metadata.class
  end

  it 'dynamically defines accessors when a non-existent property is called that looks like a setter' do
    _(api_resource).wont_respond_to :spiders
    api_resource.spiders = 4
    _(api_resource).must_respond_to :spiders
  end

  it 'calls dynamically defined getter when asked' do
    api_resource.foo = 4
    assert_equal 4, api_resource.foo
  end

  it 'accepts unix timestamps into dynamically defined date setters' do
    api_resource.foo_at = 1_401_200_468
    assert_equal 1_401_200_468, api_resource.instance_variable_get(:@foo_at)
  end

  it 'exposes dates correctly for dynamically defined getters' do
    api_resource.foo_at = 1_401_200_468
    assert_equal Time.at(1_401_200_468), api_resource.foo_at
  end

  it 'throws regular method missing error when non-existent getter is called that is backed by an instance variable' do
    api_resource.instance_variable_set(:@bar, 'you cant see me')
    _(proc { api_resource.bar }).must_raise NoMethodError
  end

  it 'throws attribute not set error when non-existent getter is called that is not backed by an instance variable' do
    _(proc { api_resource.flubber }).must_raise Intercom::AttributeNotSetError
  end

  it 'throws regular method missing error when non-existent method is called that cannot be an accessor' do
    _(proc { api_resource.flubber! }).must_raise NoMethodError
    _(proc { api_resource.flubber? }).must_raise NoMethodError
  end

  it 'throws regular method missing error when non-existent setter is called with multiple arguments' do
    _(proc { api_resource.send(:flubber=, 'a', 'b') }).must_raise NoMethodError
  end

  it 'an initialized ApiResource is equal to one generated from a response' do
    class ConcreteApiResource; include Intercom::Traits::ApiResource; end
    initialized_api_resource = ConcreteApiResource.new(object_json)
    except(object_json, 'type').keys.each do |attribute|
      assert_equal initialized_api_resource.send(attribute), api_resource.send(attribute)
    end
  end

  it 'initialized ApiResource using hash is equal to one generated from response' do
    class ConcreteApiResource; include Intercom::Traits::ApiResource; end

    api_resource.from_hash(object_hash)
    initialized_api_resource = ConcreteApiResource.new(object_hash)
    except(object_json, 'type').keys.each do |attribute|
      assert_equal initialized_api_resource.send(attribute), api_resource.send(attribute)
    end
  end

  describe 'correctly equates two resources' do
    class DummyResource; include Intercom::Traits::ApiResource; end

    specify 'if each resource has the same class and same value' do
      api_resource1 = DummyResource.new(object_json)
      api_resource2 = DummyResource.new(object_json)
      assert_equal (api_resource1 == api_resource2), true
    end

    specify 'if each resource has the same class and different value' do
      object2_json = object_json.merge('id' => 'bbbbbb')
      api_resource1 = DummyResource.new(object_json)
      api_resource2 = DummyResource.new(object2_json)
      assert_equal (api_resource1 == api_resource2), false
    end

    specify 'if each resource has a different class' do
      dummy_resource = DummyResource.new(object_json)
      assert_equal (dummy_resource == api_resource), false
    end
  end

  it 'correctly generates submittable hash when no updates' do
    assert_equal api_resource.to_submittable_hash, {}
  end

  it 'correctly generates submittable hash when there are updates' do
    api_resource.name = 'SuperSuite updated'
    api_resource.nested_fields.field_1.name = 'Updated Name'
    assert_equal api_resource.to_submittable_hash, {
      'name' => 'SuperSuite updated',
      'nested_fields' => {
        'field_1' => {
            'name' => 'Updated Name'
        }
      }
    }
  end

  def except(h, *keys)
    keys.each { |key| h.delete(key) }
    h
  end

  class DummyClass; end
end
