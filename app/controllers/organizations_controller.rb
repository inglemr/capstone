class OrganizationsController < ApplicationController
  load_and_authorize_resource
  before_filter :load_permissions
  before_filter :organization_perms, :except => [:index, :new_organization_request,:create_organization_request, ]

  def remove_member

    temp = Organization.find(params[:id])
    if (current_user.organizations.include? temp) && ( @org_perms.include?("everything")  || @org_perms.include?("delete-member")  )
      @organization = Organization.find(params[:id])
      @user = User.find(params[:member_id])
      @organization.remove_member(@user)
      @form_type = "remove_member"
      @organization.create_activity action: 'remove_member', owner: @user
      respond_to do |format|
        format.js   { render 'member_page.js.erb', :flash => { 'success' => 'Member Removed.' }}
        format.html {  redirect_to :back , :flash => { 'success' => 'Member Removed.' }}
      end
    else
      redirect_to :back , :flash => { 'error' => 'Unauthorized.' }
    end
  end

  def new_organization_request
    @organization = Organization.new
  end

  def create_organization_request
    top_role = params[:organization][:org_roles]
    @new_role = OrgRole.new()
    @new_role.name = top_role
    @new_role.description = "Leader"
    @new_role.permissions << 'everything'

    params[:organization].delete :org_roles
    @organization = Organization.new(organization_params)
    if (Organization.where(:name => @organization.name).where(:active => true).size == 0)
      @organization.active = false
      @organization.created_by = current_user.id
      @organization.save
      @new_role.org_id = @organization.id


      @new_role.save
      @organization.create_activity action: 'new_org_request', owner: current_user
      @organization.add_leader(current_user,@new_role)
      redirect_to organizations_path, :flash => { 'success' => 'Request Accepted. Pending Approval.' }
    else
      redirect_to organizations_path, :flash => { 'error' => 'Organization Already Exists' }
    end
  end

  def index
    respond_to do |format|
        format.html
        format.json { render json: OrganizationsDatatable.new(view_context) }
      end
  end

  def member_role
    temp = Organization.find(params[:id])
    if (current_user.organizations.include? temp) && ( @org_perms.include?("everything")  || @org_perms.include?("manage-role")  )
      @organization = Organization.find(params[:id])
      @user = User.find(params[:member_id])
      new_roles = Array.new
      params['user'] ||= Hash.new
      params['user']['_org_roles'] ||= []
      params['user']['_org_roles'].each do |id|
        if(!@user.org_roles.exists?(id))
          role_new = OrgRole.find(id)
          @organization.create_activity action: 'add_role_member', parameters: {roles: id}, owner: @user
          @user.org_roles << role_new
          new_roles << role_new
        end
      end
      OrgRole.all.each do |role|
        if !(params['user']['_org_roles'].include?(role.id.to_s)) && @user.org_roles.exists?(role.id)
          @user.org_roles.delete(role)
        end
      end
      @form_type = "edit_member"
      @member = @user
      respond_to do |format|
        format.js   { render 'member_page.js.erb', :flash => { 'success' => 'Member roles updated.' }}
        format.html {  redirect_to :back , :flash => { 'success' => 'Member roles update.' }}
      end
    else
      redirect_to :back , :flash => { 'error' => 'Unauthorized.' }
    end
  end

  def edit_role
    temp = Organization.find(params[:id])
    if (current_user.organizations.include? temp) && ( @org_perms.include?("everything")  || @org_perms.include?("manage-role")  )
      @role = OrgRole.find(params[:role_id])
      @organization = Organization.find(params[:id])
      params['role'] ||= Hash.new
      params['role']['_permisisons'] ||= []
      @role.permissions = params['role']['_permisisons']
      @role.save
      @form_Type = "new_role"
      @organization.create_activity action: 'role_updated', parameters: {roles: @role.id}, owner: current_user
      respond_to do |format|
        format.js   { render 'member_page.js.erb', :flash => { 'success' => 'Role Updated.' }}
        format.html {  redirect_to :back , :flash => { 'success' => 'Role Updated.' }}
      end

    else
      redirect_to :back , :flash => { 'error' => 'Unauthorized.' }
    end
  end


  def delete_role
    temp = Organization.find(params[:id])
    if (current_user.organizations.include? temp) && ( @org_perms.include?("everything")  || @org_perms.include?("manage-role")  )
      @role = OrgRole.find(params[:role_id])
      @role.destroy
      @form_type = "delete_role"
      @organization.create_activity action: 'delete_role', parameters: {roles: params[:role_id]}, owner: current_user
      respond_to do |format|
        format.js   { render 'member_page.js.erb', :flash => { 'success' => 'Role Deleted.' }}
        format.html { redirect_to :back , :flash => { 'success' => 'Role Deleted.' }}
      end

    else
      redirect_to :back , :flash => { 'error' => 'Unauthorized.' }
    end
  end

  def new_role
    temp = Organization.find(params[:id])
    if (current_user.organizations.include? temp) && (@org_perms.include?("everything")  || @org_perms.include?("manage-role")  )
      @organization = Organization.find(params[:id])
      @role = OrgRole.new
      @role.name = params[:name]
      @role.org_id = @organization.id
      @role.description = params[:description]
      @role.permissions = params['role']['_permisisons']
      @role.save
      @form_type = "new_role"
      @organization.create_activity action: 'create_role', parameters: {roles: @role.id}, owner: current_user
      respond_to do |format|
        format.js   { render 'member_page.js.erb', :flash => { 'success' => 'Role Created.' }}
        format.html { redirect_to :back , :flash => { 'success' => 'Role Created.' }}
      end
    else
      redirect_to :back , :flash => { 'error' => 'Unauthorized.' }
    end
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def member_page
    temp = Organization.find(params[:id])
    if current_user.organizations.include?(temp)
      @organization = Organization.find(params[:id])
      @joinactivities = PublicActivity::Activity.order("created_at desc").where(trackable_id: @organization.id, trackable_type: "Organization").limit(10)
      if params[:type] == "roster"
        respond_to do |format|
          format.html
          format.js   { render 'member_page.js.erb'}
          format.json { render json: Organizations::RosterDatatable.new(view_context,@organization) }
        end
      elsif params[:type] == "roles"
        respond_to do |format|
          format.html
          format.js   { render 'member_page.js.erb'}
          format.json { render json: Organizations::RolesDatatable.new(view_context,@organization) }
        end
      elsif params[:type] == "pending"
        respond_to do |format|
          format.html
          format.js   { render 'member_page.js.erb'}
          format.json { render json: Organizations::PendingDatatable.new(view_context,@organization) }
        end
      else
        respond_to do |format|
          format.html
          format.js   { render 'member_page.js.erb'}
          format.json { render json: Organizations::EventsDatatable.new(view_context,@organization) }
        end
      end
    else
      redirect_to organizations_path
      flash[:danger] = "Unauthorized"
    end
  end


  def create_article
    temp = Organization.find(params[:id])
    puts "TTT"
    puts params
    if (current_user.organizations.include? temp) && ( @org_perms.include?("everything")  || @org_perms.include?("manage-news")  )
      @organization = Organization.find(params[:id])
      @form_type = "new_post"
      @article = Article.new
      @article.body = params[:article][:body]
      @article.title = params[:title]
      @article.user_id = current_user.id
      @article.organization_id = @organization.id
      @article.save
      @organization.create_activity action: 'create_article',parameters: {article: @article.id} ,  owner: current_user
      respond_to do |format|
        format.js   { render 'member_page.js.erb', :flash => { 'success' => 'Article Created' }}
        format.html {  redirect_to :back , :flash => { 'success' => 'Article Created' }}
      end
    else
      redirect_to :back , :flash => { 'error' => 'Unauthorized.' }
    end
  end

private
  def organization_params
    params.require(:organization).permit(:name,:summary, :description,:image)
  end

  def load_organization
    @organization = Organization.find(params[:id])
  end

  def organization_perms
    load_organization
    org_perms = Array.new
     current_user.org_roles.where(:org_id => @organization.id).each do |role|
        role.permissions.each do |perm|
          org_perms << perm.to_s.gsub('"', '')
        end
     end
    @org_perms = org_perms.uniq
  end

end
