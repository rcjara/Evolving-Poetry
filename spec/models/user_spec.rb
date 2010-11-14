require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :username => "Raul Jara",
      :email => "raul.c.jara@gmail.com",
      :password => "PASSwoRd",
      :password_confirmation => "PASSwoRd"
    }
  end

  it "should reject a duplicate email address" do
    User.create!(@attr)
    user = User.new(@attr)
    user.should_not be_valid
  end

  it "should create a new instance given valid elements" do
    User.create!(@attr)
  end

  it "should require a name" do
    user = User.create(@attr.merge({:username => "" }) )
    user.should_not be_valid
  end

  it "should reject a name that is too long" do
    long_name = "a" * 51
    user = User.create(@attr.merge({:username => long_name }) )
    user.should_not be_valid
  end

  it "should require an email" do
    user = User.create(@attr.merge({:email => " " }) )
    user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "Password Validations" do 
    it "should require a password" do
      u = User.new(@attr.merge({:password => "", :password_confirmation => ""}) )
      u.should_not be_valid
    end

    it "should require that the confirmation is the same as the password" do
      u = User.new(@attr.merge({:password_confirmation => "PASSWORD"}) )
      u.should_not be_valid
    end

    it "should reject passwords that are too short" do
      short_password = "a" * 2
      u = User.new(@attr.merge({:password => short_password, :password_confirmation => short_password}) )
      u.should_not be_valid
    end
  end

end

