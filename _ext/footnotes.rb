class Footnotes
  def transform(site, page, input)
    if File.extname(page.output_path) == ".html" &&
        input =~ /<li>\[\^\d\]/
      puts "Processing footnotes for #{page.output_path}"
      input
        .gsub(/<li>\[\^(\d+)\]/, %Q{<li id="fn\\1" class="footnote"> <a href="#bfn\\1">^</a>})
        .gsub(/\[\^(\d+)\]/, %Q{<sup id="bfn\\1"><a href="#fn\\1">\\1</a></sup>})
    else
      input
    end
  end
end
