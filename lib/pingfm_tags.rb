require 'pingfm'

module PingfmTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable

  tag 'pingfm' do |tag|
    tag.expand
  end

  desc %{
    Usage:
    <pre><code><r:pingfm:message /></code></pre>
    Displays the latest status message from the current user's timeline }
  tag 'pingfm:message' do |tag|
    status = pingfm_status
    text = "not implemented"
  end

  private
    def pingfm_status
      begin

      rescue Exception => e
        # Pingfm failed... just log for now
        logger.error "Pingfm failure: #{e.inspect}"
      end
    end
end