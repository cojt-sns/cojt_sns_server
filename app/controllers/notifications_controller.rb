class NotificationsController < ApplicationController
  before_action :authenticate

  # get /notifications
  def index
    render json: @user.notifications.map(&:json).to_json
  end

  # get /notifications/:id
  def destroy
    params = notification_params

    notification = @user.notifications.find_by(id: params[:id])
    render json: { "code": 404, "message": '通知が存在しません' }, status: :not_found if notification.blank?

    render json: { "code": 500, "message": '通知の削除に失敗しました。' }, status: :internal_server_error unless notification.destroy

    render json: { "code": 200, "message": 'successful operation' }
  end

  # private

  def notification_params
    params.permit(:id)
  end
end
