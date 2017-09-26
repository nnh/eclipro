class ContentsController < ApplicationController
  before_action :set_protocol
  before_action :set_content, except: [:show, :next, :previous]
  load_and_authorize_resource

  def update
    content_params[:body].gsub!(/ style="height: .+px;"/, '')
    content_params[:body].gsub!(/\r/, '')
    Content.transaction do
      Protocol.transaction do
        @content.assign_attributes(content_params)
        if @content.changed?
          @content.status = 'in_progress'
          @content.save!
          @protocol.version += 0.001
          @protocol.save!
          flash[:notice] = t('.success')
        else
          flash[:warning] = t('.no_change')
        end
      end
    end
  rescue => e
    if e.class == ActiveRecord::StaleObjectError
      flash[:alert] = t('.lock_error')
    else
      flash[:alert] = t('.failure')
    end
  end

  def history
  end

  def compare
    body = @content.versions[params[:index].to_i].changeset[:body]
    @compare = Content.diff(body[0], body[1])
    @compare.gsub!('contenteditable="true"', '')
  end

  def revert
    Content.transaction do
      Protocol.transaction do
        @content = @content.versions[params[:index].to_i].reify
        @content.lock_version = params[:lock_version]
        @content.save!
        @protocol.version += 0.001
        @protocol.save!
        flash[:notice] = t('.success')
      end
    end
  rescue => e
    if e.class == ActiveRecord::StaleObjectError
      flash[:alert] = t('.lock_error')
    else
      flash[:alert] = t('.failure')
    end
  end

  def change_status
    if @content.update(content_params)
      flash[:notice] = t('.success')
    else
      flash[:alert] = t('.failure')
    end
  end

  def show
    @content = @protocol.contents.find_by(no: params[:section_no])
  end

  def next
    sections = Section.sorted_menu(@protocol.template_name)
    index = sections.index(params[:section_no])
    if index == sections.size - 1
      head :ok
    else
      index += 1
      if sections[index] == 'compliance'
        @content = sections[index]
      else
        @content = @protocol.contents.find_by(no: sections[index])
      end
      render :move_section
    end
  end

  def previous
    sections = Section.sorted_menu(@protocol.template_name)
    index = sections.index(params[:section_no])
    if index == 0
      head :ok
    else
      index -= 1
      if sections[index] == 'compliance' ||  sections[index] == 'title'
        @content = sections[index]
      else
        @content = @protocol.contents.find_by(no: sections[index])
      end
      render :move_section
    end
  end

  private
    def set_content
      @content = Content.find(params[:id])
    end

    def set_protocol
      @protocol = Protocol.find(params[:protocol_id])
    end

    def content_params
      params.require(:content).permit(:body, :status, :lock_version)
    end
end
