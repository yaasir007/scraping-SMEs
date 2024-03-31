require 'open-uri'
require 'nokogiri'
require 'json'
require 'csv'

data_store_path = 'data.csv'
url = 'https://smesdb.govmu.org/smesdb/index.php/directory-smes_e_direc'
smes_links_array = []
all_data = []

sme_file = URI.open(url).read
sme_main_page = Nokogiri::HTML.parse(sme_file)

puts 'Starting to scrape the SME Directory'

sme_main_page.search('.entry-content .elementor .elementor-section .elementor-container .elementor-element-populated .elementor-widget-shortcode .elementor-widget-container .elementor-shortcode .drts-view-shortcode .drts-view-entities-container .drts-view-post-entities  .drts-view-entities-list-grid .drts-row .drts-view-entity-container .drts-entity-post .drts-display-element a').each do |element|
  sme_link = element.attribute('href').value
  smes_links_array << sme_link
end

CSV.open(data_store_path, 'wb') do |csv|
  csv << ['Number', 'Company Name', 'Other Name', 'Tel No', 'Mobile No', 'Email Address', 'Business Address 1', 'Product Details', 'Categories', 'District']
end

smes_links_array.each do |link|
  single_sme_file = URI.open(link).read
  single_sme_page = Nokogiri::HTML.parse(single_sme_file)

  single_sme_page.search('.drts-row').each do |sme_data|
    index = 0
    puts 'Starting with the scraping'

    company_name = sme_data.search('.drts-display-element-entity_field_field_company_name-1 .drts-entity-field-value').text
    other_name = sme_data.search('.drts-display-element-entity_field_field_other_name-1 .drts-entity-field-value').text
    tel_number = sme_data.search('.drts-display-element-entity_field_field_tel_no-1 .drts-entity-field-value').text
    mobile_number = sme_data.search('.drts-display-element-entity_field_field_mobile_no-1 .drts-entity-field-value').text
    email_add = sme_data.search('.drts-display-element-entity_field_field_email_address-1 .drts-entity-field-value').text
    business_add = sme_data.search('.drts-display-element-entity_field_field_business_address_1-1 .drts-entity-field-value').text
    product_details = sme_data.search('.drts-display-element-entity_field_field_product_details-1 .drts-entity-field-value').text
    business_category = sme_data.search('.drts-display-element-entity_field_field_categories-1 .drts-entity-field-value').text
    district_name = sme_data.search('.drts-display-element-entity_field_field_district-1 .drts-entity-field-value').text

    all_data << [index += 1, company_name, other_name, tel_number, mobile_number, email_add, business_add, product_details, business_category, district_name]
    puts "Finished with number #{index}"
  end
end

puts all_data

CSV.open(data_store_path, 'wb') do |csv|
  csv << all_data
end
