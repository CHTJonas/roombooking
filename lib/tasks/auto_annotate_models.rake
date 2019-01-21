if Rails.env.development?
  require 'annotate'
  task :set_annotation_options do
    Annotate.set_defaults(
      'exclude_tests'             => 'true',
      'exclude_fixtures'          => 'true',
      'exclude_factories'         => 'true',
      'exclude_serializers'       => 'true',
      'exclude_scaffolds'         => 'true',
      'exclude_controllers'       => 'true',
      'exclude_helpers'           => 'true'
    )
  end

  Annotate.load_tasks
end
