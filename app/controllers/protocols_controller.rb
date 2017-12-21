class ProtocolsController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:protocol_name_filter].present?
      @protocols = @protocols.where('title like ?', "%#{params[:protocol_name_filter]}%")
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @protocol.participations.build(user: current_user, role: 'principal_investigator')

    if @protocol.contents.empty?
      sections = Section.reject_specified_sections(@protocol.template_name).sort_by { |c| c.no.to_f }
      sections.each do |section|
        @protocol.contents << Content.new(protocol: @protocol, no: section.no, title: section.title,
                                          body: section.template, editable: section.editable)
      end
    end

    if @protocol.save
      redirect_to protocol_content_path(@protocol, @protocol.contents.first, anchor: 'sections'), notice: t('.success')
    else
      render :new
    end
  end

  def update
    @protocol.update!(protocol_params)
    redirect_to @protocol, notice: @protocol.saved_changes? ? t('.success') : t('.no_change')
  rescue => ex
    flash.now[:alert] = t('.lock_error') if ex.is_a?(ActiveRecord::StaleObjectError)
    render :edit
  end

  def destroy
    @protocol.destroy
    redirect_to protocols_path, notice: t('.success')
  end

  def clone
    original = Protocol.find(params[:id])
    # TODO: fix clone team member
    @protocol = original.deep_clone(include: [:participations, :contents],
                                    expect: [{ participations: [:id] },
                                             { contents: %i[id status lock_version] }])
    @protocol.title = "#{original.title} - (COPY)"
    @protocol.short_title = "#{original.short_title} - (COPY)" if original.short_title.present?
  end

  def export
    @content_0 = @protocol.contents.find_by(no: '0')
    @contents = @protocol.contents.where.not(no: '0').sort_by { |c| c.no.to_f }

    respond_to do |format|
      format.pdf do
        render pdf: "#{@protocol.protocol_number}_v#{@protocol.version}",
               encording: 'UTF-8',
               layout: 'export.html',
               template: 'protocols/export',
               footer: {
                 center: '[page] / [topage]',
                 font_size: 9
               },
               viewport_size: '1280x1024',
               show_as_html: params[:debug].present?
      end

      format.docx do
        view_text = render_to_string template: 'protocols/export', layout: 'export.html'
        document = PandocRuby.convert(view_text.delete(' '), from: :html, to: :docx)
        send_data document,
                  filename: "#{@protocol.protocol_number}_v#{@protocol.version}.docx",
                  type: '	application/msword',
                  disposition: 'attachment'
      end
    end
  end

  def finalize
    if @protocol.finalized!
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, notice: t('.failure')
    end
  end

  def reinstate
    if @protocol.in_progress!
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, notice: t('.failure')
    end
  end

  private

    def protocol_params
      params.require(:protocol).permit(
        :lock_version,
        :template_name,
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
        study_agent: [],
        participations_attributes: [:id, :protocol_id, :user_id, :role, :_destroy, sections: []]
      )
    end
end
