module FormatHelper
  def format_date( date )
    date.strftime( '%A, %B %e, %Y' ) if date
  end
end
    
    
