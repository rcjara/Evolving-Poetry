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

  it "should reject a name with the '@' symbol in it" do
    user = User.create(@attr.merge({:username => "funny@thing"}) )
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

  describe "a user's points" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should be zero" do
      @user.total_points.should == 0
      @user.points_used.should == 0
    end

    it "should not be able to spend a point" do
      @user.spend_point!.should == false
    end


    describe "after being awarded a point" do
      before(:each) do
        @user.award_point!
      end

      it "should be at one total_point" do
        @user.total_points.should == 1
      end

      it "should be at zero used points" do
        @user.points_used.should == 0
      end

      it "should be at one available point" do
        @user.available_points.should == 1
      end

      it "should be able to spend a point" do
        @user.spend_point!.should == true
      end

      it "should not be able to spend two points" do
        @user.spend_points!(2).should == false
      end



      describe "after spending a point" do
        before(:each) do
          @user.spend_point!
        end

        it "should still have one total_points" do
          @user.total_points.should == 1
        end

        it "should have one point_used" do
          @user.points_used.should == 1
        end

        it "should have no available points" do
          @user.available_points.should == 0
        end

      end

      describe "after being awarded many points" do
        before(:each) do
          9.times { @user.award_point! }
        end

        it "should have the right number of available points" do
          @user.available_points.should == 10
        end

      end

    end

  end

end

