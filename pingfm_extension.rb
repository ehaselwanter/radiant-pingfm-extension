# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class PingfmExtension < Radiant::Extension
  version "0.1"
  description "Post page creation to social networks via ping.fm"
  url "http://github.com/ehaselwanter/radiant-pingfm-extension"
  
  define_routes do |map|
    map.with_options :controller => 'pingfm' do |t|
      t.pingfm '/admin/pingfm', :action => "edit"
    end
  end
  
  def activate
    unless admin.respond_to?(:settings)
      admin.tabs.add "Pingfm", "/admin/pingfm"
    end
    admin.pages.edit.add :extended_metadata, "pingfm"
    Page.class_eval { include PingfmNotification, PingfmTags }

    if admin.respond_to?(:help)
      admin.help.index.add :page_details, 'pingfm'
    end
  end
end
