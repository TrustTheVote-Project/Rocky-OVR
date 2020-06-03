module ApiHelperMethods
  def expect_api_response(data)
    controller.stub(:jsonp).with(data) { controller.render :nothing=>true }
  end

  def expect_api_error(data)
    controller.stub(:jsonp).with(data, :status => 400)  { controller.render :nothing=>true }
  end
  
  def expect_api_deprecation_response
    expect_api_response :deprecation_message=>"This report generation API is no longer available. Please use V4. https://rock-the-vote.github.io/Voter-Registration-Tool-API-Docs/"
  end
  
end