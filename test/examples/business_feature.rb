class BusinessFeature < TestKit::Feature
  scenario "adding a business" do
    @business_category = BusinessCategory.mock(:name => 'Bars & Restaurants')
    @user = log_in_as("user@example.com")
    @location = select_location("Cape Town")
    
    click "Add a business"
    fill_in_with_defaults(Business)
    choose_using_the_map "Milnerton, Cape Town"
    
    assert(
      not_visible?(
        "Researcher additional information",
        "Notes for administration purposes"
      ),
      "Regular users should not see researcher fields"
    )

    click "Preview Business"
    
    assert(
      visible?(
        "Your business has been created successfully",
        "About Sally's Diner",
        "Sally makes the best meal in town",
        "You are currently previewing your business page",
        template(:youtube_embed_code, :code => "oHg5SJYRHA0")
      )
    )
    
    click "Edit business"
    click "Edit profile"
    click "#update_business_button"
    
    assert(not_visible?("You are currently previewing your business page"))
  end
  
  private
  def choose_using_the_map(address) 
    fill_in 'Search for your business location' => address
    within "#add-your-business" do
      click "Search"
    end
    click 'Add this location'
  end
end
