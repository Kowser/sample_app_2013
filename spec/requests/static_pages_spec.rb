require 'spec_helper'

describe "StaticPages" do

  let(:base_title) { "Ruby on Rails Tutorial Sample App" }
  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }
  end

  describe "for signed-in users with one micropost" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
      sign_in user
      visit root_path
    end

    it "should render the user's feed" do
      user.feed.each do |item|
        expect(page).to have_selector("li##{item.id}", text: item.content)
      end
    end

    describe "follower/following counts" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        other_user.follow!(user)
        visit root_path
      end

      it { should have_link("0 following", href: following_user_path(user)) }
      it { should have_link("1 followers", href: followers_user_path(user)) }
    end
    
    it "should render the user's micropost count" do
      expect(page).to have_content("1 micropost")
    end

    subject { page }
    it { should_not have_selector('div.pagination') }
  end

  describe "for signed-in users with multiple microposts" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      31.times { FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum") }
      sign_in user
      visit root_path
    end


    it "should render the correct pluralization of 'micropost'" do
      expect(page).to have_content("31 microposts")
    end

    subject { page }
    it { should have_selector('div.pagination') }
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_content('Help') }
    it { should have_title("#{base_title} | Help") } 
  end

  describe "About page" do
    before { visit about_path }

    it { should have_content('About Us') }
    it { should have_title("#{base_title} | About Us") }
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_content('Contact') }
    it { should have_title("#{base_title} | Contact") }
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end
end
