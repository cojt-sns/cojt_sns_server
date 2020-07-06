# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(email: 'test@test.com', password: 'abcd1234', name: 'test')
user2 = User.create(email: 'test2@test.com', password: 'abcd1234', name: 'test2', private: true)

group = Group.create(name: 'スマブラ')

group1 = Group.create(name: "筑波大学")
group2 = group1.children.build(name: "情報学群")
group3 = group2.children.build(name: "情報メディア創成学類")
group4 = group3.children.build(name: "知識情報・図書館学類")
group5 = group4.children.build(name: "情報科学類")

group1.save
group2.save
group3.save
group4.save
group5.save

group_user1 = GroupUser.create(name: 'tset1-1', user: user, group: group)
group_user2 = GroupUser.create(name: 'tset1-2', user: user, group: group1)

group_user3 = GroupUser.create(name: 'tset2-1', user: user2, group: group2)
group_user4 = GroupUser.create(name: 'tset2-2', user: user2, group: group3)
group_user5 = GroupUser.create(name: 'tset2-3', user: user2, group: group4)

post1 = Post.create(content: "post1", group_user: group_user1, group_id: group.id, created_at: Time.now + 1.hour)
post2 = Post.create(content: "post2", group_user: group_user1, group_id: group.id, created_at: Time.now + 2.hour)
post3 = Post.create(content: "post3", group_user: group_user2, group_id: group1.id, created_at: Time.now + 3.hour)
post4 = Post.create(content: "post4", group_user: group_user2, group_id: group1.id, created_at: Time.now + 4.hour)
post5 = Post.create(content: "post5", group_user: group_user3, group_id: group2.id, created_at: Time.now + 1.day)
post = Post.create(content: "こんにちは！", group: group, group_user: group_user1)
