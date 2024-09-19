module Resourceable
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, except: %i[index new create]
    before_action :authorize_access

    helper_method :path_index,
                  :path_show,
                  :path_new,
                  :path_create,
                  :path_edit,
                  :path_update,
                  :path_destroy

    helper_method :resource_class,
                  :resource,
                  :resources

    helper_method :sort_params

    helper_method :versions,
                  :version_excluded_fields,
                  :version_value
  end

  ##############################################################################
  # actions
  ##############################################################################

  def index # rubocop:disable Metrics/AbcSize
    @resources = resource_class_for_search
    @resources = @resources.search(params[:query]) if params[:query].present?
    @resources = filter(@resources)
    @resources = default_filters(@resources) unless params[:query].present?
    @resources = sort(@resources)
    @resources = @resources.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @resources }
    end
  end

  def new
    @resource = resource_class.new
  end

  def create
    @resource = resource_class.new(resource_params)

    respond_to do |format|
      if @resource.save
        format.html do
          respond_with @resource, location: -> { path_show(@resource) }
        end

        format.json { render :show, status: :created, location: @resource }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html do
          respond_with @resource, location: -> { path_show(@resource) }
        end

        format.json { render :show, status: :ok, location: @resource }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy # rubocop:disable Metrics/AbcSize
    respond_to do |format|
      if resource.destroy
        format.html do
          respond_with @resource, location: -> { path_index }
        end

        format.json { head :no_content }
      else
        format.html do
          flash[:alert] = resource.errors.full_messages.join(', ')
          redirect_to path_show
        end

        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_activation # rubocop:disable Metrics/AbcSize
    if resource.discarded?
      resource.undiscard
      message = 'activated'
    else
      resource.discard
      message = 'archived'
    end

    if resource.errors.any?
      flash[:alert] = resource.errors.full_messages.join(', ')
    else
      # TODO: move message to the locale file
      flash[:notice] = "#{resource_class.model_name.human} is #{message}."
    end

    redirect_to path_show
  end

  ##############################################################################
  # search, filter, sort, paginate
  ##############################################################################

  # NOTE: can be overridden by the controller to add additional filters
  def filter(results)
    results
  end

  def default_filters(results)
    # Filter by archive state
    archive_states = params[:archive_states] || []
    results = if archive_states.include?('active')
                results.kept
              elsif archive_states.include?('archived')
                results.discarded
              else
                results
              end

    # Filter by created_at date range
    if params[:created_from].present?
      from_date = params[:created_from].to_date.beginning_of_day
      results = results.where('created_at >= ?', from_date)
    end

    if params[:created_to].present?
      to_date = params[:created_to].to_date.end_of_day
      results = results.where('created_at <= ?', to_date)
    end

    # Filter by discarded_at date range
    if params[:archived_from].present?
      from_date = params[:archived_from].to_date.beginning_of_day
      results = results.where('discarded_at >= ?', from_date)
    end

    if params[:archived_to].present?
      to_date = params[:archived_to].to_date.end_of_day
      results = results.where('discarded_at <= ?', to_date)
    end

    results
  end

  def sort(results)
    sort_by = params[:sort_by].presence&.downcase
    sort_by = if sort_by && resource_class.column_names.include?(sort_by)
                sort_by
              elsif sort_by && resource_class.column_names.include?("#{sort_by}_id")
                "#{sort_by}_id"
              else
                'created_at'
              end

    sort_direction = if %w[asc desc].include?(params[:sort_direction]&.downcase)
                       params[:sort_direction]
                     else
                       'asc'
                     end

    results.order(sort_by => sort_direction)
  end

  def sort_params(column)
    column = column.to_s

    new_direction = if column == params[:sort_by]
                      params[:sort_direction] == 'asc' ? 'desc' : 'asc'
                    else
                      'asc'
                    end

    { sort_by: column, sort_direction: new_direction }
  end

  ##############################################################################
  # paths
  ##############################################################################

  def path_index
    raise NotImplementedError
  end

  def path_show
    raise NotImplementedError
  end

  def path_new
    raise NotImplementedError
  end

  def path_create
    raise NotImplementedError
  end

  def path_edit
    raise NotImplementedError
  end

  def path_update
    raise NotImplementedError
  end

  def path_destroy
    raise NotImplementedError
  end

  ##############################################################################
  # resources
  ##############################################################################

  def resource_class
    raise NotImplementedError
  end

  def resource_class_for_search
    raise NotImplementedError
  end

  def resource
    @resource
  end

  def resources
    @resources
  end

  ##############################################################################
  # versions
  ##############################################################################

  def versions
    @versions ||= resource.versions.includes([:item]).reverse
  end

  def version_excluded_fields
    %w[
      id
      encrypted_password
      created_at
      updated_at
    ].freeze
  end

  def version_value(resource, attribute, value) # rubocop:disable Metrics/AbcSize
    return '---' if value.blank?

    attribute_type = resource.class.column_for_attribute(attribute).type

    if %i[date datetime].include?(attribute_type)
      DateTime.parse(value).strftime('%B %d, %Y')
    elsif attribute.match?(/amount$/)
      Money.new(value).format
    elsif attribute.match?(/_id$/)
      association = resource
                    .class
                    .reflect_on_association(attribute.sub(/_id$/, ''))
                    .klass

      association.find_by_id(value).to_s
    elsif attribute == 'status'
      value.titleize
    else
      value
    end
  end

  def authorize_by_model_actions
    %w[index new create]
  end

  private

  def authorize_access
    if authorize_by_model_actions.include?(action_name)
      authorize :"Admin::#{resource_class}"
    else
      authorize @resource, policy_class: :"Admin::#{resource_class}"
    end
  end

  def resource_params
    raise NotImplementedError
  end

  def set_resource
    raise NotImplementedError
  end
end
