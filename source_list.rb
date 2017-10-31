# Ruby module to list files in the source directory
# that's mounted inside your container.
module SourceList
  def self.array
    Dir['/usr/local/src/*']
  end

  def self.print
    puts self.array
  end
end
