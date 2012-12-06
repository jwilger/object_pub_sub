require 'active_support/concern'

module ObjectPubSub
  extend ActiveSupport::Concern

  def add_subscriber(*args)
    object_pub_sub_subscriber_lists.add_subscriber(*args)
  end

  private

  def publish_event(*args)
    object_pub_sub_subscriber_lists.publish_event(*args)
  end

  def object_pub_sub_subscriber_lists
    @object_pub_sub_subscriber_lists ||= SubscriberListManager.new
  end

  class SubscriberListManager
    class SubscriberList
      def initialize
        @subscribers = []
      end

      def add_subscriber(subscriber, callback_method)
        callback_pair = [subscriber, callback_method]
        return if @subscribers.include?(callback_pair)
        @subscribers << callback_pair
      end

      def publish_event(*data)
        @subscribers.each do |subscriber, callback_method|
          subscriber.send(callback_method, *data)
        end
      end
    end

    def initialize
      @subscriber_lists ||= {}
    end

    def add_subscriber(subscriber, *event_names)
      callback_map(event_names).each do |event_name, callback_method|
        subscriber_list_for(event_name).add_subscriber(subscriber, callback_method)
      end
    end

    def publish_event(event_name, *data)
      subscriber_list_for(event_name).publish_event(*data)
    end

    private

    def callback_map(event_names)
      callback_map = {}
      last_one = event_names.pop
      if last_one.kind_of?(Hash)
        callback_map.merge!(last_one)
      else
        callback_map[last_one] = last_one
      end
      event_names.each do |event_name|
        callback_map[event_name] = event_name
      end
      callback_map
    end

    def subscriber_list_for(event_name)
      @subscriber_lists.fetch(event_name) do
        @subscriber_lists[event_name] = SubscriberList.new
      end
    end
  end
end
