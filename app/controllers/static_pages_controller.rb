class StaticPagesController < BasePublicController
  def accessibility_statement
  end

  def contact_us
  end

  def cookies
  end

  def privacy_notice
  end

  def terms_conditions
  end

  def landing_page
    @academic_year = PolicyConfiguration.for(EarlyCareerPayments).current_academic_year
  end
end
