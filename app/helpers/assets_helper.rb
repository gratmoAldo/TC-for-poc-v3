module AssetsHelper
  def table_row(leftval, rightval)
    content_tag("tr", content_tag("td",leftval,:class=>"label")+content_tag("td",rightval))
  end
end
