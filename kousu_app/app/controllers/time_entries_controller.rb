class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[show edit update destroy]
  before_action :authorize_time_entry, except: [:index]

  # GET /time_entries
  def index
    scope = policy_scope(TimeEntry).includes(:project, :task)

    from = params[:from].present? ? (Date.parse(params[:from]) rescue nil) : Date.today.beginning_of_week(:monday)
    to   = params[:to].present? ? (Date.parse(params[:to]) rescue nil) : Date.today.end_of_week(:monday)
    scope = scope.between(from, to) if from && to

    scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
    scope = scope.where(user_id: params[:user_id]) if manager_or_admin?(current_organization) && params[:user_id].present?

    @time_entries = scope.order(work_date: :desc)
    @projects = policy_scope(Project).order(:name)
    @users = manager_or_admin?(current_organization) ? current_organization.users.order(:email) : []

    respond_to do |format|
      format.html
      format.csv do
        filename = "time_entries-#{Date.today}.csv"
        headers['Content-Disposition'] = %(attachment; filename="#{filename}")
        headers['Content-Type'] = 'text/csv'
        render plain: CSV.generate(headers: true) { |csv|
          csv << %w[date project task hours minutes note billable]
          @time_entries.each do |e|
            csv << [e.work_date, e.project&.name, e.task&.name, e.hours, e.minutes, e.note, e.billable]
          end
        }
      end
    end
  end

  # GET /time_entries/1
  def show; end

  # GET /time_entries/new
  def new
    @time_entry = TimeEntry.new
  end

  # GET /time_entries/1/edit
  def edit; end

  # POST /time_entries
  def create
    @time_entry = TimeEntry.new(time_entry_params)
    set_time_entry_defaults(@time_entry)
    authorize @time_entry
    if @time_entry.save
      redirect_to time_entries_url, notice: 'Time entry was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /time_entries/1
  def update
    authorize @time_entry
    if @time_entry.update(time_entry_params)
      set_time_entry_defaults(@time_entry)
      redirect_to time_entries_url, notice: 'Time entry was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /time_entries/1
  def destroy
    @time_entry.destroy!
    respond_to do |format|
      format.html { redirect_to time_entries_path, notice: 'Time entry was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_time_entry
    @time_entry = policy_scope(TimeEntry).find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:project_id, :task_id, :work_date, :minutes, :note, :billable)
  end

  def set_time_entry_defaults(entry)
    entry.organization ||= current_organization
    entry.user ||= current_user
  end

  def authorize_time_entry
    if defined?(@time_entry) && @time_entry.present?
      authorize @time_entry
    else
      authorize TimeEntry
    end
  end
end
