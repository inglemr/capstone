class OrganizationsDatatable
   delegate :params, :h, :day, :datetime ,:content_tag, :current_ability, :render, :can?,:truncate, to: :@view

  def initialize(view)
    @view = view
    @organizations = Organization.where(search_string, search: "%#{params[:sSearch] == nil ? params[:sSearch] : params[:sSearch].downcase}%")
    @organizations = @organizations.page(page).per_page(per_page)

  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: @organizations.count,
      iTotalDisplayRecords: @organizations.total_entries,
      aaData: data
    }
  end

private

  def data
    @organizations.map do |organization|
      {
        DT_RowId: organization.id.to_s,
        DT_RowClass: '',
        DT_RowAttr: '',
        "organizations__id" => organization.id,
        "organizations__name" => organization.name,
        organizations_orgTile: orgTile(organization)
      }
    end
  end

  def orgTile(organization)
    render(:partial=>"organizations/org_tile.html.erb", locals: { organization: organization, style: "col-md-6 padding-bottom-10"},:formats => [:html])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0? params[:iDisplayLength].to_i : 4
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def search_string
    "name LIKE :search OR description LIKE :search"
  end

  def sort_column
    [*0..params[:iColumns].to_i-1].map{|i| params["mDataProp_#{i}"].gsub("__", ".") if params["bSortable_#{i}"] != 'false' }[params[:iSortCol_0].to_i]
  end
end

