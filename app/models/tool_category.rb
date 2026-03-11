class ToolCategory < ApplicationRecord
  belongs_to :tool
  belongs_to :category

  validates :tool_id, uniqueness: { scope: :category_id }

  after_create  :update_category_count
  after_destroy :update_category_count

  private

  def update_category_count
    category.update_tools_count!
    # 同步更新父分类的汇总数
    category.parent&.update_tools_count!
  end
end
