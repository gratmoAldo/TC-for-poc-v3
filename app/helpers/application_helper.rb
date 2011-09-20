# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def text_field_for(form, field, size=HTML_TEXT_FIELD_SIZE, maxlength=DB_STRING_MAX_LENGTH)
    form_field = form.text_field field, :size => size, :maxlength => maxlength
    content_tag("tr", content_tag("td", "#{field.humanize}", :class => 'label') + content_tag("td", "#{form_field}"))
  end
  def text_area_for(form, field)
    form_field = form.text_area field
    content_tag("tr", content_tag("td", "#{field.humanize}", :class => 'label') + content_tag("td", "#{form_field}"))
  end
  def content2_tag_for(tag_name, record, *args, &block)
    prefix  = args.first.is_a?(Hash) ? nil : args.shift
    options = args.extract_options!
    options.merge!({ :class => "#{dom_class(record, prefix)} #{options[:class]}".strip, :id => dom_id(record, prefix) })
    content_tag(tag_name, options, &block)
  end

  def format_comment(content)
    simple_format(keep_spaces_at_beginning(h(content)))
  end
  
  def keep_spaces_at_beginning(content)
    content.split("\n").map do |line|
      line.sub(/^ +/) do |spaces|
        '&nbsp;' * spaces.length
      end
    end.join("\n")
  end
end
