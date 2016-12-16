require 'prawn/measurement_extensions'

class AddressLabelsPdf < Prawn::Document

  def book_rate_line(address_label)
    move_up 2.mm
    address_label.kind_of?(AddressLabel) || raise('Expected AddressLabel, got String. This might be caused by a change of interface. Please call `uncached(:members_postal_addresses)` on all Groups.')
    book_rate_text = (address_label.country_code == "DE") ? "BÜCHERSENDUNG" : "ENVOIS À TAXE RÉDUITE"
    text "<b>#{book_rate_text}</b>", size: 12.pt, inline_format: true
    move_down 1.mm
  end

  def sender_line
    text "<u>#{@sender}</u>", size: sender_line_font_size, inline_format: true
    move_down 2.mm
  end

  def sender_line_font_size
    5.pt
  end

  # This method is to adjust the font size according to the number of lines
  # required in order to have all addresses fit into their box, but have the
  # font as large as possible.
  #
  def text_size(str, book_rate = false)
    if book_rate
      # If there is a "book rate" badge, the actual address text needs to be smaller.
      if str.present?
        return 10.pt if num_of_lines_required(str, 12.pt) < 5
        return 8.pt if num_of_lines_required(str, 10.pt) < 6
        return 6.pt if num_of_lines_required(str, 8.pt) < 8
      end
      return 5.pt
    else
      if str.present?
        return 12.pt if num_of_lines_required(str, 12.pt) < 5
        return 10.pt if num_of_lines_required(str, 10.pt) < 6
        return 8.pt if num_of_lines_required(str, 8.pt) < 8
      end
      return 7.pt
    end
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
    ["dejavu", "times", 'kai']
  end

  def font_directory
    # We have copied the fonts from:
    # https://github.com/prawnpdf/prawn/tree/master/data/fonts
    #
    # This way, we could list the font license here:
    # https://github.com/fiedl/your_platform/tree/master/vendor/assets/fonts
    #
    # Formerly: `@font_directory ||= "#{Prawn::BASEDIR}/data/fonts"`
    #
    @font_directory ||= YourPlatform::Engine.root.join('vendor/assets/fonts').to_s
  end

  def define_fonts
    # The idea to use fallback fonts to have chinese characters supported along
    # with other UTF-8 characters, was taken from:
    # http://stackoverflow.com/a/11097644/2066546

    # action_man_path = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
    kai = "#{font_directory}/gkai00mp.ttf"
    dejavu = "#{font_directory}/DejaVuSans.ttf"

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

    # font_families.update("action_man" => {
    #   :normal      => { :file => action_man_path, :font => "ActionMan" },
    #   :italic      => { :file => action_man_path, :font => "ActionMan-Italic" },
    #   :bold        => { :file => action_man_path, :font => "ActionMan-Bold" },
    #   :bold_italic => { :file => action_man_path, :font => "ActionMan-BoldItalic" }
    # })

    font_families.update("kai" => {
      :normal => { :file => kai, :font => "Kai" },
      :bold   => kai,
      :italic => kai,
      :bold_italic => kai
    })
  end
end