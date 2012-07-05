
class Downloads
  include ReleaseHelper
  
  REPO_PREFIX        = "http://repository-projectodd.forge.cloudbees.com/staging/org/immutant"
  #REPO_PREFIX        = "http://repository-projectodd.forge.cloudbees.com/release/org/immutant"
  DOCS_PREFIX        = "#{REPO_PREFIX}/immutant-docs"

  def initialize(enabled=true)
    @enabled = enabled
  end

  def execute(site)
    return unless @enabled

    site.releases.each do |release|

      release.urls ||= OpenStruct.new
      release.urls.docs ||= OpenStruct.new
      release.urls.docs.browse = "/documentation/#{release.version}/"
      release.urls.docs.apidocs = "/documentation/#{release.version}/apidoc/"

      release.urls.docs.remote_html_zip = "#{DOCS_PREFIX}/#{release.version}/#{doc_bundle_name(release)}"

      release.urls.jira = "https://jira.jboss.org/jira/secure/IssueNavigator.jspa?reset=true&jqlQuery=project=IMMUTANT+AND+fixVersion=#{release.jira_version}&sorter/field=issuekey&sorter/order=DESC"

      release.urls.github ||= OpenStruct.new
      release.urls.github.log = "https://github.com/immutant/immutant/commits/#{release.version}"
      release.urls.github.tree = "https://github.com/immutant/immutant/tree/#{release.version}"

      release_suffix = "/immutant-dist/#{release.version}/immutant-dist-#{release.version}-bin.zip"
      release.urls.remote_dist_zip  = "#{REPO_PREFIX}#{release_suffix}"
    end
  end

end
