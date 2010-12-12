$root = File.expand_path(File.dirname(__FILE__))+'/'
class Story
  
  attr_accessor :short, :dir
  
  def initialize(dir)
    @short = dir
  end
  
  def find(name)
    #dunno yet
  end
  
  def thoughts
    return Thought.find(:story=>@short)
  end
  
  def scenes
    return Scene.find(:story=>@short)
  end
  
  def outline
    return Outline.find(:story=>@short)
  end
  
end

class Blob
  
  attr_accessor :id, :title, :content, :filename, :story, 
                :date, :meta, :file, :type, :permalink, :html

  def initialize(file_path,story=nil)
    if File.stat(file_path).directory? then return nil end
    @filename   = file_path.split('/').last
    pattern    = /^0+(\d+)\.(\d{4}\-\d{2}\-+\d{2})?\.?(.*?)$/
    chops      = @filename =~ pattern
    @id        = $1.to_i
    @date      = $2
    @title     = $3.gsub('_', ' ')
    lines      = File.read(file_path).split("\n")
    @meta      = lines.shift
    @content   = lines.join("\n")
    @story     = story
    @type      = self.class.name.downcase
    @permalink = '/'+((@story) ? "#{@story}/" : '')+"#{@type}/#{@id}"
  end
  
  def self.find(p={})
    p = {:id=>p} if p.class == Fixnum
    path = $root+'../'+ (p[:story] ? "stories/#{p[:story]}/":'')+"#{@subdir}/"
    return nil unless (File.directory? path)
    dir = Dir.new(path)
    if p[:id] then
      if filename = dir.detect{ |f| f =~ /^0+#{p[:id]}/ }
        self.new(path+filename, p[:story])
      end
    else
      dir.collect { |filename|
        file_path = path + filename
        next if file_path =~ /\.swp$/
        File.directory?(file_path) ? nil : self.new(file_path,p[:story])
      }.compact
    end
  end

end

class Thought < Blob
  @subdir = 'thoughts'
end

class Outline < Blob
  
  attr_accessor :story, :filename, :content, :sections
  
  def initialize(file_path,story=nil)
    @story    = story
    @filename = file_path
    @raw      = File.read(file_path)
    @sections = []
    hashify_content
  end
  
  def add_section(section)
    @sections << section
  end
  
  def hashify_content
    outline = {'sections'=>[]}
    @raw.split(/^\=\=\=/).delete_if{|s|s.empty?}.each do |section|
      lines = section.split("\n")
      title = lines.shift.strip.gsub(/^([=]+)/, '');
      add_section(Section.new(title, lines.join("\n")))
    end
  end
  
  def self.find(p={})
    p = {:id=>p} if p.class == Fixnum
    path = $root+"../stories/#{p[:story]}/outline"
    self.new(path,p[:story])
  end
  
  def save
    f = File.open(@filename, 'w')
    f.write(@content)
    f.close
  end
  
  def commit(message)
    puts message
     `git add #{@filename}`
     `git commit -m "#{message}"`
  end
  
end

class Section
  
  attr_accessor :scenes, :title
  
  def initialize(title, raw)
    @raw = raw
    @title = title
    @scenes = []
    hashify_content
  end

  def add_scene(scene) 
    @scenes << scene
  end

  def hashify_content
    @raw.split(/^\*/).delete_if{|s|s.empty?}.each do |scene|
	lines = scene.split("\n")
        title = lines.shift.strip
        add_scene(Scene.new(title, lines.join("\n")))
    end
  end
  
end

class Scene

  attr_accessor :title, :notes, :content

  def initialize(title, content)
    @title   = title
    @content = content
  end

end
