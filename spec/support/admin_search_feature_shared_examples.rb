RSpec.shared_examples "Admin Search Feature" do |policy|
  before do
    create(:policy_configuration, policy.to_s.underscore)
    sign_in_as_service_operator
  end

  let!(:claim1) { create(:claim, :submitted, surname: "Wayne", policy: policy) }
  let!(:claim2) { create(:claim, :submitted, surname: "Wayne", policy: policy) }
  let!(:unsubmitted_claim) { create(:claim, surname: "Smith", policy: policy) }

  scenario "redirects a service operator to the claim if there is only one match" do
    visit search_admin_claims_path

    fill_in :reference, with: claim1.reference
    click_button "Search"

    expect(page).to have_content(claim1.reference)
    expect(page).to have_no_content(claim2.reference)

    expect(page).to have_content(claim1.teacher_reference_number)
    expect(page).to have_content(policy.short_name)
  end

  scenario "it lists claims if there is more than one match" do
    visit search_admin_claims_path

    fill_in :reference, with: "wayne"
    click_button "Search"

    expect(page).to have_content(claim1.reference)
    expect(page).to have_content(claim2.reference)

    find("a[href='#{admin_claim_tasks_path(claim1)}']").click

    expect(page).to have_content(claim1.reference)
    expect(page).to have_no_content(claim2.reference)
    expect(page).to have_content(claim1.teacher_reference_number)
    expect(page).to have_content(policy.short_name)
  end

  scenario "unsubmitted claims filtered from search results" do
    visit search_admin_claims_path

    fill_in :reference, with: "Smith"
    click_button "Search"

    expect(page).to have_content("Cannot find a claim for query \"Smith\"")
  end
end
