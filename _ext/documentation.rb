class Documentation
  include ReleaseHelper

  def initialize(enabled=true)
    @enabled = enabled
  end

  def execute(site)
    return unless @enabled

    @tmp_dir = site.tmp_dir

    base_dir = File.join( site.output_dir, 'documentation' )
    current_path = File.join( base_dir, 'current' )

    FileUtils.mkdir_p( site.output_dir )
    FileUtils.rm( current_path ) if File.exist?( current_path )

    site.releases.each do |release|
      doc_root = File.join( base_dir, release.version )

      if is_1x_release?(release)
        doc_bundle_name = doc_bundle_name( release )

        unless bundle_exists?( doc_bundle_name )
          puts "Fetching doc bundle for #{release.version}"
          dl( release.urls.docs.remote_html_zip )
        end

        unless File.exist?( File.join( doc_root, "index.html" ) )
          puts "Unzipping doc bundle for #{release.version}"
          begin
            unzip( bundle_path( doc_bundle_name ), base_dir )
            FileUtils.mv( File.join( base_dir, 'html'), doc_root )
            FileUtils.rm_rf( File.join( base_dir, 'META-INF' ) )
          rescue Exception => e
          puts "ERROR: failed to unzip docs for #{release.version}: " + e.to_s
          end
        end
      else
        puts "Copying docs for #{release.version}"
        FileUtils.mkdir_p(doc_root)
        docs_for_version = File.join("_2x_docs", release.version, "apidoc")
        if File.exists?(docs_for_version)
          FileUtils.cp_r(docs_for_version, doc_root)
        else
          puts "#############################################"
          puts "WARNING: no docs found for #{release.version}"
          puts "#############################################"
        end

      end

      if latest_release?(site, release)
        puts "Linking documentation/current to #{release.version}"
        FileUtils.cd(base_dir) do |dir|
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
