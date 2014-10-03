usage rake post[name,title] or rake post['name','title'] or rake post[title] or rake post(default to post)
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :post, :name, :title do |t, args|
  if args.name
    name = args.name
  else
    name = get_stdin("Enter a filename for your post:")
  end
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your post:")
  end
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  mkdir_p "#{source_dir}/#{posts_dir}"
  filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{name.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "---"
  end
  if #{editor}
    system "#{editor} #{filename}"
  end
end
