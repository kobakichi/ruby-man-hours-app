class TimeEntriesController < ApplicationController
before_action :authorize_time_entry, except: [:index]

private
def authorize_time_entry
  if defined?(@time_entry) && @time_entry.present?
    authorize @time_entry
  else
    authorize TimeEntry
  end
end
private
def time_entry_params
  params.require(:time_entry).permit(:project_id, :task_id, :work_date, :minutes, :note, :billable)
end

def set_time_entry
  @time_entry = policy_scope(TimeEntry).find(params[:id])
end

  before_action :set_time_entry, only: %i[ show edit update destroy ]

  # GET /time_entries or /time_entries.json
  def index
  scope = policy_scope(TimeEntry).includes(:project, :task)

  from = params[:from].present? ? (Date.parse(params[:from]) rescue nil) : Date.today.beginning_of_week(:monday)
  to   = params[:to].present? ? (Date.parse(params[:to]) rescue nil) : Date.today.end_of_week(:monday)
  scope = scope.between(from, to) if from && to

  if params[:project_id].present?
    scope = scope.where(project_id: params[:project_id])
  end

  if manager_or_admin?(current_organization) && params[:user_id].present?
    scope = scope.where(user_id: params[:user_id])
  end

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


  # GET /time_entries/1 or /time_entries/1.json
  def show
  end

  # GET /time_entries/new
  def new
    @time_entry = TimeEntry.new
  end

  # GET /time_entries/1/edit
  def edit
  end

  # POST /time_entries or /time_entries.json
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
er :show, status: :created, location: @time_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /time_entries/1 or /time_entries/1.json
  def update
  authorize @time_entry
  if @time_entry.update(time_entry_params)
    set_time_entry_defaults(@time_entry)
    redirect_to time_entries_url, notice: 'Time entry was successfully updated.'
  else
    render :edit, status: :unprocessable_entity
  end
end
er :show, status: :ok, location: @time_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_entries/1 or /time_entries/1.json
  def destroy
    @time_entry.destroy!

    respond_to do |format|
      format.html { redirect_to time_entries_path, notice: "Time entry was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_entry
  @time_entry = policy_scope(TimeEntry).find(params[:id])
end


    # Only allow a list of trusted parameters through.
    def time_entry_params
      params.expect(time_entry: [ :organization_id, :user_id, :project_id, :task_id, :work_date, :minutes, :note, :billable, :approved_at, :approved_by_id ])
    end
end
