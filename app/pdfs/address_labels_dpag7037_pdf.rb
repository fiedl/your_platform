class AddressLabelsDpag7037Pdf < AddressLabelsPdf
  
  # address_label:    Array of AddressLabel objects. When calling `addresses[i].to_s`, the i-th 
  #                   address is returned as String.
  # options:
  #   - title:        The title of the document, e.g. "Addresses of all CEOs".
  #   - updated_at:   Timestamp that indicates the date of last modification.
  #   - sender:       Sender line of the address label.
  #   - book_rate:    Whether the package is to be sent as "press and books".
  #                   When sent to Germany, this results in the badge "Büchersendung".
  #                   When sent to other countries, the international "Envois à taxe réduite" is used.
  #
  def initialize(address_labels, options = {title: '', updated_at: Time.zone.now, sender: '', book_rate: false})
    super(page_size: 'A4', top_margin: 0.mm, bottom_margin: 0.mm, left_margin: 0.mm, right_margin: 0.mm)
    
    @document_title = options[:title]
    @document_updated_at = options[:updated_at]
    @required_page_count = (address_labels.count / 24).round + 1
    @sender = options[:sender]
    @book_rate = options[:book_rate]
    @export_user = options[:export_user]
    
    cover_page 
    start_new_page
    
    define_grid columns: 3, rows: 8
    
    for p in (0..(@required_page_count - 1))
      for y in 0..7
       for x in 0..2
         grid(y, x).bounding_box do

           # 4mm padding within each grid cell, which itself is 70x37mm^2.
           # 
           # PDF documents have the origin [0,0] at the bottom-left corner of the
           # page.
           # 
           # A bounding box is a structure which provides boundaries for inserting
           # content. A bounding box also has the property of relocating the origin
           # to its relative bottom-left corner. However, be aware that the location
           # specified when creating a bounding box is its top-left corner, not
           # bottom-left.
           # 
           # See: http://prawnpdf.org/manual.pdf
           #            
           bounding_box [4.mm, 37.mm-4.mm], width: 70.mm-4.mm-4.mm, height: 37.mm-4.mm-4.mm do
             # stroke_bounds
             
             font "Helvetica" do
               address_label = address_labels[p * 24 + y * 3 + x]
               if address_label
                 address = address_label.compact.versalize_abroad.to_s
                 
                 book_rate_line(address_label) if @book_rate and address_label
                 sender_line if @sender and address.to_s.present?
                 
                 address.gsub!("\nDeutschland", "") if I18n.locale == :de # in order to save space for in-country deliveries.
                 
                 begin
                   text address.to_s, size: 10.pt, fallback_fonts: fallback_fonts
                 rescue Prawn::Errors::IncompatibleStringEncoding
                   logger.warn "PDF ADDRESS LABEL EXPORT ENCODING ISSUE for #{address_label.name}."
                   text "ENCODING ISSUE!"
                 end
               end
             end
           end
         end
       end
      end
      start_new_page if p < (@required_page_count - 1)
    end
    
    # grid.show_all
  end
  
  def cover_page
    move_down 4.cm
    text I18n.t(:address_labels), align: :center, size: 18

    move_down 1.cm
    text AppVersion.app_name                                        , align: :center, size: 14
    
    move_down 0.5.cm
    text "#{I18n.t(:group)}: #{@document_title}"                    , align: :center, size: 14, style: :bold
    text "#{I18n.t(:last_update)}: #{I18n.l(@document_updated_at)}" , align: :center, size: 14
    
    move_down 0.5.cm
    text "#{I18n.t(:format)}: DIN-A4, DPAG 70x37"                   , align: :center, size: 14
    text I18n.t(:compact_address_format)                            , align: :center, size: 14

    move_down 0.5.cm
    text "#{I18n.t(:exported_by)}: #{@export_user.title}"           , align: :center, size: 14
    text I18n.localize(Time.zone.now)                               , align: :center, size: 14
  end
  
  def sender_line_font_size
    6.pt
  end
  
  def book_rate_line(address_label)
    book_rate_text = (address_label.country_code == "DE") ? "BÜCHERSENDUNG" : "ENVOIS À TAXE RÉDUITE"
    text book_rate_text, size: 10.pt, inline_format: true, style: :bold
  end
  
end