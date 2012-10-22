class ApplicationController < ActionController::Base
  protect_from_forgery
  
  TOPSELLING_FREE = "topselling_free"
  TOPSELLING_PAID = "topselling_paid"
end
