class AttachmentsController < ApplicationController
  def index
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    respond_to do |format|
      if @attachment.save
        format.html { redirect_to :back, notice: 'Document was successfully created.' }
#        format.json { render json: @document, status: :created, location: @document }
#        format.js                                                                                                                   
      else
        format.html { redirect_to :back, error: 'Document was not successfully created.' }
#        format.html { render action: "new" }
#        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  def update
  end
end
