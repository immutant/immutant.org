require 'net/http'
require 'uri'

class ReleaseSizes
  include ReleaseHelper

  def initialize()
  end

  def get_size(url)
    uri = URI.parse(url)
    Net::HTTP.start( uri.host, uri.port ) do |http|
      response = http.head( uri.path )
      b = response['content-length'] || ''
      if ( ! b.empty? )
        b = b.to_i
        kb = b / 1024
        kb / 1024
      else
        "unknown"
      end
    end
  end

  def execute(site)
    site.releases.select {|v| is_1x_release?(v)}.each do |release|
      print "Calculating dist size for #{release.version}... "
      release.dist_size = get_size(release.urls.remote_dist_zip)
      if release.dist_type == :bin || release.dist_type == :slim_only
        puts "(#{release.dist_size} mb)"
      else
        release.full_dist_size = get_size(release.urls.remote_full_zip)
        puts "(slim: #{release.dist_size} mb, full: #{release.full_dist_size} mb)"
      end
    end
  end
end
