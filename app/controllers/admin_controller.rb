class AdminController < ApplicationController
  before_filter :require_admin_or_trustee
  
  def index
    @users = User.all(:limit => 25, :order => 'id desc')
    @taxes = Tax.all
    @transactions = Transaction.all(:order => 'id desc')
    @comments = Comment.all(:order => 'id desc')    
  end
  
  def invite
    redirect_to admin_path, :notice => "You need to enter an email and name." and return if params[:email].blank? or params[:name].blank?
    
    if params[:tax_id]
      tax = Tax.find params[:tax_id]
      redirect_to admin_path, :notice => "You can't invite to that tax." and return unless admin? or tax.managers.include? current_user
    else
      tax = nil
    end
    
    if exists = User.find_by_email(params[:email])
      exists.update_attribute(:status, User::TRUSTEE) unless exists.status == User::ADMIN
      if tax
        tax.managers << exists
        redirect_to root_path, :notice => "Added #{params[:email]} to the tax."
      else
        redirect_to root_path, :notice => "That email is already registered. Making sure they have trustee status now!"
      end
    else
      User.invite!({:email => params[:email], :name => params[:name]}, current_user)
      invited = User.last
      invited.update_attributes({:status => User::TRUSTEE, :bio => params[:bio]})
      redirect_to root_path, :notice => "Sent invitation to #{params[:email]}."
      tax.managers << invited
    end
    
  end
  
end
