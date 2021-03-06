require 'test_helper'

class ConstituentTest < ActiveSupport::TestCase
  # Relationship matchers...
    should have_many(:addresses)
    should have_many(:donation_histories)
    should have_many(:donation_programs).through(:donation_histories)
    should have_many(:constituent_events)
    should have_many(:events).through(:constituent_events)
    should have_many(:contact_histories)
    should have_many(:constituent_membership_records)
    should have_many(:membership_records).through(:constituent_membership_records)

  # Validation matchers...
    should validate_presence_of(:lookup_id)
    should validate_presence_of(:last_group)
    should allow_value("(412)-218-4897").for(:phone)
    should_not allow_value("4122184897").for(:phone)
    should allow_value("gyao@andrew.cmu.edu").for(:email_id)
    should_not allow_value("something!`@some.con").for(:email_id)
    should allow_value(true).for(:do_not_email)
    should allow_value(false).for(:do_not_email)
    # TODO: Figure out why this works? I think any string coerces to boolean
    should_not allow_value("maybe").for(:do_not_email)
    should_not allow_value(nil).for(:do_not_email)
    should allow_value(5.years.ago.to_date).for(:dob)
    should_not allow_value(1.year.from_now.to_date).for(:dob)

    #TODO: add more validations in constituent, then add more tests
    # Specifically the last_group regex

  # ---------------------------------
  # Testing other methods with a context
  context "Creating a constituent context" do
    setup do
      create_constituents
       
      # create_addresses
      
    end

    # and provide a teardown method as well
    teardown do
      destroy_constituents

    end

    should "show that constituent record is created properly" do
      assert_equal "12345", @bruce.lookup_id
      assert_equal "Mr.", @bruce.title
      assert_equal "Bruce Wayne", @bruce.name
      assert_equal "Wayne", @bruce.last_group
      assert_equal "abc@mail.com", @bruce.email_id
      assert_equal "(123)-456-7890", @bruce.phone
      assert_equal 20.years.ago.to_date, @bruce.dob
      assert_equal false, @bruce.do_not_email
      assert_equal false, @bruce.duplicate
      assert_equal "Individual", @bruce.constituent_type
      assert_equal "Ask for batman", @bruce.phone_notes
    end

    # test the scope 'by_lookup_id'
    should "shows that ordering by lookup id works" do
      assert_equal 3, Constituent.all.size # quick check of size
      assert_equal ["10000", "12345", "12346"],
      Constituent.by_lookup_id.map{|p| p.lookup_id}
    end

    # test the scope 'alphabetical_last_group'
    should "shows that ordering by last_group works" do
      assert_equal ["PNC", "Wayne", "Yao Family"],
      Constituent.alphabetical_last_group.map{|p| p.last_group}
    end

    # test the scope 'alphabetical_name'
    should "shows that ordering by name works" do
      assert_equal ["Bruce Wayne","PNC", "Yao Family"],
      Constituent.alphabetical_name.map{|p| p.name}
    end

    # test the scope 'individual'
    should "shows that search for individual works" do
      assert_equal ["Bruce Wayne"], Constituent.individual.map{|p| p.name}
    end
    # test the scope 'household'
    should "shows that search for household works" do
      assert_equal ["Yao Family"], Constituent.household.map{|p| p.name}
    end

    # test the scope 'company'
    should "shows that search for company works" do
      assert_equal ["PNC"], Constituent.company.map{|p| p.name}
    end

    should "show the current address" do
      @add_bruce = FactoryBot.create(:address, lookup_id: @bruce.lookup_id,
      address_1: "5034 Forbes Avenue", city: "Pittsburgh",
      state: "Pennsylvania", zip: "15213", address_type: "Business",
      date_added: 2.months.ago.to_date)
      assert_equal "5034 Forbes Avenue", @bruce.current_address
      assert_equal nil, @yaoFam.current_address
      assert_equal nil, @pnc.current_address
       @add_bruce.destroy
    end

  end
end
