class RankingsController < ApplicationController
  # GET /rankings
  # GET /rankings.json
  def index
    @rankings_free = Ranking.where(:genre => TOPSELLING_FREE).last
    @rankings_paid = Ranking.where(:genre => TOPSELLING_PAID).last

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rankings }
    end
  end

  # GET /rankings/1
  # GET /rankings/1.json
  def show
    @ranking = Ranking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ranking }
    end
  end
end
