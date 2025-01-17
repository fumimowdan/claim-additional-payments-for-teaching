require "rails_helper"

describe ApplicationHelper do
  describe "#currency_value_for_number_field" do
    let(:value) { 1000.1 }

    it "formats the number to two decimal places and is suitable for a number_field" do
      expect(helper.currency_value_for_number_field(value)).to eql("1000.10")
    end

    context "when no value exists" do
      let(:value) { nil }

      it "does no formatting and just returns nil" do
        expect(helper.currency_value_for_number_field(value)).to be_nil
      end
    end
  end

  describe "page_title" do
    it "returns a title for the page that follows the guidance of the design system" do
      expected_title = page_title("Title", policy: "student-loans")
      expect(expected_title).to eq("Title — Teachers: claim back your student loan repayments — GOV.UK")

      expected_title = page_title("Title", policy: "maths-and-physics")
      expect(expected_title).to eq("Title — Claim a payment for teaching maths or physics — GOV.UK")
    end

    it "uses the generic service name if a specific policy isn't available" do
      expect(page_title("Some Title", policy: nil)).to eq("Some Title — Claim additional payments for teaching — GOV.UK")
    end

    it "includes an optional error prefix" do
      expected_title = page_title("Some Title", show_error: true, policy: "student-loans")
      expect(expected_title).to eq("Error — Some Title — Teachers: claim back your student loan repayments — GOV.UK")
    end
  end

  describe "#support_email_address" do
    it "defaults to the generic support address" do
      expect(support_email_address).to eq t("support_email_address")
    end

    it "returns a policy-specific email address based on routing path" do
      expect(support_email_address("student-loans")).to eq t("student_loans.support_email_address")
      expect(support_email_address("maths-and-physics")).to eq t("maths_and_physics.support_email_address")
      expect(support_email_address("additional-payments")).to eq t("early_career_payments.support_email_address")
    end
  end

  describe "#support_email_address_for_selected_claim_policy" do
    it "returns a ECP specific email if the session contains selected ECP claim" do
      session[:selected_claim_policy] = "EarlyCareerPayments"
      expect(support_email_address_for_selected_claim_policy).to eq t("early_career_payments.support_email_address")
    end

    it "returns a LUP specific email if the session contains selected LUP claim" do
      session[:selected_claim_policy] = "LevellingUpPremiumPayments"
      expect(support_email_address_for_selected_claim_policy).to eq t("levelling_up_premium_payments.support_email_address")
    end
  end

  describe "#policy_service_name" do
    it "defaults to the generic service name" do
      expect(policy_service_name).to eq t("service_name")
    end

    it "returns a policy-specific service name for student loans" do
      expect(policy_service_name("student-loans")).to eq t("student_loans.policy_name")
    end

    it "returns a policy-specific service name for maths and physics" do
      expect(policy_service_name("maths-and-physics")).to eq t("maths_and_physics.policy_name")
    end

    it "returns a policy-specific service name for additional payments" do
      expect(policy_service_name("additional-payments")).to eq t("early_career_payments.policy_name")
    end
  end

  describe "#policy_description" do
    it "returns description for student loans" do
      expect(policy_description("student-loans")).to eq t("student_loans.claim_description")
    end

    it "returns description for student loans" do
      expect(policy_description("maths-and-physics")).to eq t("maths_and_physics.claim_description")
    end

    it "returns description for student loans" do
      expect(policy_description("additional-payments")).to eq t("early_career_payments.claim_description")
    end
  end
end
