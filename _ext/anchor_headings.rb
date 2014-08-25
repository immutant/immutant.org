class AnchorHeadings
  def initialize(*matchers)
    @matchers = matchers
  end

  def transform(site, page, input)
    if @matchers.detect {|m| m =~ page.output_path} &&
        File.extname(page.output_path) == ".html" &&
        input =~ /<h[1-6]>/
      puts "Processing heading anchors for #{page.output_path}"
      input.gsub(/(<h[1-6])>(.*?)(<\/h[1-6]>)/) do |_|
        pre, content, post = $1, $2, $3
        anchor = content.gsub(' ', '_')
        %Q|#{pre} id="#{anchor}" onclick="window.location = '##{anchor}'">#{content}#{post}|
      end
    else
      input
    end
  end
end
