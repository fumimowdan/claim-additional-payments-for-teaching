module EarlyCareerPayments
  class Eligibility < ApplicationRecord
    AwardAmount = Struct.new(
      :itt_subject,
      :itt_academic_year,
      :claim_academic_year,
      :base_amount,
      :uplift_amount,
      keyword_init: true
    )

    AWARD_AMOUNTS = [
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2018),
        claim_academic_year: AcademicYear.new(2021),
        base_amount: 5_000,
        uplift_amount: 7_500
      ),
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2019),
        claim_academic_year: AcademicYear.new(2022),
        base_amount: 5_000,
        uplift_amount: 7_500
      ),
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2022),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :physics,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2022),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :chemistry,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2022),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :foreign_languages,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2022),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2018),
        claim_academic_year: AcademicYear.new(2023),
        base_amount: 5_000,
        uplift_amount: 7_500
      ),
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2023),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :physics,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2023),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :chemistry,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2023),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :foreign_languages,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2023),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2019),
        claim_academic_year: AcademicYear.new(2024),
        base_amount: 5_000,
        uplift_amount: 7_500
      ),
      AwardAmount.new(
        itt_subject: :mathematics,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2024),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :physics,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2024),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :chemistry,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2024),
        base_amount: 2_000,
        uplift_amount: 3_000
      ),
      AwardAmount.new(
        itt_subject: :foreign_languages,
        itt_academic_year: AcademicYear.new(2020),
        claim_academic_year: AcademicYear.new(2024),
        base_amount: 2_000,
        uplift_amount: 3_000
      )
    ].freeze
    EDITABLE_ATTRIBUTES = [
      :nqt_in_academic_year_after_itt,
      :current_school_id,
      :employed_as_supply_teacher,
      :has_entire_term_contract,
      :employed_directly,
      :subject_to_formal_performance_action,
      :subject_to_disciplinary_action,
      :qualification,
      :eligible_itt_subject,
      :teaching_subject_now,
      :itt_academic_year
    ].freeze
    AMENDABLE_ATTRIBUTES = [:award_amount].freeze
    ATTRIBUTE_DEPENDENCIES = {
      "employed_as_supply_teacher" => ["has_entire_term_contract", "employed_directly"],
      "qualification" => ["eligible_itt_subject", "teaching_subject_now"],
      "eligible_itt_subject" => ["teaching_subject_now"],
      "itt_academic_year" => ["eligible_itt_subject"]
    }.freeze

    IGNORED_ATTRIBUTES = [
      "eligible_degree_subject"
    ]

    self.table_name = "early_career_payments_eligibilities"

    enum qualification: {
      postgraduate_itt: 0,
      undergraduate_itt: 1,
      assessment_only: 2,
      overseas_recognition: 3
    }

    enum eligible_itt_subject: {
      chemistry: 0,
      foreign_languages: 1,
      mathematics: 2,
      physics: 3,
      none_of_the_above: 4,
      computing: 5
    }, _prefix: :itt_subject

    enum itt_academic_year: {
      AcademicYear.new(2017) => AcademicYear::Type.new.serialize(AcademicYear.new(2017)),
      AcademicYear.new(2018) => AcademicYear::Type.new.serialize(AcademicYear.new(2018)),
      AcademicYear.new(2019) => AcademicYear::Type.new.serialize(AcademicYear.new(2019)),
      AcademicYear.new(2020) => AcademicYear::Type.new.serialize(AcademicYear.new(2020)),
      AcademicYear.new(2021) => AcademicYear::Type.new.serialize(AcademicYear.new(2021)),
      AcademicYear.new => AcademicYear::Type.new.serialize(AcademicYear.new)
    }

    @@max_award_amount_in_pounds = AWARD_AMOUNTS.collect(&:uplift_amount).max

    def self.max_award_amount_in_pounds
      @@max_award_amount_in_pounds
    end

    has_one :claim, as: :eligibility, inverse_of: :eligibility
    belongs_to :current_school, optional: true, class_name: "School"

    validates :nqt_in_academic_year_after_itt, on: [:"nqt-in-academic-year-after-itt", :submit], inclusion: {in: [true, false], message: "Select an option to continue"}
    validates :current_school, on: [:"current-school", :submit], presence: {message: "Select a school from the list or search again for a different school"}
    validates :employed_as_supply_teacher, on: [:"supply-teacher", :submit], inclusion: {in: [true, false], message: "Select yes if you are currently employed as a supply teacher"}
    validates :has_entire_term_contract, on: [:"entire-term-contract", :submit], inclusion: {in: [true, false], message: "Select yes if you have a contract to teach at the same school for one term or longer"}, if: :employed_as_supply_teacher?
    validates :employed_directly, on: [:"employed-directly", :submit], inclusion: {in: [true, false], message: "Select yes if you are employed directly by your school"}, if: :employed_as_supply_teacher?
    validates :subject_to_formal_performance_action, on: [:"poor-performance", :submit], inclusion: {in: [true, false], message: "Select yes if you are subject to formal action for poor performance at work"}
    validates :subject_to_disciplinary_action, on: [:"poor-performance", :submit], inclusion: {in: [true, false], message: "Select yes if you are subject to disciplinary action"}
    validates :qualification, on: [:qualification, :submit], presence: {message: "Select the route you took in to teaching"}
    validates :eligible_itt_subject, on: [:"eligible-itt-subject", :submit], presence: {message: ->(object, data) { I18n.t("activerecord.errors.models.early_career_payments_eligibilities.attributes.eligible_itt_subject.blank.qualification.#{object.qualification}") }}
    validates :teaching_subject_now, on: [:"teaching-subject-now", :submit], inclusion: {in: [true, false], message: "Select yes if you currently spend at least half of your contracted hours teaching eligible subjects"}
    validates :itt_academic_year, on: [:"itt-year", :submit], presence: {message: ->(object, data) { I18n.t("activerecord.errors.models.early_career_payments_eligibilities.attributes.itt_academic_year.blank.qualification.#{object.qualification}") }}
    validates :award_amount, on: [:submit], presence: {message: "Enter an award amount"}
    validates_numericality_of :award_amount, message: "Enter a valid monetary amount", allow_nil: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 7500
    validates :award_amount, on: :amendment, award_range: {max: max_award_amount_in_pounds}

    before_save :set_qualification_if_trainee_teacher, if: :nqt_in_academic_year_after_itt_changed?

    delegate :name, to: :current_school, prefix: true, allow_nil: true

    def policy
      EarlyCareerPayments
    end

    # Rescues from errors for assignments coming from LUP-only fields
    # eg. `claim.eligibility.eligible_degree_subject = true` will get ignored
    def assign_attributes(*args)
      super
    rescue ActiveRecord::UnknownAttributeError
      all_attributes_ignored = (args.first.keys - IGNORED_ATTRIBUTES).empty?
      raise unless all_attributes_ignored
    end

    def trainee_teacher?
      nqt_in_academic_year_after_itt == false
    end

    def qualification_name
      return qualification.gsub("_itt", " initial teacher training (ITT)") if qualification.split("_").last == "itt"

      qualification_attained = qualification.humanize.downcase

      qualification_attained == "assessment only" ? qualification_attained : qualification_attained + " qualification"
    end

    def eligible_later
      find_cohorts(match_criteria: :partial_find_all).reject { |award_amount| award_amount.claim_academic_year <= claim.academic_year }
    end

    def eligible_later?
      eligible_later.present?
    end

    # next eligible ignores current eligibility and is always looking forward
    # to the next application window, used for reminder setting.
    # definitions come from https://www.gov.uk/guidance/early-career-payments-guidance-for-teachers-and-schools
    def eligible_later_year
      eligible_later.first&.claim_academic_year
    end

    def eligible_now?
      find_cohorts(match_criteria: :exact).one?
    end

    # This doesn't mean it's eligible either, ie, eligibility could be undetermined
    # TODO: :itt_subject_none_of_the_above? might need to be more specific for CAPT-392 (not yet done)
    def ineligible?
      trainee_teacher_with_itt_subject_none_of_the_above ||
        ineligible_current_school? ||
        no_entire_term_contract? ||
        not_employed_directly? ||
        poor_performance? ||
        itt_subject_ineligible? ||
        not_teaching_now_in_eligible_itt_subject? ||
        ineligible_cohort?
    end

    def ineligibility_reason
      [
        :generic_ineligibility,
        :itt_subject_none_of_the_above,
        :ineligible_current_school,
        :not_teaching_now_in_eligible_itt_subject
      ].find { |eligibility_check| send("#{eligibility_check}?") }
    end

    def award_amount
      super || calculate_award_amount
    end

    def calculate_award_amount
      return BigDecimal("0.00") if current_school.nil?

      current_school.eligible_for_early_career_payments_as_uplift? ? award_amounts.first.uplift_amount : award_amounts.first.base_amount
    end

    def award_amounts
      zero_award = [AwardAmount.new(
        itt_subject: :not_eligible,
        itt_academic_year: AcademicYear.new,
        claim_academic_year: AcademicYear.new,
        base_amount: BigDecimal("0.00"),
        uplift_amount: BigDecimal("0.00")
      )]
      return zero_award if without_cohort?

      if eligible_now?
        award_amounts = find_cohorts(match_criteria: :exact)
      elsif eligible_later?
        award_amounts = find_cohorts(match_criteria: :partial_find_all)
      end
      return zero_award if award_amounts.nil?

      award_amounts
    end

    def first_eligible_itt_academic_year
      find_cohorts(match_criteria: :partial_find)&.itt_academic_year
    end

    def reset_dependent_answers(reset_attrs = [])
      attrs = ineligible? ? changed.concat(reset_attrs) : changed

      ATTRIBUTE_DEPENDENCIES.each do |attribute_name, dependent_attribute_names|
        dependent_attribute_names.each do |dependent_attribute_name|
          write_attribute(dependent_attribute_name, nil) if attrs.include?(attribute_name)
        end
      end
    end

    def eligible_none_of_the_above?
      false
    end

    def submit!
      self.award_amount = award_amount
      save!
    end

    private

    def itt_subject_ineligible?
      return false if claim.academic_year.blank?

      has_itt_subject_other_than_those_eligible_now_or_in_the_future?
    end

    def has_itt_subject_other_than_those_eligible_now_or_in_the_future?
      itt_subject = eligible_itt_subject # attribute name implies eligibility which isn't always the case
      return false if itt_subject.blank?

      begin
        itt_subject_checker = JourneySubjectEligibilityChecker.new(claim_year: claim.academic_year, itt_year: itt_academic_year)
        # TODO: this might not work if display and symbol diverge, e.g. if `Foreign Languages`
        # changes to `Languages` but we keep the symbol as `:foreign_languages`
        itt_subject_symbol = itt_subject.to_sym
        !itt_subject_symbol.in?(itt_subject_checker.current_and_future_subject_symbols(policy))
      rescue
        # have bad year for policy, but can still rule some out
        itt_subject_none_of_the_above?
      end
    end

    def find_cohorts(match_criteria:)
      if match_criteria == :exact
        AWARD_AMOUNTS.find_all do |award_amount|
          award_amount.itt_academic_year == itt_academic_year &&
            award_amount.itt_subject.to_s == eligible_itt_subject &&
            award_amount.claim_academic_year == claim.academic_year
        end
      elsif match_criteria == :partial_find_all
        AWARD_AMOUNTS.find_all do |award_amount|
          award_amount.itt_academic_year == itt_academic_year &&
            award_amount.itt_subject.to_s == eligible_itt_subject
        end
      elsif match_criteria == :partial_find
        AWARD_AMOUNTS.find do |award_amount|
          award_amount.claim_academic_year == claim.academic_year &&
            award_amount.itt_subject.to_s == eligible_itt_subject
        end
      end
    end

    def without_cohort?
      [eligible_itt_subject, itt_academic_year].any?(nil)
    end

    def ineligible_cohort?
      return true if itt_academic_year == AcademicYear.new
      return true if itt_academic_year == AcademicYear.new("2017/2018")

      return false if without_cohort?
      return false if eligible_later.present?

      find_cohorts(match_criteria: :exact).none?
    end

    def ineligible_current_school?
      current_school.present? && !current_school.eligible_for_early_career_payments?
    end

    def no_entire_term_contract?
      employed_as_supply_teacher? && has_entire_term_contract == false
    end

    def not_employed_directly?
      employed_as_supply_teacher? && employed_directly == false
    end

    def not_teaching_now_in_eligible_itt_subject?
      teaching_subject_now == false
    end

    def poor_performance?
      subject_to_formal_performance_action? ||
        subject_to_disciplinary_action?
    end

    def generic_ineligibility?
      trainee_teacher_with_itt_subject_none_of_the_above ||
        no_entire_term_contract? ||
        not_employed_directly? ||
        poor_performance? ||
        ineligible_cohort?
    end

    def no_student_loan?
      claim.no_student_loan?
    end

    def set_qualification_if_trainee_teacher
      return unless trainee_teacher?

      self.qualification = :postgraduate_itt
    end

    def trainee_teacher_with_itt_subject_none_of_the_above
      trainee_teacher? && itt_subject_none_of_the_above?
    end
  end
end
