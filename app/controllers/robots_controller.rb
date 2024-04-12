class RobotsController < ApplicationController
  def robots_txt
    robots = File.read(Rails.root + "public/robots.txt")
    render plain: robots, layout: false, content_type: "text/plain"
  end
end
