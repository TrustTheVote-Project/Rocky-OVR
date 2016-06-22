require 'rails_helper'

describe PriorityPdfGeneration do


  describe '.retrieve_from_queue' do
    let(:queue) { double(Object) }
    let(:receive_resp) { double(Object) }
    before(:each) do
      queue.stub(:receive_message).and_return(receive_resp)
      receive_resp.stub(:messages).and_return(["A Message"])
      PriorityPdfGeneration.stub(:queue).and_return(queue)
      PdfGeneration.stub(:receive_and_generate)
    end
    it "gets a message from the queue" do
      queue.should_receive(:receive_message).with({
        queue_url: PriorityPdfGeneration.queue_url, # required
        max_number_of_messages: 1,
        wait_time_seconds: 3,
      })
      PriorityPdfGeneration.retrieve_from_queue
    end
    it "returns the first message" do
      receive_resp.stub(:messages).and_return(["First Message", "Second Message"])
      PriorityPdfGeneration.retrieve_from_queue.should == "First Message"
    end
    context 'Now rows avaialable' do
      before(:each) do
        receive_resp.stub(:messages).and_return([])
        PriorityPdfGeneration.stub(:sleep)
      end
      it "calls PdfGeneration.retrieve_from_queue" do
        PdfGeneration.should_receive(:receive_and_generate)
        PriorityPdfGeneration.retrieve_from_queue
      end
      
      it "does not pause before returning" do
        PriorityPdfGeneration.should_not_receive(:sleep)
        PriorityPdfGeneration.retrieve_from_queue
      end
    end
  end  
  
end
