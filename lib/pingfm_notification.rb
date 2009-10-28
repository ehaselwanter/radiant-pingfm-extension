require 'pingfm'
module PingfmNotification
  def self.included(base)
    base.class_eval {
      after_save :notify_pingfm
    }
  end
  
  def notify_pingfm
    if parent
      if published? && pingfm_configured? && parent.notify_pingfm_of_children? && !self.already_notified_pingfm
        message = Hash.new
        message[:status_body] = "(#{absolute_url}) #{title} #{"@t "+ self.meta_tags.collect{|tag| tag.name}.join(", ") if self.respond_to?(:meta_tags)}"
        message[:blog_title] = title
        message[:blog_body] = "#{render_part(:body)} </br> <a href='#{absolute_url}'>readmore</a> #{"@t "+ self.meta_tags.collect{|tag| tag.name}.join(", ") if self.respond_to?(:meta_tags)}"

        logger.debug "posting  #{message[:status_body]} to ping.fm"
        logger.debug "posting  #{message[:blog_body]} to ping.fm"

        message[:debug] = 0

        begin
          client = Pingfm::Client.new(config['pingfm.application_api_key'].strip,config['pingfm.api_key'].strip)
          #post(body, title = '', post_method = 'default', service = '', debug = 0)
          status_status = client.tpost(message[:status_body],'status','',message[:debug])
          blog_status =  client.tpost(message[:blog_body],'blogs',message[:blog_title],message[:debug])
          # Don't trigger save callbacks
          if status_status['status'].eql?("OK") || blog_status['status'].eql?("OK")
            self.class.update_all({:already_notified_pingfm => true}, :id => self.id)
            logger.debug "posted  #{message[:blog_title]} to ping.fm"
          else
            logger.error("Ping.fm Notification failure: #{status['message']} application_api_key:'#{config['pingfm.application_api_key']}' api_key:'#{config['pingfm.api_key']}'")
          end
        rescue Exception => e
          # Pingfm failed... just log for now
          logger.error "Ping.fm Notification exception #{e.inspect} application_api_key:'#{config['pingfm.application_api_key']}' api_key:'#{config['pingfm.api_key']}'"
        end
      end
    end
  end

  def absolute_url
    if config['pingfm.url_host'] =~ /^http/
      "#{config['pingfm.url_host']}#{self.url}"
    else
      "http://#{config['pingfm.url_host']}#{self.url}"
    end
  end

  def pingfm_configured?
    !%w(pingfm.api_key pingfm.application_api_key pingfm.url_host).any? {|k| config[k].blank? }
  end

  def config
    Radiant::Config
  end
end