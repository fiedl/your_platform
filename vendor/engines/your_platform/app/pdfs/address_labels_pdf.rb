require 'prawn/measurement_extensions'

class AddressLabelsPdf < Prawn::Document
  
  def initialize(addresses, options = {title: '', updated_at: Time.zone.now, sender: ''})
    super(page_size: 'A4', top_margin: 8.mm, bottom_margin: 8.mm, left_margin: 10.mm, right_margin: 10.mm)
    
    @document_title = options[:title]
    @document_updated_at = options[:updated_at]
    @required_page_count = (addresses.count / 24).round + 1
    @sender = options[:sender]
    
    define_grid columns: 3, rows: 8, gutter: 10.mm
    
    for p in (0..(@required_page_count - 1))
      page_header
      page_footer
      
      for y in 0..7
       for x in 0..2
         grid(y, x).bounding_box do
           address = addresses[p * 24 + y * 3 + x]
           address = address.try(:gsub, ", ", "\n")
           sender_line if @sender and address
           text address, size: text_size(address), fallback_fonts: fallback_fonts
         end
       end
      end
      start_new_page if p < (@required_page_count - 1)
    end
    
    # grid.show_all
  end
  
  def sender_line
    text "<u>#{@sender}</u>", size: 5.pt, inline_format: true
    move_down 2.mm
  end
  
  # This method is to adjust the font size according to the number of lines
  # required in order to have all addresses fit into their box, but have the
  # font as large as possible.
  #
  def text_size(str)
    if str.present?
      return 12.pt if num_of_lines_required(str, 12.pt) < 5
      return 10.pt if num_of_lines_required(str, 10.pt) < 6
      return 8.pt if num_of_lines_required(str, 8.pt) < 8
    end
    return 7.pt
  end
  
  # This method estimates the number of lines required for the given string.
  # Some lines are longer than 35 characters and they will broken into the
  # new line in the PDF. Therefore we need this estimate.
  #
  def num_of_lines_required(str, font_size = 12.pt)
    @available_width ||= (210.mm - 20.mm - 2 * 10.mm)/3
    if str.present?
      str.lines.collect { |line| (width_of(line, size: font_size) / @available_width).floor + 1 }.sum
    else
      0
    end
  end
    
  def page_header_text
    "Druck auf Zweckform 3475, 70x36 mm², 24 Stk pro Blatt, DIN-A4. Skalierung auf 100% stellen!"
  end
  def page_header
    bounding_box([0, 28.85.cm], width: 18.5.cm, height: 0.5.cm) do
      text page_header_text, size: 8.pt, align: :center
    end
  end
  def page_footer_text
    "#{Rails.application.class.parent_name}: #{@document_title}, Datenstand: #{I18n.localize(@document_updated_at)}, Seite #{page_number} von #{@required_page_count}"
  end
  def page_footer
    bounding_box([0, -0.5.cm], width: 18.5.cm, height: 0.5.cm) do
      text page_footer_text, size: 8.pt, align: :center
    end
  end
  
  def fallback_fonts
    define_fonts
    ["dejavu", "times", 'kai', 'action_man']
  end
  
  def define_fonts
    # The idea to use fallback fonts to have chinese characters supported along
    # with other UTF-8 characters, was taken from:
    # http://stackoverflow.com/a/11097644/2066546
    
    kai = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
    action_man_path = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
    dejavu = "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

    font_families.update("dejavu" => {
      :normal      => dejavu,
      :italic      => dejavu,
      :bold        => dejavu,
      :bold_italic => dejavu
    })

    #Times is defined in prawn
    font_families.update("times" => {
      :normal => "Times-Roman",
      :italic      => "Times-Italic",
      :bold        => "Times-Bold",
      :bold_italic => "Times-BoldItalic"
    })

    font_families.update("action_man" => {
      :normal      => { :file => action_man_path, :font => "ActionMan" },
      :italic      => { :file => action_man_path, :font => "ActionMan-Italic" },
      :bold        => { :file => action_man_path, :font => "ActionMan-Bold" },
      :bold_italic => { :file => action_man_path, :font => "ActionMan-BoldItalic" }
    })

    font_families.update("kai" => {
      :normal => { :file => kai, :font => "Kai" },
      :bold   => kai,
      :italic => kai,
      :bold_italic => kai
    })
  end
end