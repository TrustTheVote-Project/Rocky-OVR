require 'rails_helper'

describe PdfGeneration do
  
  describe '.count' do
    it "needs testing"
  end
  
  describe '.queue_registrant' do
    it "needs testing"
  end
  
  describe '.create!' do
    it "needs testing"
  end
  
  describe ".delete_from_queue" do
    it "needs testing"
  end
  
  describe '.retrieve_from_queue' do
    let(:queue) { double(Object) }
    let(:receive_resp) { double(Object) }
    before(:each) do
      queue.stub(:receive_message).and_return(receive_resp)
      receive_resp.stub(:messages).and_return(["A Message"])
      PdfGeneration.stub(:queue).and_return(queue)
    end
    it "gets a message from the queue" do
      queue.should_receive(:receive_message).with({
        queue_url: PdfGeneration.queue_url, # required
        max_number_of_messages: 1,
        wait_time_seconds: 3,
      })
      PdfGeneration.retrieve_from_queue
    end
    it "returns the first message" do
      receive_resp.stub(:messages).and_return(["First Message", "Second Message"])
      PdfGeneration.retrieve_from_queue.should == "First Message"
    end
    context 'Now rows avaialable' do
      before(:each) do
        receive_resp.stub(:messages).and_return([])
        PdfGeneration.stub(:sleep)
      end
      it "pauses before returning" do
        PdfGeneration.should_receive(:sleep).with(3)
        PdfGeneration.retrieve_from_queue
      end
    end
  end
  
  describe '.receive_and_generate' do
    let(:r) { double(Registrant, pdf_ready?: false) }
    let(:message) { double(Object, body: "1") }
    before(:each) do
      PdfGeneration.stub(:retrieve_from_queue).and_return(message)
      Registrant.stub(:find).and_return(r)
      PdfGeneration.stub(:delete_from_queue).and_return(true)
      r.stub(:generate_pdf).and_return(true)
      r.stub(:finalize_pdf).and_return(true)
    end
    
    it "retrieves an id" do
      PdfGeneration.should_receive(:retrieve_from_queue)
      PdfGeneration.receive_and_generate.should be_truthy
    end
    
    it "retrieves the registrant" do
      Registrant.should_receive(:find).with("1")
      PdfGeneration.receive_and_generate.should be_truthy
    end
    
    it "generates the pdf" do
      r.should_receive(:generate_pdf)
      PdfGeneration.receive_and_generate.should be_truthy
    end
    it "finishes the pdf gen" do
      r.should_receive(:finalize_pdf)
      PdfGeneration.receive_and_generate.should be_truthy
    end
    it "deletes the pdfgen message" do
      PdfGeneration.should_receive(:delete_from_queue)
      PdfGeneration.receive_and_generate.should be_truthy
    end
    
    context 'when there is no registrant' do
      before(:each) do
        Registrant.stub(:find).and_return(nil)
      end
      it "doesn't finish the pdf gen or delete the row" do
        r.should_not_receive(:generate_pdf)
        r.should_not_receive(:finalize_pdf)
        PdfGeneration.should_not_receive(:delete_from_queue)
        PdfGeneration.receive_and_generate
      end
      it "logs an error" do
        Rails.logger.should_receive(:error)
        PdfGeneration.receive_and_generate
      end
    end
    context 'when the pdf fails to generate' do
      before(:each) do
        r.stub(:generate_pdf).and_return(false)
      end
      it "doesn't finish the pdf gen or delete the row" do
        r.should_not_receive(:finalize_pdf)
        PdfGeneration.should_not_receive(:delete_from_queue)
        PdfGeneration.receive_and_generate
      end
      it "logs an error" do
        Rails.logger.should_receive(:error)
        PdfGeneration.receive_and_generate
      end
    end
    context 'when the pdfgenid is nil' do
      it "returns false" do
        PdfGeneration.stub(:retrieve_from_queue).and_return(nil)
        PdfGeneration.receive_and_generate.should be_falsey
      end
    end
  end
  
end
