class GroupsController < ApplicationController
  before_action :authenticate, only: [:create, :update]

  # get /groups
  def index
    render json: {
      "id": 1,
      "twitter_traceability": false,
      "questions": [
        "スマブラのプレイ時間は?"
      ],
      "introduction": false,
      "tags": [
        0
      ]
    }
  end

  # post /groups
  def create
    render json: [
      {
        "group": {
          "id": 1,
          "twitter_traceability": false,
          "questions": [
            "スマブラのプレイ時間は?"
          ],
          "introduction": false,
          "tags": [
            0
          ]
        }
      }
    ]
  end

  # get /groups/{id}
  def show
    render json: {
      "id": 1,
      "twitter_traceability": false,
      "questions": [
        "スマブラのプレイ時間は?"
      ],
      "introduction": false,
      "tags": [
        0
      ]
    }
  end

  # put /groups/{id}
  def update
    render json: {
      "id": 1,
      "twitter_traceability": false,
      "questions": [
        "スマブラのプレイ時間は?"
      ],
      "introduction": false,
      "tags": [
        0
      ]
    }
  end
end
