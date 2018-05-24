class SectionsController < ApplicationController
  load_and_authorize_resource

  def index
    @template_names = Section.template_names
    @divided_sections = []
    @template_names.each do |name|
      @divided_sections << @sections.where(template_name: name)
    end
  end

  def show
  end

  def edit
  end

  def update
    if @section.update(section_params)
      redirect_to section_path(@section), notice: t('.success')
    else
      render :edit
    end
  end

  private

  def section_params
    params.require(:section).permit(:title, :template, :instructions, :example, :editable)
  end
end
