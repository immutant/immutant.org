module FormatHelper
  def format_date( date )
    date.strftime( '%A, %B %e, %Y' ) if date
  end

  def author( page )
    author = page.author || "The Immutant Team"
    if page.author_url
      %Q{<a href="#{page.author_url}">#{author}</a>}
    else
      author
    end
  end
end
