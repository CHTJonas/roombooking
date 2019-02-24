class ApplicationService
  def self.perform(*args, &block)
    instance = new(*args, &block)
    instance.perform
    instance
  end
end
