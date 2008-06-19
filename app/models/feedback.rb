class Feedback < ActiveRecord::Base

  Engines.plugins[:mephisto_feedback].add_tab('Feedback', :controller => 'feedback')
  Engines.plugins[:mephisto_feedback].option :no_feedback_msg, "You don't seem to have any feedback."
  Engines.plugins[:mephisto_feedback].option :destroy_msg, "Feedback deleted."
  Engines.plugins[:mephisto_feedback].option :clear_msg, "All feedback has been cleared."

  belongs_to :site
  attr_protected :site_id
  validates_presence_of :site_id
  @@default_keys = %w(key)
  
  def self.create_from(site, params)
    order = params.delete(:order)
    order = order ? order.split(',') : (params.keys - @@default_keys)
    params[:body] = (order.inject([]) { |memo, key| memo << "#{key.to_s.humanize}:" << params.delete(key) << '' } << '' << params[:body]).join("\n")
    @@default_keys.each { |key| params[key] = 'n/a' if params[key].blank? }
    feedback = new(params)
    feedback.site_id = site.id
    feedback.save!
  end

  def self.create_error_from(site, params, exception)
    error = ["[#{exception.class.name}] #{exception.message}"]
    error.push *exception.backtrace.collect { |b| " > #{b}" }
    error.push *params.collect { |(key, value)| "#{key}: #{value}" }
    feedback = new(:name => 'Error', :key => (params[:key] || 'error'), :body => error.join("\n"))
    feedback.site_id = site.id
    feedback.save!
  end
    
end