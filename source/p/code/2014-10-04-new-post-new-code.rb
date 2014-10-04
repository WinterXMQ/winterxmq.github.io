# usage rake code[name] or rake code['name'] or rake code(default to code)
# tack for new code files
desc "Begin a new code file in #{source_dir}/#{code_dir}"
task :code, :name do |t, args|
  if args.name
    name = args.name
  else
    name = get_stdin("Enter a filename for your code:")
  end
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  mkdir_p "#{source_dir}/#{code_dir}"
  basicname = "#{Time.now.strftime('%Y-%m-%d')}-#{name}"
  filename = "#{source_dir}/#{code_dir}/#{basicname}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  if #{editor}
    system "#{editor} #{filename}"
  end
  if File.exist?(filename)
    puts "Created new post: #{filename}"
    puts "{% include_code [filename] lang:Language #{basicname} %}"
    puts "  or  {% include_code [filename] lang:Language #{code_dir}/#{basicname} %}"
    puts "  can be used in blog markdown files."
  else
    puts "File is canceled."
  end
end
