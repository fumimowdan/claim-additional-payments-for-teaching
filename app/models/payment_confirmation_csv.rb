require "csv"

class PaymentConfirmationCsv
  attr_reader :rows, :errors

  EXPECTED_HEADERS = [
    "Payroll Reference",
    "Gross Value",
    "Claim ID",
    "NI",
    "Employers NI",
    "Student Loans",
    "Tax",
    "Net Pay",
  ].freeze

  def initialize(file)
    @errors = []
    @rows = parse_csv(file)
    check_headers
  end

  private

  def check_headers
    if rows
      missing_headers = EXPECTED_HEADERS - rows.headers
      errors.append("The selected file is missing some expected columns: #{missing_headers.join(", ")}") if missing_headers.any?
    end
  end

  def parse_csv(file)
    if file.nil?
      errors.append("You must provide a file")
      nil
    else
      CSV.read(file.to_io, headers: true)
    end
  rescue CSV::MalformedCSVError
    errors.append("The selected file must be a CSV")
    nil
  end
end
