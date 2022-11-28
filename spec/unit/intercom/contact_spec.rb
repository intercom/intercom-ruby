# frozen_string_literal: true

require 'spec_helper'

describe Intercom::Contact do
  let(:client) { Intercom::Client.new(token: 'token') }

  it 'should be listable' do
    proxy = client.contacts.all
    _(proxy.resource_name).must_equal 'contacts'
    _(proxy.url).must_equal '/contacts'
    _(proxy.resource_class).must_equal Intercom::Contact
  end

  it 'should throw an ArgumentError when there are no parameters' do
    _(proc { client.contacts.create }).must_raise(ArgumentError)
  end

  it "to_hash'es itself" do
    created_at = Time.now
    contact = Intercom::Contact.new(email: 'jim@example.com', contact_id: '12345', created_at: created_at, name: 'Jim Bob')
    as_hash = contact.to_hash
    _(as_hash['email']).must_equal 'jim@example.com'
    _(as_hash['contact_id']).must_equal '12345'
    _(as_hash['created_at']).must_equal created_at.to_i
    _(as_hash['name']).must_equal 'Jim Bob'
  end

  it 'presents created_at and last_impression_at as Date' do
    now = Time.now
    contact = Intercom::Contact.new(created_at: now, last_impression_at: now)
    _(contact.created_at).must_be_kind_of Time
    _(contact.created_at.to_s).must_equal now.to_s
    _(contact.last_impression_at).must_be_kind_of Time
    _(contact.last_impression_at.to_s).must_equal now.to_s
  end

  it 'is throws a Intercom::AttributeNotSetError on trying to access an attribute that has not been set' do
    contact = Intercom::Contact.new
    _(proc { contact.foo_property }).must_raise Intercom::AttributeNotSetError
  end

  it 'presents a complete contact record correctly' do
    contact = Intercom::Contact.new(test_contact)
    _(contact.external_id).must_equal 'id-from-customers-app'
    _(contact.email).must_equal 'bob@example.com'
    _(contact.name).must_equal 'Joe Schmoe'
    _(contact.workspace_id).must_equal 'the-workspace-id'
    _(contact.session_count).must_equal 123
    _(contact.created_at.to_i).must_equal 1_401_970_114
    _(contact.remote_created_at.to_i).must_equal 1_393_613_864
    _(contact.updated_at.to_i).must_equal 1_401_970_114

    _(contact.avatar).must_be_kind_of Intercom::Avatar
    _(contact.avatar.image_url).must_equal 'https://graph.facebook.com/1/picture?width=24&height=24'

    _(contact.notes).must_be_kind_of Intercom::BaseCollectionProxy
    _(contact.tags).must_be_kind_of Intercom::BaseCollectionProxy
    _(contact.companies).must_be_kind_of Intercom::ClientCollectionProxy

    _(contact.custom_attributes).must_be_kind_of Intercom::Lib::FlatStore
    _(contact.custom_attributes['a']).must_equal 'b'
    _(contact.custom_attributes['b']).must_equal 2

    _(contact.social_profiles.size).must_equal 4
    twitter_account = contact.social_profiles.first
    _(twitter_account).must_be_kind_of Intercom::SocialProfile
    _(twitter_account.name).must_equal 'twitter'
    _(twitter_account.username).must_equal 'abc'
    _(twitter_account.url).must_equal 'http://twitter.com/abc'

    _(contact.location_data).must_be_kind_of Intercom::LocationData
    _(contact.location_data.city_name).must_equal 'Dublin'
    _(contact.location_data.continent_code).must_equal 'EU'
    _(contact.location_data.country_name).must_equal 'Ireland'
    _(contact.location_data.latitude).must_equal '90'
    _(contact.location_data.longitude).must_equal '10'
    _(contact.location_data.country_code).must_equal 'IRL'

    _(contact.unsubscribed_from_emails).must_equal true
    _(contact.user_agent_data).must_equal 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11'
  end

  it 'allows easy setting of custom data' do
    now = Time.now
    contact = Intercom::Contact.new
    contact.custom_attributes['mad'] = 123
    contact.custom_attributes['other'] = now.to_i
    contact.custom_attributes['thing'] = 'yay'
    _(contact.to_hash['custom_attributes']).must_equal 'mad' => 123, 'other' => now.to_i, 'thing' => 'yay'
  end

  it 'rejects nested data structures in custom_attributes' do
    contact = Intercom::Contact.new

    _(proc { contact.custom_attributes['thing'] = [1] }).must_raise(ArgumentError)
    _(proc { contact.custom_attributes['thing'] = { 1 => 2 } }).must_raise(ArgumentError)
    _(proc { contact.custom_attributes['thing'] = { 1 => { 2 => 3 } } }).must_raise(ArgumentError)

    contact = Intercom::Contact.new(test_contact)
    _(proc { contact.custom_attributes['thing'] = [1] }).must_raise(ArgumentError)
  end

  describe 'incrementing custom_attributes fields' do
    before :each do
      @now = Time.now
      @contact = Intercom::Contact.new('email' => 'jo@example.com', :external_id => 'i-1224242', :custom_attributes => { 'mad' => 123, 'another' => 432, 'other' => @now.to_i, :thing => 'yay' })
    end

    it 'increments up by 1 with no args' do
      @contact.increment('mad')
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 124
    end

    it 'increments up by given value' do
      @contact.increment('mad', 4)
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 127
    end

    it 'increments down by given value' do
      @contact.increment('mad', -1)
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 122
    end

    it 'can increment new custom data fields' do
      @contact.increment('new_field', 3)
      _(@contact.to_hash['custom_attributes']['new_field']).must_equal 3
    end

    it 'can call increment on the same key twice and increment by 2' do
      @contact.increment('mad')
      @contact.increment('mad')
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 125
    end
  end

  describe 'decrementing custom_attributes fields' do
    before :each do
      @now = Time.now
      @contact = Intercom::Contact.new('email' => 'jo@example.com', :external_id => 'i-1224242', :custom_attributes => { 'mad' => 123, 'another' => 432, 'other' => @now.to_i, :thing => 'yay' })
    end

    it 'decrements down by 1 with no args' do
      @contact.decrement('mad')
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 122
    end

    it 'decrements down by given value' do
      @contact.decrement('mad', 3)
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 120
    end

    it 'can decrement new custom data fields' do
      @contact.decrement('new_field', 5)
      _(@contact.to_hash['custom_attributes']['new_field']).must_equal(-5)
    end

    it 'can call decrement on the same key twice and decrement by 2' do
      @contact.decrement('mad')
      @contact.decrement('mad')
      _(@contact.to_hash['custom_attributes']['mad']).must_equal 121
    end
  end

  it 'saves a contact (always sends custom_attributes)' do
    contact = Intercom::Contact.new('email' => 'jo@example.com', :external_id => 'i-1224242')
    client.expects(:post).with('/contacts', 'email' => 'jo@example.com', 'external_id' => 'i-1224242', 'custom_attributes' => {}).returns('email' => 'jo@example.com', 'external_id' => 'i-1224242')
    client.contacts.save(contact)
  end

  it 'can save a contact with a nil email' do
    contact = Intercom::Contact.new('email' => nil, :external_id => 'i-1224242')
    client.expects(:post).with('/contacts', 'custom_attributes' => {}, 'email' => nil, 'external_id' => 'i-1224242').returns('email' => nil, 'external_id' => 'i-1224242')
    client.contacts.save(contact)
  end

  it 'can use client.contacts.create for convenience' do
    client.expects(:post).with('/contacts', 'custom_attributes' => {}, 'email' => 'jo@example.com', 'external_id' => 'i-1224242').returns('email' => 'jo@example.com', 'external_id' => 'i-1224242')
    contact = client.contacts.create('email' => 'jo@example.com', :external_id => 'i-1224242')
    _(contact.email).must_equal 'jo@example.com'
  end

  it 'updates the contact with attributes as set by the server' do
    client.expects(:post).with('/contacts', 'email' => 'jo@example.com', 'external_id' => 'i-1224242', 'custom_attributes' => {}).returns('email' => 'jo@example.com', 'external_id' => 'i-1224242', 'session_count' => 4)
    contact = client.contacts.create('email' => 'jo@example.com', :external_id => 'i-1224242')
    _(contact.session_count).must_equal 4
  end

  it 'allows setting dates to nil without converting them to 0' do
    client.expects(:post).with('/contacts', 'email' => 'jo@example.com', 'custom_attributes' => {}, 'remote_created_at' => nil).returns('email' => 'jo@example.com')
    contact = client.contacts.create('email' => 'jo@example.com', 'remote_created_at' => nil)
    assert_nil contact.remote_created_at
  end

  it 'sets/gets rw keys' do
    params = { 'email' => 'me@example.com', :external_id => 'abc123', 'name' => 'Bob Smith', 'last_seen_ip' => '1.2.3.4', 'last_seen_contact_agent' => 'ie6', 'created_at' => Time.now }
    contact = Intercom::Contact.new(params)
    custom_attributes = (params.keys + ['custom_attributes']).map(&:to_s).sort
    _(contact.to_hash.keys.sort).must_equal custom_attributes
    params.keys.each do |key|
      _(contact.send(key).to_s).must_equal params[key].to_s
    end
  end

  it 'will allow extra attributes in response from api' do
    contact = Intercom::Contact.send(:from_api, 'new_param' => 'some value')
    _(contact.new_param).must_equal 'some value'
  end

  it 'returns a BaseCollectionProxy for all without making any requests' do
    client.expects(:execute_request).never
    all = client.contacts.all
    _(all).must_be_instance_of(Intercom::BaseCollectionProxy)
  end

  it 'can print contacts without crashing' do
    client.expects(:get).with('/contacts', 'email' => 'bo@example.com').returns(test_contact)
    contact = client.contacts.find('email' => 'bo@example.com')

    begin
      orignal_stdout = $stdout
      $stdout = StringIO.new

      puts contact
      p contact
    ensure
      $stdout = orignal_stdout
    end
  end

  it 'fetches a contact' do
    client.expects(:get).with('/contacts', 'email' => 'bo@example.com').returns(test_contact)
    contact = client.contacts.find('email' => 'bo@example.com')
    _(contact.email).must_equal 'bob@example.com'
    _(contact.name).must_equal 'Joe Schmoe'
    _(contact.session_count).must_equal 123
  end

  it 'can update a contact with an id' do
    contact = Intercom::Contact.new(id: 'de45ae78gae1289cb')
    client.expects(:put).with('/contacts/de45ae78gae1289cb', 'custom_attributes' => {})
    client.contacts.save(contact)
  end

  it 'deletes a contact' do
    contact = Intercom::Contact.new('id' => '1')
    client.expects(:delete).with('/contacts/1', {}).returns(contact)
    client.contacts.delete(contact)
  end

  it 'archives a contact' do
    contact = Intercom::Contact.new('id' => '1')
    client.expects(:post).with('/contacts/1/archive', {})
    client.contacts.archive(contact)
  end

  it 'unarchives a contact' do
    contact = Intercom::Contact.new('id' => '1')
    client.expects(:post).with('/contacts/1/unarchive', {})
    client.contacts.unarchive(contact)
  end

  it 'deletes an archived contact' do
    contact = Intercom::Contact.new('id' => '1','archived' =>true)
    client.expects(:delete).with('/contacts/1', {})
    client.contacts.delete_archived_contact("1")
  end

  describe 'merging' do
    let(:lead) { Intercom::Contact.from_api(external_id: 'contact_id', role: 'lead') }
    let(:user) { Intercom::Contact.from_api(id: 'external_id', role: 'user') }

    it 'should be successful with a lead and user' do
      client.expects(:post).with('/contacts/merge',
                                 from: lead.id, into: user.id).returns(test_contact)

      client.contacts.merge(lead, user)
    end
  end

  describe 'nested resources' do
    let(:contact) { Intercom::Contact.new(id: '1', client: client) }
    let(:contact_no_tags) { Intercom::Contact.new(id: '2', client: client, tags: []) }
    let(:company) { Intercom::Company.new(id: '1') }
    let(:subscription) { Intercom::Subscription.new(id: '1', client: client) }
    let(:tag) { Intercom::Tag.new(id: '1') }
    let(:note) { Intercom::Note.new(body: "<p>Text for the note</p>") }

    it 'returns a collection proxy for listing notes' do
      proxy = contact.notes
      _(proxy.resource_name).must_equal 'notes'
      _(proxy.url).must_equal '/contacts/1/notes'
      _(proxy.resource_class).must_equal Intercom::Note
    end

    it 'returns a collection proxy for listing segments' do
      proxy = contact.segments
      _(proxy.resource_name).must_equal 'segments'
      _(proxy.url).must_equal '/contacts/1/segments'
      _(proxy.resource_class).must_equal Intercom::Segment
    end

    it 'returns a collection proxy for listing tags' do
      proxy = contact.tags
      _(proxy.resource_name).must_equal 'tags'
      _(proxy.url).must_equal '/contacts/1/tags'
      _(proxy.resource_class).must_equal Intercom::Tag
    end

    it 'returns correct tags from differring contacts' do
      client.expects(:get).with('/contacts/1/tags', {}).returns({
        'type' => 'tag.list',
        'tags' => [
          {
            'type' => 'tag',
            'id' => '1',
            'name' => 'VIP Customer'
          },
          {
            'type' => 'tag',
            'id' => '2',
            'name' => 'Test tag'
          }
        ]
      })

      _(contact_no_tags.tags.map{ |t| t.id }).must_equal []
      _(contact.tags.map{ |t| t.id }).must_equal ['1', '2']
    end

    it 'returns a collection proxy for listing companies' do
      proxy = contact.companies
      _(proxy.resource_name).must_equal 'companies'
      _(proxy.url).must_equal '/contacts/1/companies'
      _(proxy.resource_class).must_equal Intercom::Company
    end

    it 'adds a note to a contact' do
      client.expects(:post).with('/contacts/1/notes', {body: note.body}).returns(note.to_hash)
      contact.create_note({body: note.body})
    end

    it 'adds a tag to a contact' do
      client.expects(:post).with('/contacts/1/tags', "id": tag.id).returns(tag.to_hash)
      contact.add_tag({ "id": tag.id })
    end

    it 'removes a subscription to a contact' do
      client.expects(:delete).with("/contacts/1/subscription_types/#{subscription.id}", "id": subscription.id).returns(subscription.to_hash)
      contact.remove_subscription_type({ "id": subscription.id })
    end

    it 'removes a tag from a contact' do
      client.expects(:delete).with("/contacts/1/tags/#{tag.id}", "id": tag.id ).returns(tag.to_hash)
      contact.remove_tag({ "id": tag.id })
    end

    it 'adds a contact to a company' do
      client.expects(:post).with('/contacts/1/companies', "id": company.id).returns(test_company)
      contact.add_company({ "id": tag.id })
    end

    it 'removes a contact from a company' do
      client.expects(:delete).with("/contacts/1/companies/#{company.id}", "id": tag.id ).returns(test_company)
      contact.remove_company({ "id": tag.id })
    end

    describe 'just after creating the contact' do
      let(:contact) do
        contact = Intercom::Contact.new('email' => 'jo@example.com', :external_id => 'i-1224242')
        client.expects(:post).with('/contacts', 'email' => 'jo@example.com', 'external_id' => 'i-1224242', 'custom_attributes' => {})
                             .returns('id' => 1, 'email' => 'jo@example.com', 'external_id' => 'i-1224242')
        client.contacts.save(contact)
      end

      it 'returns a collection proxy for listing notes' do
        proxy = contact.notes
        _(proxy.resource_name).must_equal 'notes'
        _(proxy.url).must_equal '/contacts/1/notes'
        _(proxy.resource_class).must_equal Intercom::Note
      end

      it 'returns a collection proxy for listing tags' do
        proxy = contact.tags
        _(proxy.resource_name).must_equal 'tags'
        _(proxy.url).must_equal '/contacts/1/tags'
        _(proxy.resource_class).must_equal Intercom::Tag
      end

      it 'returns a collection proxy for listing companies' do
        proxy = contact.companies
        _(proxy.resource_name).must_equal 'companies'
        _(proxy.url).must_equal '/contacts/1/companies'
        _(proxy.resource_class).must_equal Intercom::Company
      end

      it 'adds a note to a contact' do
        client.expects(:post).with('/contacts/1/notes', {body: note.body}).returns(note.to_hash)
        contact.create_note({body: note.body})
      end

      it 'adds a subscription to a contact' do
        client.expects(:post).with('/contacts/1/subscription_types', "id": subscription.id).returns(subscription.to_hash)
        contact.create_subscription_type({ "id": subscription.id })
      end

      it 'adds a tag to a contact' do
        client.expects(:post).with('/contacts/1/tags', "id": tag.id).returns(tag.to_hash)
        contact.add_tag({ "id": tag.id })
      end

      it 'removes a tag from a contact' do
        client.expects(:delete).with("/contacts/1/tags/#{tag.id}", "id": tag.id ).returns(tag.to_hash)
        contact.remove_tag({ "id": tag.id })
      end

      it 'adds a contact to a company' do
        client.expects(:post).with('/contacts/1/companies', "id": company.id).returns(test_company)
        contact.add_company({ "id": tag.id })
      end

      it 'removes a contact from a company' do
        client.expects(:delete).with("/contacts/1/companies/#{company.id}", "id": tag.id ).returns(test_company)
        contact.remove_company({ "id": tag.id })
      end
    end
  end
end
