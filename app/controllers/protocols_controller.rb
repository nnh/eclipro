class ProtocolsController < ApplicationController
  before_action :set_protocol, only: [:show, :edit, :update, :destroy]

  def index
    # TODO: 権限
    @protocols = Protocol.all
  end

  def show
    @contents = @protocol.contents.order(:created_at)
    @examples = Section.select { |s| s.example.present? }
    @instructions = Section.select { |s| s.instructions.present? }
  end

  def new
    @protocol = Protocol.new
  end

  def edit
  end

  def create
    @protocol = Protocol.new(protocol_params)
    @protocol.principal_investigator = current_user

    section_no = Section.pluck(:no)
    section_no.each do |no|
      section = Section.find_by(no: no)
      @protocol.contents << Content.new(protocol: @protocol, no: no, title: section.title,
                                        body: section.template, editable: section.editable)
    end

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
      params.require(:protocol).permit(
        :title,
        :short_title,
        :protocol_number,
        :nct_number,
        :sponsor_other,
        :entity_funding_name,
        :has_ide,
        :has_ind,
        :compliance,
        sponsors: [],
        study_agent: []
      )
    end
end
