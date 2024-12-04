# frozen_string_literal: true

xml.instruct!
xml.rss version: '2.0', 'xmlns:atom': 'http://w3.org/2005/Atom', 'xmlns:georss': 'http://www.georss.org/georss' do
  xml.channel do
    xml.title Settings::Instance.name
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: request.url
    xml.link root_url
    xml.description t('.feed_description', name: Settings::Instance.name)
    xml.language 'de-de'
    @issues.each do |i|
      xml.item do
        issue_url = edit_issue_url(i)
        xml.title "##{i.id} #{i.main_category.kind_name} (#{i.main_category} – #{i.sub_category})"
        xml.description do
          html_cont = <<-HTML
            <b>#{Issue.human_attribute_name(:status)}:</b> #{i.human_enum_name(:status)}<br/>
            <b>#{Issue.human_attribute_name(:status_note)}:</b> #{!i.status_note.to_s == '' ? i.status_note : t('.status_note_not_available')}<br/>
            <b>#{Issue.human_attribute_name(:address)}:</b> #{i.address}<br/>
            <b>#{Issue.human_attribute_name(:property_owner)}:</b> #{i.property_owner}<br/>
            <b>#{Issue.human_attribute_name(:supporter)}:</b> #{i.supporters.size.positive? ? i.supporters.size : t('.no_supporters')}<br/>
            <b>#{Issue.human_attribute_name(:description)}:</b> #{i.description}<br/>
            <b>#{Issue.human_attribute_name(Issue.human_attribute_name(:media_url))}:</b><br/>
          HTML
          i.photos.each do |photo|
            html_cont << image_tag(photo.file.variant(resize_to_limit: [360, 360]),
              alt: Issue.human_attribute_name(:media_url), class: 'rounded img-fluid')
            html_cont << '<br/>'
          end
          html_cont << link_to(t('.link', name: Settings::Instance.name), issue_url, target: '_blank', rel: 'noopener')
          xml.cdata! html_cont
        end
        xml.georss :point, "#{i.position.y} #{i.position.x}"
        xml.link issue_url
        xml.guid issue_url
        xml.pubDate i.created_at.rfc2822
      end
    end
  end
end
