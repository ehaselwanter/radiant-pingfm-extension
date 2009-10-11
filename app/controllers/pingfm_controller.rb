class PingfmController < ApplicationController
  def edit
    if request.post?
      begin
        @config['pingfm.api_key'] = params[:api_key]
        @config['pingfm.application_api_key'] = params[:application_api_key]
        @config['pingfm.url_host'] = params[:url_host]
        flash[:notice] = "Pingfm settings saved."
      rescue
        flash[:error] = "Pingfm settings could not be saved!"
      end
      redirect_to :action => 'edit'
    end
  end

end
