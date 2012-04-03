module BoxHelper

  def content_box( args, &block ) # :heading
    content = with_output_buffer( &block )
    render :partial => "shared/box", :locals => { :heading => args[:heading], :content => content }
  end

end
