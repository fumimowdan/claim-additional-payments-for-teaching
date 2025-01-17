require "rails_helper"

RSpec.feature "Trainee Teacher - Early Career Payments - journey" do
  context "when Claim AcademicYear is 2022/2023" do
    let(:ecp_only_school) { create(:school, :early_career_payments_eligible) }

    before { create(:policy_configuration, :additional_payments) }

    scenario "ECP-only school with trainee teacher" do
      visit landing_page_path(EarlyCareerPayments.routing_name)
      expect(page).to have_link(href: "mailto:#{EarlyCareerPayments.feedback_email}")

      # - Landing (start)
      expect(page).to have_text(I18n.t("early_career_payments.landing_page"))
      click_on "Start now"

      # - Which school do you teach at
      expect(page).to have_text(I18n.t("early_career_payments.questions.current_school_search"))

      choose_school ecp_only_school

      # - NQT in Academic Year after ITT
      expect(page).to have_text(I18n.t("early_career_payments.questions.nqt_in_academic_year_after_itt.heading"))

      choose "No, I’m a trainee teacher"
      click_on "Continue"

      expect(page).to have_text(I18n.t("early_career_payments.ineligible.heading"))
    end
  end
end
