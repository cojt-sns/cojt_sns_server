# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(email: 'test@test.com', password: 'abcd1234', name: 'test')
user2 = User.create(email: 'test2@test.com', password: 'abcd1234', name: 'test2')

tag = Tag.create(name: 'スマブラ')

tag1 = Tag.create(name: "筑波大学")
tag2 = tag1.children.build(name: "情報学群")
tag3 = tag2.children.build(name: "情報メディア創成学類")
tag4 = tag2.children.build(name: "知識情報・図書館学類")
tag5 = tag2.children.build(name: "情報科学類")

tag1.save
tag2.save
tag3.save
tag4.save
tag5.save

group = Group.create(public: true, twitter_traceability: true, questions: '["スマブラのプレイ時間は?"]', introduction: false, tags: [tag, tag2])

group1 = Group.create(public: true, twitter_traceability: true, questions: '["スマブラのプレイ時間は?"]', introduction: false, tags: [tag1])

group2 = Group.create(public: true, twitter_traceability: true, questions: '["スマブラのプレイ時間は?"]', introduction: false, tags: [tag, tag3])

group3 = Group.create(public: false, twitter_traceability: false, questions: '["スマブラのプレイ時間は?"]', introduction: false, tags: [tag, tag4])

group4 = Group.create(public: false, twitter_traceability: false, questions: '["スマブラのプレイ時間は?"]', introduction: false, tags: [tag, tag5])

user.groups << group
user.groups << group1

user2.groups << group2
user2.groups << group3
user2.groups << group4

user.save!

post1 = Post.create(content: "post1", user_id: user.id, group_id: group.id, created_at: Time.now + 1.hour)
post2 = Post.create(content: "post2", user_id: user.id, group_id: group.id, created_at: Time.now + 2.hour)
post3 = Post.create(content: "post3", user_id: user.id, group_id: group1.id, created_at: Time.now + 3.hour)
post4 = Post.create(content: "post4", user_id: user.id, group_id: group1.id, created_at: Time.now + 4.hour)
post5 = Post.create(content: "post5", user_id: user.id, group_id: group1.id, created_at: Time.now + 1.day)
post = Post.create(content: "こんにちは！", group: group, user: user)
