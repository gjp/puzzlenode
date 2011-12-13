module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title }
  end

  def md(content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :autolink            => true,
      :space_after_headers => true,
      :no_intra_emphasis   => true,
      :fenced_code_blocks  => true)

    markdown.render(content).html_safe
  end

  # Straight out of Railscast 228 & 240
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title,
      params.merge(:sort => column, :direction => direction, :page => nil),
      {:class => css_class}
  end

end
