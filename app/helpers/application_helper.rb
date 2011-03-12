module ApplicationHelper
  def page_title
    extra = @title ? " | " + @title : ""
    "Non-Sense Engine" + extra
  end

  def proper_list(array)
    if array.length > 1
      array[0...-1].join(", ") + " and " + array[-1]
    else
      array[0]
    end
  end

  def clear
    %{<div class="clear"></div>}.html_safe
  end

  def date_fmt(time)
    time.to_date.to_s(:long_ordinal)
  end
end
