class ProtocolsController < ApplicationController
  before_action :set_protocol, only: [:show, :edit, :update, :destroy]

  def index
    @protocols = Protocol.all
  end

  def show
  end

  def new
    @protocol = Protocol.new
  end

  def edit
  end

  def create
    @protocol = Protocol.new(protocol_params)
    @protocol.principal_investigator = current_user

    if @protocol.save
      redirect_to @protocol, notice: t('.success')
    else
      render :new
    end
  end

  def update
    @protocol.version += 0.001
    if @protocol.update(protocol_params)
      redirect_to @protocol, notice: t('.success')
    else
      render :edit
    end
  end

  def destroy
    @protocol.destroy
    redirect_to protocols_url, notice: t('.success')
  end

  private

    def set_protocol
      @protocol = Protocol.find(params[:id])
    end

    def protocol_params
      params.require(:protocol).permit(:title)
    end
end
