if Rails.env == "development"
  skip_these_files = [".", "..", ".keep", "concerns"]
  Dir.foreach("#{Rails.root}/app/models") do |model_name|
    require_dependency model_name unless skip_these_files.include? model_name
  end
end
