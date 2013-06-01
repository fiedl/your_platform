module SpecialPagesHelper

    def link_to_special_page(body, flag, html_options = {})
        special_page = Page.find_by_flag( flag )
        special_page ||= "#"
        link_to body, special_page, html_options
    end

end
