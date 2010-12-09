module WorksHelper
  def display_content(work)
    body = work.content.split(/\n/).collect do |line|
      %(<p class="poem-line">) + line + %(</p>)
    end.join
    (%(<div class="poem">) + body + %(</div>)).html_safe
  end
end
