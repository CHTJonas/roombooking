class ApplicationService
  def self.perform(*args, &block)
    new(*args, &block).perform
  end

  def self.create(*args, &block)
    instance = new(*args, &block)
    instance.perform
    instance
  end
end
