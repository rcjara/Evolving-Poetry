module ApplicationHelper
  def carousel_id(obj)
    [obj.class.to_s, obj.id, "carousel"].join('-')
  end

  def carousel_next_link(obj)
    carousel_link(obj, "next")
  end

  def carousel_prev_link(obj)
    carousel_link(obj, "prev")
  end

  def carousel_link(obj, additional)
    link_to additional.capitalize, '#', :id => "#{carousel_id(obj)}-#{additional}"
  end

  def carousel_counter(obj)
    raw( %{<div class="carousel-counter" id="#{carousel_id(obj)}-counter"></div>} )
  end

  def page_title
    extra = @title ? " | " + @title : ""
    "Nonsense Engine" + extra
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

  def time_fmt(time)
    time.strftime("%I:%M %p")
  end
end
