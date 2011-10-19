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

  def current_amis
      latest_release.amis
  end

end
