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

  def doc_chapter_for_version(version, chapter)
    "/documentation/#{version}/#{chapter}.html"
  end

  def doc_bundle_name(release)
    release.version == '0.1.0' ? "immutant-docs-#{release.version}.jar" :
      "immutant-docs-#{release.version}-bin.zip"
  end
end
