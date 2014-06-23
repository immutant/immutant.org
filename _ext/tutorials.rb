class Tutorials

  def tutorials(suffix, site)
    site.pages.inject([]) do |accum, p|
      if (p.relative_source_path =~ %r{^/tutorials#{suffix}/}) &&
          !(p.relative_source_path =~ %r{/index\.})
        if p.date?
          p.date = Time.parse( p.date ) if p.date.kind_of?(String)
        else
          p.date = p.input_mtime
        end
        p.layout ||= "tutorial#{suffix}"
        p.inhibit_title = true
        accum << p
      end
      accum
    end.sort_by { |p| p.sequence || 0 }
  end

  def execute(site)
    site.tutorials = tutorials("", site)
    site.tutorials1 = tutorials("-1x", site)
  end

end
