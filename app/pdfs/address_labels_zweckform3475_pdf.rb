class AddressLabelsZweckform3475Pdf < AddressLabelsPdf

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
    super(page_size: 'A4', top_margin: 8.mm, bottom_margin: 8.mm, left_margin: 10.mm, right_margin: 10.mm)

    @document_title = options[:title]
    @document_updated_at = options[:updated_at]
    @required_page_count = (address_labels.count / 24).round + 1
    @sender = options[:sender]
    @book_rate = options[:book_rate]

    define_grid columns: 3, rows: 8, gutter: 10.mm

    for p in (0..(@required_page_count - 1))
      page_header
      page_footer

      for y in 0..7
       for x in 0..2
         grid(y, x).bounding_box do
           address_label = address_labels[p * 24 + y * 3 + x]
           address = address_label.to_s.gsub(", ", "\n")
           book_rate_line(address_label) if @book_rate and address_label
           sender_line if @sender and address.to_s.present?
           address.gsub!("\nDeutschland", "") if I18n.locale == :de # in order to save space for in-country deliveries.

           begin
             text address.to_s, size: text_size(address.to_s, @book_rate), fallback_fonts: fallback_fonts
           rescue Prawn::Errors::IncompatibleStringEncoding => e
             text "Die Adresse von #{address_label.name} enthält nicht-darstellbare Zeichen."
           end
         end
       end
      end
      start_new_page if p < (@required_page_count - 1)
    end

    # grid.show_all
  end

  def page_header_text
    "Druck auf Zweckform 3475, 70x36 mm², 24 Stk pro Blatt, DIN-A4. Skalierung auf 100% stellen!"
  end
  def page_header
    bounding_box([0, 28.85.cm], width: 18.5.cm, height: 0.5.cm) do
      text page_header_text, size: 8.pt, align: :center
    end
  end

end