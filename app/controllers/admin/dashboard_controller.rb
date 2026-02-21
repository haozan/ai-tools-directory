class Admin::DashboardController < Admin::BaseController
  def index
    @admin_count = Administrator.all.size
    @recent_logs = AdminOplog.includes(:administrator).order(created_at: :desc).limit(5)

    @show_password_change_modal = current_admin&.first_login? && Rails.env.production?
  end

  def sync_data
    results = DataSyncService.new.call
    
    if results[:error]
      flash[:error] = "同步失败: #{results[:error]}"
    else
      success_message = []
      success_message << "分类: 新增#{results[:categories][:created]}个, 更新#{results[:categories][:updated]}个, 删除#{results[:categories][:deleted]}个"
      success_message << "工具: 新增#{results[:tools][:created]}个, 更新#{results[:tools][:updated]}个, 删除#{results[:tools][:deleted]}个"
      success_message << "关联: 新增#{results[:associations][:created]}个"
      
      flash[:success] = "数据同步成功！#{success_message.join('; ')}"
      
      # 记录错误信息（如果有）
      if results[:categories][:errors].any? || results[:tools][:errors].any? || results[:associations][:errors].any?
        all_errors = results[:categories][:errors] + results[:tools][:errors] + results[:associations][:errors]
        flash[:warning] = "部分数据同步失败: #{all_errors.join('; ')}"
      end
    end
    
    redirect_to admin_root_path
  end
end
