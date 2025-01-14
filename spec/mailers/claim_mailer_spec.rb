require "rails_helper"

RSpec.describe ClaimMailer, type: :mailer do
  shared_examples "an email related to a claim using the generic template" do |policy|
    let(:claim_description) { I18n.t("#{policy.locale_key}.claim_description") }

    it "sets the to address to the claimant's email address" do
      expect(mail.to).to eq([claim.email_address])
    end

    it "sets the GOV.UK Notify reply_to_id according to the policy" do
      expect(mail["reply_to_id"].value).to eql(policy.notify_reply_to_id)
    end

    it "mentions the type of claim in the subject and body" do
      expect(mail.subject).to include(claim_description)
      expect(mail.body.encoded).to include(claim_description)
    end

    it "includes the claim reference in the subject and body" do
      expect(mail.subject).to include("reference number: #{claim.reference}")
      expect(mail.body.encoded).to include(claim.reference)
    end

    it "greets the claimant in the body" do
      expect(mail.body.encoded).to start_with("Dear #{claim.first_name} #{claim.surname},")
    end
  end

  shared_examples "an email related to a claim using GOVUK Notify templates" do |policy|
    let(:claim_description) { I18n.t("#{policy.locale_key}.claim_description") }

    it "sets the to address to the claimant's email address" do
      expect(mail.to).to eq([claim.email_address])
    end

    it "sets the GOV.UK Notify reply_to_id according to the policy" do
      expect(mail["reply_to_id"].value).to eql(policy.notify_reply_to_id)
    end

    it "includes a personalisation key for claim reference (ref_number)" do
      expect(mail[:personalisation].decoded).to include("ref_number")
      expect(mail[:personalisation].decoded).to include(claim.reference)
    end

    it "includes a personalisation key for 'first_name'" do
      expect(mail[:personalisation].decoded).to include("{:first_name=>\"Jo\"")
      expect(mail.body.encoded).to be_empty
    end

    it "includes a personalisation key for 'support_email_address'" do
      support_email_address = I18n.t("#{claim.policy.locale_key}.support_email_address")
      expect(mail[:personalisation].decoded).to include(":support_email_address=>\"#{support_email_address}\"")
    end
  end

  # Characteristics common to all policies
  [EarlyCareerPayments, StudentLoans, LevellingUpPremiumPayments].each do |policy|
    context "with a #{policy} claim" do
      let!(:policy_configuration) { create(:policy_configuration, policy.to_s.underscore) }

      describe "#submitted" do
        let(:claim) { build(:claim, :submitted, policy: policy) }
        let(:mail) { ClaimMailer.submitted(claim) }

        it_behaves_like "an email related to a claim using GOVUK Notify templates", policy

        context "when EarlyCareerPayments", if: policy == EarlyCareerPayments do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "cb319af7-a769-42e4-8f01-5cbb9fc24846"
          end
        end

        context "when LevellingUpPremiumPayments", if: policy == LevellingUpPremiumPayments do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "0158e1c4-ffa2-4b5e-86f9-0dead4e68587"
          end
        end

        context "when StudentLoans", if: policy == StudentLoans do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "f9e39fcd-301a-4427-9159-6831fd484e39"
          end
        end
      end

      describe "#approved" do
        let(:claim) { build(:claim, :approved, policy: policy) }
        let(:mail) { ClaimMailer.approved(claim) }

        it_behaves_like "an email related to a claim using GOVUK Notify templates", policy

        context "when EarlyCareerPayments", if: policy == EarlyCareerPayments do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "3974db1c-c7dd-44cf-97b9-bb96d211a996"
          end
        end

        context "when LevellingUpPremiumPayments", if: policy == LevellingUpPremiumPayments do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "78e4bf4a-5d4b-4328-9384-116c08183a77"
          end
        end

        context "when StudentLoans", if: policy == StudentLoans do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "2032be01-6aee-4a1a-81ce-cf91e09de8d7"
          end
        end
      end

      describe "#rejected" do
        let(:claim) { build(:claim, :rejected, policy: policy) }
        let(:mail) { ClaimMailer.rejected(claim) }

        it_behaves_like "an email related to a claim using GOVUK Notify templates", policy

        shared_examples "template id and personalisation keys" do
          let(:expected_common_keys) do
            {
              first_name: claim.first_name,
              ref_number: claim.reference,
              support_email_address: I18n.t("#{claim.policy.locale_key}.support_email_address"),
              current_financial_year: (policy == StudentLoans) ? StudentLoans.current_financial_year : ""
            }
          end
          let(:expected_rejected_reasons_keys) do
            {
              reason_ineligible_subject: "yes",
              reason_ineligible_year: "no",
              reason_ineligible_school: "no",
              reason_ineligible_qualification: "no",
              reason_induction: "no",
              reason_no_qts_or_qtls: "no",
              reason_duplicate: "no",
              reason_no_response: "no",
              reason_other: "no"
            }
          end
          let(:all_expected_keys) { expected_common_keys.merge(expected_rejected_reasons_keys) }

          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq(expected_template_id)
          end

          it "passes common fields as personalisation keys" do
            expect(mail[:personalisation].unparsed_value).to include(expected_common_keys)
          end

          it "passes rejected reasons as personalisation keys" do
            expect(mail[:personalisation].unparsed_value).to include(expected_rejected_reasons_keys)
          end

          it "does not pass any other personalisation keys" do
            expect(mail[:personalisation].unparsed_value).to match(all_expected_keys)
          end
        end

        context "when EarlyCareerPayments", if: policy == EarlyCareerPayments do
          let(:expected_template_id) { "b78ffea4-a3d7-4c4a-b0f7-066744c6e79f" }

          include_examples "template id and personalisation keys"
        end

        context "when LevellingUpPremiumPayments", if: policy == LevellingUpPremiumPayments do
          let(:expected_template_id) { "c20e8d85-ef71-4395-8f8b-90fcbd824b86" }

          include_examples "template id and personalisation keys"
        end

        context "when StudentLoans", if: policy == StudentLoans do
          let(:expected_template_id) { "f719237d-6b2a-42d6-98f2-3d5b6585f32b" }

          include_examples "template id and personalisation keys"
        end
      end

      describe "#update_after_three_weeks" do
        let(:claim) { build(:claim, :submitted, policy: policy) }
        let(:mail) { ClaimMailer.update_after_three_weeks(claim) }

        it_behaves_like "an email related to a claim using GOVUK Notify templates", policy

        context "when EarlyCareerPayments", if: policy == EarlyCareerPayments do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "0ef1e702-ea64-43a5-a084-330f2f51836e"
          end
        end

        context "when LevellingUpPremiumPayments", if: policy == LevellingUpPremiumPayments do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "a10322ed-7829-44b2-95c6-d5cc686d2c04"
          end
        end

        context "when StudentLoans", if: policy == StudentLoans do
          it "uses the correct template" do
            expect(mail[:template_id].decoded).to eq "c43bac94-67ff-4440-8f26-506eb4c232e8"
          end
        end
      end
    end
  end

  [MathsAndPhysics].each do |policy|
    context "with a #{policy} claim" do
      let!(:policy_configuration) { create(:policy_configuration, policy.to_s.underscore) }

      describe "#submitted" do
        let(:claim) { build(:claim, :submitted, policy: policy) }
        let(:mail) { ClaimMailer.submitted(claim) }

        it_behaves_like "an email related to a claim using the generic template", policy

        it "mentions that claim has been received in the subject and body" do
          expect(mail.subject).to include("been received")
          expect(mail.body.encoded).to include("We've received your application")
        end
      end

      describe "#approved" do
        let(:claim) { build(:claim, :approved, policy: policy) }
        let(:mail) { ClaimMailer.approved(claim) }

        it_behaves_like "an email related to a claim using the generic template", policy

        it "mentions that claim has been approved in the subject and body" do
          expect(mail.subject).to include("approved")
          expect(mail.body.encoded).to include("been approved")
        end
      end

      describe "#rejected" do
        let(:claim) { build(:claim, :submitted, policy: policy) }
        let(:mail) { ClaimMailer.rejected(claim) }

        it_behaves_like "an email related to a claim using the generic template", policy

        it "mentions that claim has been rejected in the subject and body" do
          expect(mail.subject).to include("rejected")
          expect(mail.body.encoded).to include("not been able to approve")

          expect(mail.body.encoded)
            .to include("We have not been able to approve your application")
        end

        context "with future academic year" do
          let(:current_year) { AcademicYear.current }
          let!(:policy_configuration) { create(:policy_configuration, policy.to_s.underscore, current_academic_year: current_year + 4) }

          it "changes the ITT reason based on the policy's configured current_academic_year" do
            expect(mail.body.encoded)
              .to include("We have not been able to approve your application")
          end
        end
      end

      describe "#update_after_three_weeks" do
        let(:claim) { build(:claim, :submitted, policy: policy) }
        let(:mail) { ClaimMailer.update_after_three_weeks(claim) }

        it_behaves_like "an email related to a claim using the generic template", policy

        it "mentions that the claim is still being reviewed in the subject and body" do
          expect(mail.subject).to include("still reviewing your application")
          expect(mail.body.encoded).to include("We're still reviewing your application")
        end
      end
    end
  end

  describe "#email_verification" do
    let(:mail) { ClaimMailer.email_verification(claim, one_time_password) }
    let(:one_time_password) { 123124 }
    let(:claim) { build(:claim, policy: policy, first_name: "Ellie") }

    before { create(:policy_configuration, policy.to_s.underscore) }

    context "with an EarlyCareerPayments claim" do
      let(:policy) { EarlyCareerPayments }

      it "has personalisation keys for: one time password, validity_duration,first_name and support_email_address" do
        expect(mail[:personalisation].decoded).to eq("{:email_subject=>\"Early-career payment email verification\", :first_name=>\"Ellie\", :one_time_password=>123124, :support_email_address=>\"earlycareerteacherpayments@digital.education.gov.uk\", :validity_duration=>\"15 minutes\"}")
        expect(mail.body.encoded).to be_empty
      end
    end

    context "with an LevellingUpPremiumPayments claim" do
      let(:policy) { LevellingUpPremiumPayments }

      it "has personalisation keys for: one time password, validity_duration,first_name and support_email_address" do
        expect(mail[:personalisation].decoded).to eq("{:email_subject=>\"Levelling up premium payment email verification\", :first_name=>\"Ellie\", :one_time_password=>123124, :support_email_address=>\"levellinguppremiumpayments@digital.education.gov.uk\", :validity_duration=>\"15 minutes\"}")
        expect(mail.body.encoded).to be_empty
      end
    end
  end
end
