class AttachmentsController < ApplicationController
  def index
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    respond_to do |format|
      if @attachment.save
        format.html { redirect_to :back, notice: 'Attachment was successfully created.' }
#        format.json { render json: @attachment, status: :created, location: @attachment }
#        format.js                                                                                                                   
      else
        format.html { redirect_to :back, error: 'Attachment was not successfully created.' }
#        format.html { render action: "new" }
#        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /attachments/1
  # PUT /attachments/1.json
  def update
    @attachment = Attachment.find(params[:id])

    respond_to do |format|
      if @attachment.update_attributes(params[:attachment])
        format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attachments/1
  # DELETE /attachments/1.json
  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end


end
