require 'net/http'

class EventsController < ApplicationController

  before_action :find_event, except: [:index, :create, :new, :import_events]

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @event.to_json }
    end
  end

  def index
    @events = Event.where('start_date <= ?', DateTime.now.end_of_year).order(start_date: :desc)

    respond_to do |format|
      format.html
      format.json { render :json => @events.to_json }
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to events_path
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @event.update_attributes(event_params)
      redirect_to event_path(@event)
    else
      render action: 'edit'
    end
  end

  def delete
  end

  def destroy
    @event.destroy
    redirect_to events_path
  end

  def import_events
    redirect_to events_path
  end

  private

  def find_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :start_date, :end_date,
                                  :removel, :location, :buildup,
                                  :case_ids).tap do |whitelisted|
      whitelisted[:case_ids] = params[:event][:case_ids]
    end
  end

end
