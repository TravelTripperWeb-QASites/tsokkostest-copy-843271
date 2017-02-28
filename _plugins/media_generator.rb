#------------------------------------------------------------------------------
#
# This plugin read all the media individual .json files and
# merge them to a single file.
#
# As well same for model instances. All model instance files read and
# merge them to a single file.
#
# When jekyll server running all these files will be created and
# updated accordingly.
#
#---------------------------------------------------------------------------------------------------------------

module Jekyll
  class MediaGenerator < Generator
    require 'octokit'

    class GithubError < StandardError
    end
    safe true

    def generate(_site)
     binding.pry
      images
      create_json_files media_dir
      create_json_files model_dir, 'models'
    end

    private

    def save(filename, content)
      filename = "#{filename}.json"
      File.open(filename, 'w') do |f|
        f.write(JSON.pretty_generate(content))
      end
    end

    def create_json_files(folder, file_name = 'models')
      return unless File.directory? folder
      sub_folders = Dir.entries("#{folder}/").select { |entry| File.directory? File.join(folder, entry) and !(entry == '.' || entry == '..') }
      if sub_folders.empty?
        json = Dir[File.join(folder, '*.json')].map { |f| JSON.parse File.read(f) }.flatten
        file = folder.split('/')[-1]
        save file, json
      else
        hash = Hash.new { |h, k| h[k] = [] }
        sub_folders.each do |file|
          Dir[File.join(folder, file, '*.json')].map do |f|
            data = JSON.parse File.read(f)
            hash[file.to_s] << [name: data['name'], file: File.basename(f)]
          end
        end
        save file_name, hash
      end
    end

    def model_dir
      File.expand_path(File.join(Dir.pwd, '_data', '_models'))
    end

    def media_dir
      File.expand_path(File.join(Dir.pwd, '_assets', 'image_data'))
    end

    def self.images(repo, branch)
      binding.pry
      images_folder = get_raw_content(repo, '_assets', branch).select { |item|
        item.name == 'images' && item.type == 'dir'
      }.first
      binding.pry
      if images_folder
        images = folder_tree(repo, images_folder.sha).tree.select { |item| item.type == 'blob' }
        images.map { |image| { path: image.path, sha: image.sha } }
      else
        return []
      end
    rescue Octokit::NotFound
      []
    end
    # returns files or dirs, content NOT decoded
    def self.get_raw_content(repo, path, branch = 'master')
      Octokit.content(repo.include?('/') ? repo : full_repo_name(repo), path: path, ref: branch)
    end

    def self.full_repo_name(repo)
      repo = repo.to_s
      if repo.include?('/') #already in org/repo format
        return repo
      else
        "#{ENV['ORGANIZATION_NAME']}#{repo}"
      end
    end
  end
end
