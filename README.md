# ActiveJob Inline Setup

## Installation

Add gem into `Gemfile`

```ruby
gem "active_job_inline", github: "nxtthing/active-job-inline"
```

Add rack middleware by placing next code into `config/application.rb`
```ruby
require "active_job_inline/extensions/rack_middleware"
...
config.middleware.use ActiveJobInline::Extensions::RackMiddleware
```
Place next code into `spec/rails_helper.rb`
```ruby
require "active_job_inline/extensions/active_record_test_fixtures_before_rollback_patch"

ActiveSupport.on_load(:active_record_fixtures) do
  prepend ActiveJobInline::Extensions::ActiveRecordTestFixturesBeforeRollbackPatch
end
```
After that you are able to use custom active_job adapter in environment files like `config/environments/development.rb`
```ruby
ActiveJobInline.apply do
  # Do something
end
```
or
```ruby
ActiveJobInline.apply(with_delay: true) do
  # Do something
end
```
and check if inline adapter is applied directly from your code
```ruby
ActiveJobInline.applied?
```
