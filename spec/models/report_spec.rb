require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:partner) { FactoryGirl.create :partner }
  let(:report) { FactoryGirl.create :report, partner: partner, report_type: report_type }
  let!(:registrants) { FactoryGirl.create_list :completed_registrant, 3, partner: partner }
  let!(:reg_no_pdf_delivery) { registrants[0] }
  let!(:reg_unsigned_pdf_delivery) { registrants[1].tap { |r| r.create_pdf_delivery } }
  let!(:reg_esigned_pdf_delivery) { registrants[2].tap { |r| r.create_pdf_delivery; r.update!(voter_signature_image: '!')  } }

  before do
    allow(report).to receive(:write_report_file) do |_fn, contents|
      @report = CSV.parse(contents)
    end
  end

  context 'pdf_assistance' do
    let(:report_type) { described_class::REGISTRANTS_REPORT_EXTENDED }
    let(:column) { Registrant::CSV_HEADER_EXTENDED.index('Requested Assistance') }
    let(:email) { Registrant::CSV_HEADER_EXTENDED.index('Email address') }

    it 'includes pdf_assistance data' do
      report.run
      expect(report.status).to eq(Report::Status.complete.to_s)
      expect(@report.size).to eq(registrants.size + 1)
      expect(@report[0][column]).to eq('Requested Assistance')
      expect(@report[2][email]).to eq(reg_unsigned_pdf_delivery.tell_email)
      expect(@report[1][column]).to eq(nil)
      expect(@report[2][column]).to eq('Yes')
      expect(@report[3][column]).to eq(nil)
    end
  end
end
