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
        message[:body] = "(#{absolute_url}) #{title} #{"@t "+ self.meta_tags.map(&:name).join(', ') if self.respond_to?(:meta_tags)}"
        logger.info "posted  #{message[:body]} to ping.fm"
        message[:debug] = 0

        begin
          client = Pingfm::Client.new(config['pingfm.application_api_key'],config['pingfm.api_key'])
          #post(body, title = '', post_method = 'default', service = '', debug = 0)
          status = client.post(message[:body],'','default','',1)
          # Don't trigger save callbacks
          if status['status'].eql?("OK")
            self.class.update_all({:already_notified_pingfm => true}, :id => self.id)
          else
            logger.error("Ping.fm Notification failure: #{status['message']}")
          end
        rescue Exception => e
          # Pingfm failed... just log for now
          logger.error "Ping.fm Notification failure: #{e.inspect}"
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