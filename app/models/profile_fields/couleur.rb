# Format:
#
#     value: "schwarz-weiß-gold"
#     value: "schwarz-weiß-gold auf gold"
#     value: "schwarz-weiß-gold auf gold, Perkussion silber-silber"
#     value: "schwarz-weiß-gold auf gold, Perkussion silber-silber, von unten getragen"
#
class ProfileFields::Couleur < ProfileField

  def self.model_name
    ProfileField.model_name
  end

  def set(colors:, percussion_colors: nil, ground_color: nil, reverse: false)
    self.value = colors.join("-")
    self.value = "#{self.value} auf #{ground_color}" if ground_color
    self.value = "#{self.value}, Perkussion #{percussion_colors.join("-")}" if percussion_colors
    self.value = "#{self.value}, von unten getragen" if reverse
  end

  def colors
    value.split(", ").first.split(" auf ").first.split("-")
  end

  def ground_color
    value.split(", ").first.split(" auf ").second
  end

  def percussion_colors
    value.split(", ").detect { |str| str.include? "Perkussion" }.try(:gsub, "Perkussion ", "").try(:split, "-") || []
  end

  def reverse
    value.include?("von unten getragen").to_b
  end

  def apparent_colors
    array = self.colors
    array = [ground_color] + array + [ground_color] if ground_color.present?
    array = [percussion_colors.first] + array + [percussion_colors.last] if percussion_colors.present?
    array = array.reverse if self.reverse
    array
  end

  def as_json(*args)
    super.merge({
      colors: colors,
      percussion_colors: percussion_colors,
      ground_color: ground_color,
      reverse: reverse,
      apparent_colors: apparent_colors
    })
  end

  def self.colors
    [
      {name: "Schwarz", hex: "#000000"},
      {name: "Weiß", hex: "#ffffff"},
      {name: "Gold", hex: "#c2a952"},
      {name: "Altgold", hex: "#99893D"},
      {name: "Silber", hex: "#999999"},
      {name: "Rot", hex: "#c71d19"},
      {name: "Dunkelrot", hex: "#991914"},
      {name: "Weinrot", hex: "#661F44"},
      {name: "Karmesinrot", hex: "#E72274"},
      {name: "Purpur", hex: "#E72274"},
      {name: "Violett", hex: "#841F82"},
      {name: "Blau", hex: "#1100bd"},
      {name: "Kornblumenblau", hex: "#263688"},
      {name: "Hellblau", hex: "#62b0fe"},
      {name: "Hellblau (Siegen)", hex: "#3fa7cd"},
      {name: "Hellblau (Hohenheim)", hex: "#0bddf9"},
      {name: "Lila", hex: "#b960e5"},
      {name: "Grün", hex: "#136736"},
      {name: "Keine", hex: nil}
    ]
  end

end