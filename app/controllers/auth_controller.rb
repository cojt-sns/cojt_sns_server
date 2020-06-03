class AuthController < ApplicationController
  before_action :authenticate, only: [:logout]

  # POST /auth/login
  def login()
    puts params[:email].class

    if params[:email].nil?
      render json: { "code": 400, "message": "メールアドレスを入力してください"}, status: 400
      return
    end

    if params[:password].nil?
      render json: { "code": 400, "message": "パスワードを入力してください"}, status: 400
      return
    end

    user = User.find_by(email: params[:email])

    # ユーザーの存在を確認
    if user.nil?
      render json: { "code": 401, "message": "メールアドレスまたはパスワードが間違っています。"}, status: 401
      return
    end

    # パスワードを確認
    if !user.authenticate(params[:password])
      render json: { "code": 401, "message": "メールアドレスまたはパスワードが間違っています。" }, status: 401
      return
    end

    

    #AuthenticateToken生成
    auth = AuthenticateToken.new
    auth.user = user
    auth.token = SecureRandom.uuid
    if !auth.save
      render json: { "code": 500, "message": "トークンを生成できませんでした。" }, status: 500
      return
    end

    render json: { "code": 200, "auth_token": auth.token }
  end

  # POST /auth/logout
  def logout()
    auth = AuthenticateToken.find_by(token: params[:auth_token])

    # トークンの存在を確認
    if auth.nil?
      render json: { "message": "トークンが存在しません" }, status: 401
      return
    end

    # トークンを無効に
    auth.active = false
    if !auth.save
      render json: { "message": "ログアウトできませんでした。" }, status: 500
      return
    end

    render json: { "code": 200, "message": "ログアウトしました。" }
  end
end

