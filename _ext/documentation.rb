
class Documentation

  def initialize(enabled=true)
    @enabled = enabled
  end

  def execute(site)
    return unless @enabled

    @tmp_dir = site.tmp_dir

    current_path = File.join( site.output_dir, 'documentation', 'current' )
    
    FileUtils.mkdir_p( site.output_dir )
    FileUtils.rm( current_path ) if File.exist?( current_path )
    
    (site.releases).each do |release|
      doc_bundle_name = "immutant-docs-#{release.version}.jar"
      base_dir = File.join( site.output_dir, 'documentation' )
      doc_root = File.join( base_dir, release.version )
      
      unless bundle_exists?( doc_bundle_name )
        puts "Fetching doc bundle for #{release.version}"
        dl( release.urls.docs.remote_html_zip )
      end
      
      unless File.exist?( File.join( doc_root, "index.html" ) )
        puts "Unzipping doc bundle for #{release.version}"
        unzip( bundle_path( doc_bundle_name ), base_dir )
        FileUtils.mv( File.join( base_dir, 'html'), doc_root )
        FileUtils.rm_rf( File.join( base_dir, 'META-INF' ) )
      end

      if release == site.releases.first
        #puts "Linking documentation/current to #{release.version}"
        FileUtils.cd( File.join( site.output_dir, 'documentation' ) ) do |dir|
          FileUtils.ln_s( release.version, 'current' ) 
        end
      end
      
    end
  end

  def bundle_exists?(name)
    File.exist?( bundle_path( name ) )
  end

  def bundle_path(name)
    File.join( @tmp_dir, name )
  end

  def unzip(bundle, dest)
    `unzip -q #{bundle} -d #{dest}`
  end

  def dl(url, dir = @tmp_dir)
    `wget --quiet -P #{dir} #{url}`
  end
  
end
