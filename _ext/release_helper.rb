module ReleaseHelper

  def release_for_version(version)
    site.releases.find { |release| release.version == version }
  end

  def announcement_for_version(version)
    site.posts.find { |p| p.version == version }
  end

  def is_1x_release?(release)
    !is_2x_release?(release)
  end

  def is_2x_release?(release)
    release.version.start_with?("2")
  end

  def latest_release(site_map=nil)
    (site_map ? site_map : site).releases.first
  end

  def latest_1x_release(site_map=nil)
    (site_map ? site_map : site).releases.detect {|r| is_1x_release?(r)}
  end

  def latest_2x_release(site_map=nil)
    (site_map ? site_map : site).releases.detect {|r| is_2x_release?(r)}
  end

  def latest_release?(site_map=nil, release)
    release == latest_release(site_map)
  end

  def latest_1x_release?(site_map=nil, release)
    release == latest_1x_release(site_map)
  end

  def latest_2x_release?(site_map=nil, release)
    release == latest_2x_release(site_map)
  end

  def api_doc_for_version(version, group, fn = nil)
    if version.to_f > 0 &&
        version.to_f < 0.8 &&
        version != "0.10.0"
      path = "/documentation/#{version}/apidoc/#{group}-api.html"
      path << "##{fn}" if fn
    else
      if version == 'LATEST'
        path = "/builds/LATEST/html-docs/apidoc/immutant.#{group}.html"
      else
        path = "/documentation/#{version}/apidoc/immutant.#{group}.html"
      end
      path << "#var-#{fn}" if fn
    end
    path
  end

  def api_doc_for_2x_version(version, group = nil, fn = nil)
    path = "/builds/2x/#{version}/target/apidocs/"
    path << (group ? "immutant.#{group}.html" : "index.html")
    path << "#var-#{fn}" if fn
    path
  end

  def doc_chapter_for_version(version, chapter, target = nil)
      if version == 'LATEST'
        path = "/builds/LATEST/html-docs/#{chapter}.html"
      else
        path = "/documentation/#{version}/#{chapter}.html"
      end
    path << "##{target}" if target
    path
  end

  def doc_bundle_name(release)
    release.version == '0.1.0' ? "immutant-docs-#{release.version}.jar" :
      "immutant-docs-#{release.version}-bin.zip"
  end
end
