module ApplicationHelper
  def page_title
    extra = @title ? " | " + @title : ""
    "Non-Sense Engine" + extra
  end
end
