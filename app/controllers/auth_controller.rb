class AuthController < ApplicationController
  before_action :authenticate, only: %i(logout user)

  # POST /auth/login
  def login
    # email,password が送信されたか確認
    if params[:email].nil?
      render json: { "code": 400, "message": 'メールアドレスを入力してください' }, status: :bad_request
      return
    end
    if params[:password].nil?
      render json: { "code": 400, "message": 'パスワードを入力してください' }, status: :bad_request
      return
    end

    user = User.find_by(email: params[:email])

    # ユーザーの存在を確認
    if user.nil?
      render json: { "code": 401, "message": 'メールアドレスまたはパスワードが間違っています。' }, status: :unauthorized
      return
    end

    # パスワードを確認
    unless user.authenticate(params[:password])
      render json: { "code": 401, "message": 'メールアドレスまたはパスワードが間違っています。' }, status: :unauthorized
      return
    end

    # AuthenticateToken生成
    auth = AuthenticateToken.new
    auth.user = user
    auth.token = SecureRandom.uuid
    auth.last_access = DateTime.now
    unless auth.save
      render json: { "code": 500, "message": 'トークンを生成できませんでした。' }, status: :internal_server_error
      return
    end

    render json: { "code": 200, "auth_token": auth.token }
  end

  # POST /auth/logout
  def logout
    auth = AuthenticateToken.find_by(token: @token)

    # トークンの存在を確認
    if auth.nil?
      render json: { "message": 'トークンが存在しません' }, status: :unauthorized
      return
    end

    # トークンを無効に
    auth.active = false
    unless auth.save
      render json: { "message": 'ログアウトできませんでした。' }, status: :internal_server_error
      return
    end

    render json: { "code": 200, "message": 'ログアウトしました。' }
  end

  # get /auth/user
  def user
    if @user.nil?
      render json: { "message": 'ユーザーが存在しません' }, status: :internal_server_error
      return
    end

    render json: @user.json
  end
end
