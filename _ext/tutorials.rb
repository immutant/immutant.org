class Tutorials

  def execute(site)
    site.tutorials = site.pages.inject([]) do |accum, p|
      if (p.relative_source_path =~ %r{^/tutorials/}) &&
          !(p.relative_source_path =~ %r{/index\.})
        if p.date?
          p.date = Time.parse( p.date ) if p.date.kind_of?(String)
        else
          p.date = p.input_mtime
        end
        p.layout ||= 'tutorial'
        p.inhibit_title = true
        accum << p
      end
      accum
    end.sort_by { |p| p.sequence || 0 }
  end

end
