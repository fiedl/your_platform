require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def test_should_create_test_user
    assert create_test_user
  end

  def test_should_require_a_first_and_a_last_name
    assert create_test_user( :first_name => "" ).invalid? :first_name
    assert create_test_user( :last_name => "" ).invalid? :last_name
  end

  def test_should_require_alias
    assert create_test_user( :alias => "" ).invalid? :alias
  end

  def test_should_reject_invalid_and_accept_valid_emails
    assert create_test_user( :email => "foo @example.com" ).invalid? :email
    assert create_test_user( :email => "foo at example.com" ).invalid? :email
    assert create_test_user( :email => "foo@192.168.0.100" ).invalid? :email
    assert create_test_user( :email => "foo@example.com" ).valid? :email
  end

  def test_alias_should_be_unique
    create_test_user( :alias => "der_selbe_alias" ) # erster Benutzer ok
    assert create_test_user( :alias => "der_selbe_alias" ).invalid? :alias # der zweite sollte fehlschlagen.
  end

  def test_should_capitalize_name
    assert create_test_user( :alias => "mr.capital", :first_name => "max", :last_name => "capital" ).name == "Max Capital"
  end

  def test_alias_should_be_recognized_as_taken
    assert Alias.new( "mustermann" ).taken? # den Benutzer gibt es schon im Fixture.
  end

  def test_should_generate_alias_correctly
    # Im Fixture existieren Max, Moritz und Stefan Mustermann.
    # Der Alias-Generator sollte also nicht "mustermann" und nicht "m.mustermann", sondern "max.mustermann" generieren.
    assert users( :max_mustermann ).alias.generate == "max.mustermann"
    assert users( :stefan_mustermann ).alias.generate == "s.mustermann"
    assert users( :tamara_musterfrau ).alias.generate == "musterfrau"
  end

  def test_should_generate_alias_object
    assert_not_nil Alias.new
    assert_not_nil Alias.new "test_alias"
  end

  def test_alias_generate_exclam_should_assign_new_alias_to_user
    u = User.first
    assert u.alias.generate! == u.alias.generate
  end

  protected

  def create_test_user( options = {} )
    preferences = { 
      :first_name  => "Holger",
      :last_name   => "Tester",
      :alias       => "tester" }.merge( options )
    User.create( preferences )
  end

end
