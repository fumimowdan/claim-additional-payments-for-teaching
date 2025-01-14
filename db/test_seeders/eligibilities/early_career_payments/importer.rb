module TestSeeders
  module Eligibilities
    module EarlyCareerPayments
      class Importer
        include EarlyCareerPayments

        ELIGIBILITY_COLUMNS = [
          :nqt_in_academic_year_after_itt,
          :qualification,
          :eligible_itt_subject,
          :itt_academic_year,
          :teaching_subject_now,
          :employed_as_supply_teacher,
          :subject_to_disciplinary_action,
          :subject_to_formal_performance_action,
          :current_school_id,
          :created_at,
          :updated_at
        ].freeze

        def initialize(records, **kwargs)
          @records = records
          @logger = Logger.new($stdout)
          @test_type = kwargs[:test_type]
          @quantity = kwargs[:quantity]
        end

        def run
          logger.info "Seeding #{records.size} ECP Eligibilities"
          insert_eligibilities
        end

        private

        attr_reader :records, :logger, :test_type, :quantity

        # the existing version of the activerecord-copy gem does not support
        # binary copy of decimals, so for now 'award_amount' has been excluded
        # it will be calculated dynamically, and because this is for test purposes
        # does not suffer the issue previously where if GIAS data changes then a
        # claimants award_amount might change between submission, approval and then
        # being added to a payroll run
        def insert_eligibilities
          ::EarlyCareerPayments::Eligibility.copy_from_client ELIGIBILITY_COLUMNS do |copy|
            records.each do |data|
              time = Time.now.getutc

              copy << [
                true,
                qualification(data["Post / Undergraduate / AO / Overseas"])&.last,
                eligible_itt_subject(data["Subject Code"])&.last.to_s,
                itt_academic_year(data["ITT Cohort Year"]),
                true,
                false,
                false,
                false,
                schools_id,
                time,
                time
              ]
            end
          end
        end

        def schools_id
          uplift = [1, 4].include? Random.rand(10)
          return School.find_by(name: "Penistone Grammar School").id if uplift

          School.find_by(name: "Hampstead School").id
        end
      end
    end
  end
end
