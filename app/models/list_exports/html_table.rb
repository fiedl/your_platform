# This wrapper can be used when a html table already exists
# that can be used as template for an excel or csv export.
#
class ListExports::HtmlTable < ListExports::Base

  def html_data
    data
  end

  def table_rows
    rows = []
    doc = Nokogiri::HTML(html_data)
    doc.xpath('//table/*/tr').each do |row|
      tarray = []
      row.xpath('th', 'td').each do |cell|
        tarray << cell.text
      end
      rows << tarray
    end
    rows
  end

  def csv_data
    doc = Nokogiri::HTML(html_data)
    CSV.generate do |csv|
      table_rows.each do |row|
        csv << row
      end
    end
  end

  def to_csv
    byte_order_mark + csv_data
  end

  def to_xls
    Excelinator.csv_to_xls(csv_data)
  end

end