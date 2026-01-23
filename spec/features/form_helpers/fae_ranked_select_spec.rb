require 'spec_helper'

feature 'fae_ranked_select' do

  before(:each) do
    admin_login
    @aroma1 = FactoryBot.create(:aroma, name: 'Citrus')
    @aroma2 = FactoryBot.create(:aroma, name: 'Floral')
    @aroma3 = FactoryBot.create(:aroma, name: 'Hoppy')
    @beer = FactoryBot.create(:beer, name: 'Test IPA')
  end

  scenario 'should display ranking table with title', js: true do
    visit edit_admin_beer_path(@beer)

    # h2 titles are uppercased via CSS
    expect(page).to have_selector('h2', text: 'Aroma Ranking', visible: :all)
    expect(page).to have_content('Drag to reorder aromas by prominence')
  end

  scenario 'should show empty message when no items selected', js: true do
    visit edit_admin_beer_path(@beer)

    within('.js-ranking-table') do
      expect(page).to have_content('No items selected')
    end
  end

  scenario 'adding items to select should add them to the ranking table', js: true do
    visit edit_admin_beer_path(@beer)

    # Initially empty
    within('.js-ranking-table') do
      expect(page).to have_content('No items selected')
    end

    # Select an aroma using Chosen multi-select
    # Click on the search input within the chosen container to open dropdown
    chosen_container = find('.js-ranked-select-container .chosen-container')
    chosen_container.find('.search-field input').click
    
    # Click the option in the dropdown
    chosen_container.find('.chosen-results .active-result', text: 'Citrus').click

    # Wait for AJAX and verify it appears in ranking table
    eventually {
      within('.js-ranking-table') do
        expect(page).to_not have_selector('.js-ranking-empty-row', visible: true)
        expect(page).to have_content('Citrus')
      end
    }

    # Add another aroma
    chosen_container.find('.search-field input').click
    chosen_container.find('.chosen-results .active-result', text: 'Floral').click

    eventually {
      within('.js-ranking-table') do
        expect(page).to have_content('Citrus')
        expect(page).to have_content('Floral')
      end
    }
  end

  scenario 'removing items from select should remove them from the ranking table', js: true do
    # Create a beer with existing aromas
    BeerAroma.create!(beer: @beer, aroma: @aroma1, position: 1)
    BeerAroma.create!(beer: @beer, aroma: @aroma2, position: 2)

    visit edit_admin_beer_path(@beer)

    within('.js-ranking-table') do
      expect(page).to have_content('Citrus')
      expect(page).to have_content('Floral')
    end

    # In Chosen multi-select, selected items appear as "choices" with an X to remove
    # Find the choice for Citrus and click its remove button
    within('.js-ranked-select-container .chosen-container') do
      choice = find('.search-choice', text: 'Citrus')
      choice.find('.search-choice-close').click
    end

    eventually {
      within('.js-ranking-table') do
        expect(page).to_not have_content('Citrus')
        expect(page).to have_content('Floral')
      end
    }
  end

  scenario 'reordering items in ranking table should persist after save', js: true do
    # Create a beer with existing aromas in specific order
    BeerAroma.create!(beer: @beer, aroma: @aroma1, position: 1)
    BeerAroma.create!(beer: @beer, aroma: @aroma2, position: 2)
    BeerAroma.create!(beer: @beer, aroma: @aroma3, position: 3)

    visit edit_admin_beer_path(@beer)

    # Verify initial order in ranking table
    within('.js-ranking-table tbody') do
      rows = all('.js-ranking-row')
      expect(rows[0]).to have_content('Citrus')
      expect(rows[1]).to have_content('Floral')
      expect(rows[2]).to have_content('Hoppy')
    end

    # Drag the third item to the first position
    handle = find('.js-ranking-table tbody .js-ranking-row:last-child .sortable-handle .icon-sort')
    target = find('.js-ranking-table tbody .js-ranking-row:first-child .sortable-handle .icon-sort')
    handle.drag_to(target)

    # Wait for AJAX sort to complete
    sleep 0.5

    # Save the form
    click_button 'Save'

    # Return to the form and verify order persisted
    visit edit_admin_beer_path(@beer)

    eventually {
      within('.js-ranking-table tbody') do
        rows = all('.js-ranking-row')
        expect(rows[0]).to have_content('Hoppy')
        expect(rows[1]).to have_content('Citrus')
        expect(rows[2]).to have_content('Floral')
      end
    }

    # Also verify items are still selected in the select menu (shown as choices)
    within('.js-ranked-select-container .chosen-container') do
      expect(page).to have_selector('.search-choice', text: 'Citrus')
      expect(page).to have_selector('.search-choice', text: 'Floral')
      expect(page).to have_selector('.search-choice', text: 'Hoppy')
    end
  end

  scenario 'adding items, saving form, and returning should preserve selections', js: true do
    visit edit_admin_beer_path(@beer)

    # Add aromas using Chosen
    chosen_container = find('.js-ranked-select-container .chosen-container')
    chosen_container.find('.search-field input').click
    chosen_container.find('.chosen-results .active-result', text: 'Citrus').click

    eventually {
      within('.js-ranking-table') do
        expect(page).to have_content('Citrus')
      end
    }

    chosen_container.find('.search-field input').click
    chosen_container.find('.chosen-results .active-result', text: 'Hoppy').click

    eventually {
      within('.js-ranking-table') do
        expect(page).to have_content('Hoppy')
      end
    }

    # Save the form
    click_button 'Save'

    # Wait for save to complete and redirect
    expect(page).to have_content('Saved!')

    # Navigate back to the edit form
    visit edit_admin_beer_path(@beer)

    # Wait for page to load
    expect(page).to have_selector('.js-ranking-table')

    # Verify selections are preserved
    within('.js-ranking-table tbody') do
      expect(page).to have_content('Citrus')
      expect(page).to have_content('Hoppy')
      expect(page).to_not have_selector('.js-ranking-empty-row', visible: true)
    end

    # Check Chosen selections (shown as choices)
    within('.js-ranked-select-container .chosen-container') do
      expect(page).to have_selector('.search-choice', text: 'Citrus')
      expect(page).to have_selector('.search-choice', text: 'Hoppy')
    end
  end

  scenario 'empty row should hide after adding first item', js: true do
    visit edit_admin_beer_path(@beer)

    # Verify empty row is visible
    expect(page).to have_selector('.js-ranking-empty-row', visible: true)

    # Add first item using Chosen
    chosen_container = find('.js-ranked-select-container .chosen-container')
    chosen_container.find('.search-field input').click
    chosen_container.find('.chosen-results .active-result', text: 'Citrus').click

    # Verify empty row is now hidden
    eventually {
      expect(page).to_not have_selector('.js-ranking-empty-row', visible: true)
    }
  end

end
