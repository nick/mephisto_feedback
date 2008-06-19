module Admin
  class FeedbackController < Admin::BaseController

    skip_before_filter :login_required
    before_filter :login_required, :except => :create
    member_actions << 'index' << 'show'

    def index
      conditions = returning [['site_id = ?'], "#{site.id}"] do |cond|
        unless params[:key].blank?
          cond.first << "#{Feedback.connection.quote_column_name :key} = ?"
          cond       << params[:key]
        end
        unless params[:name].blank?
          cond.first << 'name LIKE ? OR email LIKE ?'
          cond       << "#{params[:name]}%" << "#{params[:name]}%"
        end
        unless params[:q].blank?
          cond.first << 'body LIKE ?'
          cond       << "%#{params[:body]}%"
        end
        cond.unshift cond.shift.join(" OR ") if cond.first.any?
      end
      @feedbacks = Feedback.paginate \
        :page => params[:page],
        :per_page => 50,
        :order => 'created_at desc',
        :conditions => conditions.first.blank? ? nil : conditions
    end
    
    def show
      @feedback = Feedback.find(params[:id], :conditions => ['site_id = ?', site.id] )
    end
    
    def destroy
      Feedback.delete_all(['site_id = ? and id = ?', site.id, params[:id]])
      flash[:notice] = Engines.plugins[:mephisto_feedback].destroy_msg
      redirect_to :action => 'index'
    end
    
    def clear
      Feedback.delete_all(['site_id = ?', site.id])
      flash[:notice] = Engines.plugins[:mephisto_feedback].clear_msg
      redirect_to :action => 'index'
    end
    
    def create
      Feedback.create_from(site, params[:feedback]) if params[:feedback]
    rescue
      Feedback.create_error_from(site, params[:feedback] || {}, $!)
    end
  end
end