class NewsController < ApplicationController
  # GET /news
  # GET /news.json
  def index
    @news = News.where{created_at >= 1.hours.ago}
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news }
    end
  end
end
