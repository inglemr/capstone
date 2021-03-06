class Admin::TagsDatatable
   delegate :params, :h,  :content_tag, :current_ability, :render, :can?,:truncate, to: :@view

  def initialize(view)
    @view = view
    @tags = Tag.order("#{sort_column} #{sort_direction}").where(search_string, search: "%#{params[:sSearch] == nil ? params[:sSearch] : params[:sSearch].downcase}%")
    @tags = @tags.page(page).per_page(per_page)

  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: @tags.count,
      iTotalDisplayRecords: @tags.total_entries,
      aaData: data
    }
  end

private

  def data

    @tags.map do |tag|
      {
        'DT_RowId' => tag.id.to_s,
        "tags__id" => tag.id,
        "tags__name" => tag.name.capitalize,
        tag_actions: actions(tag)
      }
    end
  end

  def actions(tag)
    render(:partial=>"admin/tag/actions.html.erb", locals: { tag: tag} , :formats => [:html])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0? params[:iDisplayLength].to_i : 10
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def search_string
    "name like :search"
  end

  def sort_column
    [*0..params[:iColumns].to_i-1].map{|i| params["mDataProp_#{i}"].gsub("__", ".") if params["bSortable_#{i}"] != 'false' }[params[:iSortCol_0].to_i]
  end
end
