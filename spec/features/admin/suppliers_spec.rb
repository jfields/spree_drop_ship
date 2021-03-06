require 'spec_helper'

feature 'Admin - Suppliers', js: true do

  before do
    country = create(:country, name: "United States")
    create(:state, name: "Vermont", country: country)
    @supplier = create :supplier
  end

  context 'as an Admin' do

    before do
      login_user create(:admin_user)
      visit spree.admin_path
      within 'ul[data-hook=admin_tabs]' do
        click_link 'Suppliers'
      end
      page.should have_content('Listing Suppliers')
    end

    scenario 'should be able to create new supplier' do
      click_link 'New Supplier'
      check 'supplier_active'
      select '1970', from: 'supplier_contacts_date_of_birth_1i'
      select 'April', from: 'supplier_contacts_date_of_birth_2i'
      select '20', from: 'supplier_contacts_date_of_birth_3i'
      fill_in 'supplier[name]', with: 'Test Supplier'
      fill_in 'supplier[email]', with: 'spree@example.com'
      fill_in 'supplier[url]', with: 'http://www.test.com'
      fill_in 'supplier[commission_flat_rate]', with: '0'
      fill_in 'supplier[commission_percentage]', with: '0'
      fill_in 'supplier[address_attributes][firstname]', with: 'First'
      fill_in 'supplier[address_attributes][lastname]', with: 'Last'
      fill_in 'supplier[address_attributes][address1]', with: '1 Test Drive'
      fill_in 'supplier[address_attributes][city]', with: 'Test City'
      fill_in 'supplier[address_attributes][zipcode]', with: '55555'
      select2 'United States', from: 'Country:'
      select2 'Vermont', from: 'State:'
      fill_in 'supplier[address_attributes][phone]', with: '555-555-5555'
      click_button 'Create'
      page.should have_content('Supplier "Test Supplier" has been successfully created!')
    end

    scenario 'should be able to delete supplier' do
      click_icon 'trash'
      page.driver.browser.switch_to.alert.accept
      within 'table' do
        page.should_not have_content(@supplier.name)
      end
    end

    scenario 'should be able to edit supplier' do
      click_icon 'edit'
      check 'supplier_active'
      select '1970', from: 'supplier_contacts_date_of_birth_1i'
      select 'April', from: 'supplier_contacts_date_of_birth_2i'
      select '20', from: 'supplier_contacts_date_of_birth_3i'
      fill_in 'supplier[name]', with: 'Test Supplier'
      fill_in 'supplier[email]', with: 'spree@example.com'
      fill_in 'supplier[url]', with: 'http://www.test.com'
      fill_in 'supplier[commission_flat_rate]', with: '0'
      fill_in 'supplier[commission_percentage]', with: '0'
      fill_in 'supplier[address_attributes][firstname]', with: 'First'
      fill_in 'supplier[address_attributes][lastname]', with: 'Last'
      fill_in 'supplier[address_attributes][address1]', with: '1 Test Drive'
      fill_in 'supplier[address_attributes][city]', with: 'Test City'
      fill_in 'supplier[address_attributes][zipcode]', with: '55555'
      select2 'United States', from: 'Country:'
      select2 'Vermont', from: 'State:'
      fill_in 'supplier[address_attributes][phone]', with: '555-555-5555'
      page.should have_css('#s2id_supplier_user_ids') # can edit assigned users
      click_button 'Update'
      page.should have_content('Supplier "Test Supplier" has been successfully updated!')
    end

  end

  context 'as a Supplier' do

    before do
      @user = create(:supplier_user)
      login_user @user
      visit spree.account_path
      within 'dd.supplier-info' do
        click_link 'Edit'
      end
    end

    scenario 'should only see tabs they have access to' do
      within '#admin-menu' do
        page.should_not have_link('Overview')
        page.should have_link('Products')
        page.should_not have_link('Reports')
        page.should_not have_link('Configuration')
        page.should_not have_link('Promotions')
        page.should_not have_link('Suppliers')
        # Since we remove the normal orders tab and add dso tab the first shopping cart icon should contain it.
        within '.icon-truck' do
          page.should have_content('DROP SHIP ORDERS')
        end
      end
    end

    scenario 'should be able to update supplier' do
      select '1970', from: 'supplier_contacts_date_of_birth_1i'
      select 'April', from: 'supplier_contacts_date_of_birth_2i'
      select '20', from: 'supplier_contacts_date_of_birth_3i'
      fill_in 'supplier[name]', with: 'Test Supplier'
      fill_in 'supplier[email]', with: @user.email
      fill_in 'supplier[url]', with: 'http://www.test.com'
      fill_in 'supplier[address_attributes][firstname]', with: 'First'
      fill_in 'supplier[address_attributes][lastname]', with: 'Last'
      fill_in 'supplier[address_attributes][address1]', with: '1 Test Drive'
      fill_in 'supplier[address_attributes][city]', with: 'Test City'
      fill_in 'supplier[address_attributes][zipcode]', with: '55555'
      select2 'United States', from: 'Country'
      select2 'Vermont', from: 'State'
      fill_in 'supplier[address_attributes][phone]', with: '555-555-5555'
      page.should_not have_css('#supplier_active') # cannot edit active
      page.should_not have_css('#supplier_featured') # cannot edit featured
      page.should_not have_css('#s2id_supplier_user_ids') # cannot edit assigned users
      page.should_not have_css('#supplier_commission_flat_rate') # cannot edit flat rate commission
      page.should_not have_css('#supplier_commission_percentage') # cannot edit comission percentage
      click_button 'Update'
      page.should have_content('Supplier "Test Supplier" has been successfully updated!')
      page.current_path.should eql(spree.edit_admin_supplier_path(@user.reload.supplier))
    end

    scenario 'should display errors with invalid supplier update' do
      select '1970', from: 'supplier_contacts_date_of_birth_1i'
      select 'April', from: 'supplier_contacts_date_of_birth_2i'
      select '20', from: 'supplier_contacts_date_of_birth_3i'
      fill_in 'supplier[name]', with: 'Test Supplier'
      fill_in 'supplier[email]', with: @user.email
      fill_in 'supplier[url]', with: 'http://www.test.com'
      fill_in 'supplier[address_attributes][firstname]', with: ''
      fill_in 'supplier[address_attributes][lastname]', with: 'Last'
      fill_in 'supplier[address_attributes][address1]', with: '1 Test Drive'
      fill_in 'supplier[address_attributes][city]', with: 'Test City'
      fill_in 'supplier[address_attributes][zipcode]', with: '55555'
      select2 'United States', from: 'Country'
      select2 'Vermont', from: 'State'
      fill_in 'supplier[address_attributes][phone]', with: '555-555-5555'
      click_button 'Update'
      page.should have_content('Address is invalid')
      page.current_path.should eql(spree.admin_supplier_path(@user.reload.supplier))
    end

  end

  context 'as a User other than the suppliers' do

    scenario 'should be unauthorized' do
      supplier = create(:supplier)
      login_user create(:user)
      visit spree.edit_admin_supplier_path(supplier)
      page.should have_content('Unauthorized')
    end

  end

end
