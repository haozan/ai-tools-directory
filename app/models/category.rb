class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  # Self-referential associations for nested categories
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  
  # Tool associations
  has_many :tool_categories, dependent: :destroy
  has_many :tools, through: :tool_categories
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validates :slug, uniqueness: true
  validate :prevent_circular_reference
  
  # Scopes
  scope :with_tools, -> { where('tools_count > 0') }
  scope :popular, -> { order(Arel.sql('CASE WHEN position IS NULL THEN 1 ELSE 0 END, position ASC, tools_count DESC')) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :child_categories, -> { where.not(parent_id: nil) }
  
  def update_tools_count!
    update(tools_count: tools.count)
  end
  
  # Check if this category is a root category
  def root?
    parent_id.nil?
  end
  
  # Check if this category has children
  def has_children?
    children.any?
  end
  
  # Get all ancestor categories (parent, grandparent, etc.)
  def ancestors
    return [] if root?
    [parent] + parent.ancestors
  end
  
  # Get all descendant categories (children, grandchildren, etc.)
  def descendants
    children + children.flat_map(&:descendants)
  end
  
  # Get the full path of category names (e.g., "法律文书 > 合同审查")
  def full_path(separator: ' > ')
    ancestors.reverse.map(&:name).push(name).join(separator)
  end
  
  # Get the level/depth of this category (root = 0, child = 1, etc.)
  def level
    ancestors.count
  end
  
  # Get all tools including tools from subcategories
  def all_tools
    if has_children?
      # Get direct tools + all tools from children
      tool_ids = tools.pluck(:id)
      children.each do |child|
        tool_ids += child.all_tools.pluck(:id)
      end
      Tool.where(id: tool_ids.uniq)
    else
      tools
    end
  end
  
  private
  
  # Prevent circular references in parent-child relationships
  def prevent_circular_reference
    return if parent_id.nil?
    
    if parent_id == id
      errors.add(:parent_id, "分类不能是自己的父分类")
    elsif ancestors.map(&:id).include?(id)
      errors.add(:parent_id, "分类不能形成循环引用")
    end
  end
end
