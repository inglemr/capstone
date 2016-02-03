class EventsController < ApplicationController
	load_and_authorize_resource
	before_filter :load_permissions 
	def show
		@event = Event.find(params[:id])
	end

end