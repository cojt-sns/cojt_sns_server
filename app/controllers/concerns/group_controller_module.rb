module GroupControllerModule
  def update_words(group, is_save = true)
    group.words = []

    nm = Natto::MeCab.new('-N 2')
    logger.info(nm)
    nm.parse(group.name) do |n|
      next if n.surface.empty?

      word = Word.find_by(word: n.surface)
      if word.nil?
        word = Word.new(word: n.surface, word_class: n.feature.split(',').dig(0))
        return unless word.save
      end

      group.words << word unless group.words.where(id: word.id).exists?
    end

    group.save if is_save
  end

  # rubocop:disable Metrics/AbcSize
  def update_score(group, is_save = true)
    update_words(group, false) if group.words.count.zero?

    post = group.posts.where(created_at: (Time.zone.now - 1.week)..).count
    post = 1 if post.zero?

    member = group.group_users.count
    member = 1 if member.zero?

    group.frequency = 70 * Math.log(post.to_f / member, 20)
    depth_score = 10 * Math.log(group.tree_level + 1, 5)
    group.depth_score = depth_score > 10 ? 10.0 : depth_score
    logger.debug(group.words.sum { |w| w.groups.count })
    logger.debug(group.words.map(&:word))
    group.independency = 20.0 / (group.words.sum { |w| w.groups.count }.to_f / group.words.count)

    group.score = group.frequency + group.depth_score + group.independency

    group.save if is_save

    logger.debug(group.id)
  end
  # rubocop:enable Metrics/AbcSize
end
