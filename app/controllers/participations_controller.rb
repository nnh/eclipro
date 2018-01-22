class ParticipationsController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource through: :protocol

  def new
  end

  def create
    if @participation.save
      redirect_to @protocol, notice: t('.success')
    else
      render :new
    end
  end

  def destroy
    if @participation.destroy
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, alert: @participation.errors.full_messages.join(',')
    end
  end

  private

    def participation_params
      params.require(:participation).permit(:protocol_id, :user_id, :role, sections: [])
    end
end
