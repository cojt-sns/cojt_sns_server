class TagsController < ApplicationController
  before_action :authenticate, only: [:create]
  
  # GET /tags
  def index
    render json: 
      [
        {
          "tag": {
            "id": 1,
            "name": "情報メディア創成学類",
            "parent_id": 0,
            "fullname": "筑波大学.情報学群.情報メディア創成学類"
          },
          "ancestors": [
            {
              "id": 1,
              "name": "情報メディア創成学類",
              "parent_id": 0,
              "fullname": "筑波大学.情報学群.情報メディア創成学類"
            }
          ],
          "children": [
            {
              "id": 1,
              "name": "情報メディア創成学類",
              "parent_id": 0,
              "fullname": "筑波大学.情報学群.情報メディア創成学類"
            }
          ]
        }
      ]
  end

  # GET /tags/{id}
  def show
    render json: {
      "id": 1,
      "name": "情報メディア創成学類",
      "parent_id": 0,
      "fullname": "筑波大学.情報学群.情報メディア創成学類"
    }
  end

  # POST /tag
  def create
    render json: {
      "id": 1,
      "name": "情報メディア創成学類",
      "parent_id": 0,
      "fullname": "筑波大学.情報学群.情報メディア創成学類"
    }
  end
end
