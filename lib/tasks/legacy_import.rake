namespace :db do
  desc "Import data from the old database"
  task legacy_import: :environment do |t,args|
    # HACK (Mispy): The "firsts" here are to force the
    # Rails database reflection to cache the new schema
    # instead of the old one. This whole thing is a bit
    # ad hoc and inefficient but that's fine.
    User.first; p User
    Scite.first; p Scite
    Comment.first; p Comment
    Subscription.first; p Subscription

    ActiveRecord::Base.establish_connection({
      adapter: 'postgresql',
      database: 'legacy_scirate'
    })

    puts "Mapping old paper ids to arxiv uids"

    id_map = Hash[Paper.pluck(:id, :identifier)]
    feed_id_map = Hash[Feed.unscoped.pluck(:id, :name)]

    puts "Importing users + scites, comments and subscriptions"

    old_users = User.includes(:comments, :subscriptions).to_a

    old_scites = {}
    Scite.all.each do |scite|
      old_scites[scite.sciter_id] ||= []
      old_scites[scite.sciter_id] << scite
    end

    ActiveRecord::Base.establish_connection(Rails.env)

    ActiveRecord::Base.transaction do
      old_users.each do |old_user|
        p old_user.name
        user = User.create!(
          fullname: old_user.name,
          username: User.default_username(old_user.name) + "-#{old_user.id}",
          email: old_user.email,
          remember_token: old_user.remember_token,
          password: 'mehmeh',
          password_confirmation: 'mehmeh',
          password_digest: old_user.password_digest,
          password_reset_token: old_user.password_reset_token,
          password_reset_sent_at: old_user.password_reset_sent_at,
          confirmation_token: old_user.confirmation_token,
          active: old_user.active,
          expand_abstracts: old_user.expand_abstracts,
          scites_count: old_user.scites_count,
          comments_count: old_user.comments_count,
          created_at: old_user.created_at
        )

        (old_scites[old_user.id]||[]).each do |old_scite|
          user.scites.create!(
            paper_uid: id_map[old_scite.paper_id],
            created_at: old_scite.created_at
          )
        end

        old_user.comments.each do |old_comment|
          user.comments.create!(
            paper_uid: id_map[old_comment.paper_id],
            created_at: old_comment.created_at,
            content: old_comment.content
          )
        end

        old_user.subscriptions.each do |old_sub|
          user.subscriptions.create!(
            feed_uid: feed_id_map[old_sub.feed_id],
            created_at: old_sub.created_at
          )
        end

        # If they're not subscribed to anything
        # subscribe them to quant-ph
        if old_user.subscriptions.count == 0
          user.subscriptions.create!(
            feed_uid: 'quant-ph',
            created_at: old_sub.created_at
          )
        end
      end
    end
  end
end
