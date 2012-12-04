# ObjectPubSub

ObjectPubSub is an implementation of the Observer pattern for Ruby that 
provides finer-grained controll over message passing than does the 
Observable module from Ruby's stdlib. The including class can publish 
multiple event types, and the subscribers can specify both which event 
types to listen for and what method on the subscriber should be invoked 
for each event type.

## Installation

Add this line to your application's Gemfile:

    gem 'object_pub_sub'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install object_pub_sub

## Usage

In the class that will be publishing events (the "Observable"), simply 
include `ObjectPubSub` and then publish events where appropriate:

    class UserValidator
      include ObjectPubSub

      attr_reader :user, :errors

      def initialize(user)
        @user = user
        @errors = {}
      end

      def validate
        validate_username #def exluded for brevity
        validate_password #def exluded for brevity
        validate_email #def exluded for brevity

        notify_subscribers
      end

      private

      def notify_subscribers
        if errors.any?
          publish_event(:invalid, errors)
        else
          publish_event(:valid, user)
        end
      end
    end

Then, objects that care about those events can subscribe to them:

    class ValidationLogger
      def initialize(name, logger = nil)
        @logger = logger || Logger.new(STDERR)
        @name = name
      end

      def log_validation_error(errors)
        logger.warn("Validation errors on #{name}: #{errors}")
      end
    end

    class CreateUser
      def initialize(logger = nil)
        @logger = logger
      end

      def perform(user_attrs)
        user = User.new(attrs)
        validation_logger = ValidationLogger.new("User creation", logger)
        validator = UserValidator.new(user)
        validator.add_subscriber(self, :valid => :handle_valid_user, :invalid => :handle_invalid_user)
        validator.add_subscriber(validation_logger, :invalid => :log_validation_error)
        validator.validate
      end

      def handle_valid_user(user)
        # ...
      end

      def handle_invalid_user(errors)
       # ...
      end
    end

    CreateUser.new \
      .perform(:username => 'foo', :email => 'foo@example.com', :password => 'foopassword')

See the examples under `/spec` for more information.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
