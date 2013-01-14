module ReleaseHelper

  def release_for_version(version)
    site.releases.find { |release| release.version == version }
  end

  def announcement_for_version(version)
    site.posts.find { |p| p.version == version }
  end

  def latest_release
    site.releases.first
  end

  def latest_release?(release)
    release == latest_release
  end

  def api_doc_for_version(version, group, fn = nil)
    if version.to_f > 0 &&
        version.to_f < 0.8
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
