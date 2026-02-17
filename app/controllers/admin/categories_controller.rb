class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :load_parent_categories, only: [:new, :edit, :create, :update]

  def index
    @categories = Category.popular.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_category_path(@category), notice: 'Category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: 'Category was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: 'Category was successfully deleted.'
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
  
  def load_parent_categories
    # Load all categories except the current one (to prevent circular references)
    # For new records, show all. For edit, exclude self and descendants
    if @category&.persisted?
      excluded_ids = [@category.id] + @category.descendants.map(&:id)
      @parent_categories = Category.where.not(id: excluded_ids).order(:name)
    else
      @parent_categories = Category.order(:name)
    end
  end

  def category_params
    params.require(:category).permit(:name, :slug, :description, :tools_count, :parent_id, :position)
  end
end
