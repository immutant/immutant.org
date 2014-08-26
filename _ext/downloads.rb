class Downloads
  include ReleaseHelper

  STAGING_REPO_PREFIX = "http://downloads.immutant.org/staging/org/immutant"
  REPO_PREFIX         = "http://downloads.immutant.org/release/org/immutant"


  def initialize(enabled=true)
    @enabled = enabled
  end

  def add_common_entries(release)
    release.urls ||= OpenStruct.new
    release.urls.docs ||= OpenStruct.new
    release.urls.docs.apidocs = "/documentation/#{release.version}/apidoc/"
    release.urls.jira = "https://jira.jboss.org/jira/secure/IssueNavigator.jspa?reset=true&jqlQuery=project=IMMUTANT+AND+fixVersion=#{release.jira_version}&sorter/field=issuekey&sorter/order=DESC"
    release.urls.github ||= OpenStruct.new
    release.urls.github.log = "https://github.com/immutant/immutant/commits/#{release.version}"
    release.urls.github.tree = "https://github.com/immutant/immutant/tree/#{release.version}"
  end

  def add_1x_entries(release)
    # if release.version == "1.1.0"
    #   puts "################################################"
    #   puts "HEY, DUMMY! YOU'RE STILL USING A STAGING RELEASE"
    #   puts "################################################"
    #   prefix = STAGING_REPO_PREFIX
    # else
    prefix = REPO_PREFIX
    #end

    docs_prefix = "#{prefix}/immutant-docs"

    release.urls.docs.browse = "/documentation/#{release.version}/"
    release.urls.docs.remote_html_zip = "#{docs_prefix}/#{release.version}/#{doc_bundle_name(release)}"

    release_infix = "/immutant-dist/#{release.version}/immutant-dist-#{release.version}-"
    if release.dist_type == :bin
      release.urls.remote_dist_zip  = "#{prefix}#{release_infix}bin.zip"
    elsif release.dist_type == :slim_only
      release.urls.remote_dist_zip  = "#{prefix}#{release_infix}slim.zip"
    else
      release.urls.remote_dist_zip  = "#{prefix}#{release_infix}slim.zip"
      release.urls.remote_full_zip  = "#{prefix}#{release_infix}full.zip"
    end
  end

  def execute(site)
    return unless @enabled

    site.releases.each do |release|
      add_common_entries(release)
      add_1x_entries(release) if is_1x_release?(release)
    end
  end

end
