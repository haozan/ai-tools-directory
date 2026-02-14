class Admin::ResourcesController < Admin::BaseController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  def index
    @resources = Resource.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @resource = Resource.new
  end

  def create
    @resource = Resource.new(resource_params)

    if @resource.save
      redirect_to admin_resource_path(@resource), notice: 'Resource was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @resource.update(resource_params)
      redirect_to admin_resource_path(@resource), notice: 'Resource was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    redirect_to admin_resources_path, notice: 'Resource was successfully deleted.'
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:title, :description, :url, :category, :subscribers_count, :logo_url, :featured, :view_count)
  end
end
