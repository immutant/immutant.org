require 'release_helper'
require 'format_helper'
#require 'release_sizes'
require 'rss_widget'
require 'tagger_atomizer'
require 'events_munger'
require 'downloads'
require 'documentation'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::DataDir.new

  extension EventsMunger.new()
  extension Awestruct::Extensions::Atomizer.new(:events, '/events.atom')

  extension Downloads.new()
  
  extension Awestruct::Extensions::Posts.new('/news')
  extension Awestruct::Extensions::Paginator.new(:posts, '/news/index', :per_page => 5)
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::Atomizer.new(:posts, '/news.atom')
  extension Awestruct::Extensions::Disqus.new
#  extension ReleaseSizes.new

  extension Awestruct::Extensions::Tagger.new(:posts,
                                              '/news/index',
                                              '/news/tags',
                                              :per_page=>5)

  extension Awestruct::Extensions::TagCloud.new(:posts,
                                                '/news/tags/index.html',
                                                :layout=>'one-column')

  extension Awestruct::Extensions::TaggerAtomizer.new(:posts, '/news/tags' )
  
  helper Awestruct::Extensions::GoogleAnalytics
  helper Awestruct::Extensions::Partial
  helper ReleaseHelper
  helper FormatHelper
  helper RssWidget

  extension Documentation.new()
end
