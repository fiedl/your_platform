# This helper abstracts the several markup methods
# into one method `markup()`.
#
# For example, on a Page, use:
#
#   <div id="content">
#     <%= markup(@page.content) %>
#   </div>
#
module MarkupHelper

  def markup(text)
    if text
      unless text.downcase.include?("<html>") or text.downcase.include?("<html ")
        emojify markdown replace_quick_link_tags mentionify replace_video_links youtubify text
      else
        strip_escaped_comments sanitize text
      end
    end
  end

  def page_markup(text)
    markup_and_email_scrambler text
  end

  def strip_escaped_comments(text)
    # Strip comments from outlook, like
    # "<style><!--\n/* Font Definitions */\n@font-face\n\t{font-family:\"Cambria Math\";\n\tpanose-1:2 4 5 3 5 4 6 3 2 4;}\n@font-face\n\t{font-family:Calibri;\n\tpanose-1:2 15 5 2 2 2 4 3 2 4;}\n@font-face\n\t{font-family:Tahoma;\n\tpanose-1:2 11 6 4 3 5 4 4 2 4;}\n@font-face\n\t{font-family:Garamond;\n\tpanose-1:2 2 4 4 3 3 1 1 8 3;}\n/* Style Definitions */\np.MsoNormal, li.MsoNormal, div.MsoNormal\n\t{margin:0cm;\n\tmargin-bottom:.0001pt;\n\tfont-size:11.0pt;\n\tfont-family:\"Calibri\",\"sans-serif\";}\na:link, span.MsoHyperlink\n\t{mso-style-priority:99;\n\tcolor:blue;\n\ttext-decoration:underline;}\na:visited, span.MsoHyperlinkFollowed\n\t{mso-style-priority:99;\n\tcolor:purple;\n\ttext-decoration:underline;}\np.MsoAcetate, li.MsoAcetate, div.MsoAcetate\n\t{mso-style-priority:99;\n\tmso-style-link:\"Sprechblasentext Zchn\";\n\tmargin:0cm;\n\tmargin-bottom:.0001pt;\n\tfont-size:8.0pt;\n\tfont-family:\"Tahoma\",\"sans-serif\";}\nspan.E-MailFormatvorlage17\n\t{mso-style-type:personal-compose;\n\tfont-family:\"Calibri\",\"sans-serif\";\n\tcolor:windowtext;}\nspan.SprechblasentextZchn\n\t{mso-style-name:\"Sprechblasentext Zchn\";\n\tmso-style-priority:99;\n\tmso-style-link:Sprechblasentext;\n\tfont-family:\"Tahoma\",\"sans-serif\";}\n.MsoChpDefault\n\t{mso-style-type:export-only;}\n@page WordSection1\n\t{size:612.0pt 792.0pt;\n\tmargin:70.85pt 70.85pt 2.0cm 70.85pt;}\ndiv.WordSection1\n\t{page:WordSection1;}\n--></style>"
    text.gsub(/&lt;!--[^<>]*--&gt;/im, "").html_safe
  end

end

# In order to use the markup helper method with best_in_place's :display_with argument,
# the ActionView::Base has to include the markup method.
#
module ActionView
  class Base
    include MarkupHelper
  end
end
