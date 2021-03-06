class UsersController < ApplicationController
  before_filter :authenticate

  # GET /users
  # GET /users.json
  def index
    @users = User.search(params.merge({
                  :sort_col => sort_column,
                  :sort_dir => sort_direction,
                  :filter   => filter_type }))
    
    @categories = Hash.new(0)
    @users.each do |user|
      @categories[user.category_as_string] += 1
    end
    @categories = @categories.sort_by { |k,v| k }.sort_by { |k,v| -v }
    
    @results = @users.size

    @users = @users.paginate(:page => params[:page], :per_page => params[:per_page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @rentals = @user.rentals.find(:all, :order => 'return_date')
    @holds = @user.holds.find(:all, :order => 'end_date')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    if current_user.category > 0
        @user = User.new

        respond_to do |format|
          format.html # new.html.erb
          format.json { render :json => @user }
        end
    else
        redirect_to(users_path)
    end
  end

  # GET /users/1/edit
  def edit
    if current_user.category > 0
        if current_user.category == 1 and current_user.category > User.find(params[:id]).category
            @user = User.find(params[:id])
        elsif current_user.category == 2
            @user = User.find(params[:id])
        else
            redirect_to(users_path)
        end
    else
        redirect_to(users_path)
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, :notice => 'User was successfully created.' }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, :notice => 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # /users/manage
  # /users/manage.json
  def manage
    if current_user.category < 1
      redirect_to(root_path)
    end
  end

  def authenticate
    redirect_to(new_user_session_path) unless user_signed_in?
  end

private
  def tableColumns
    User.column_names
  end

end
