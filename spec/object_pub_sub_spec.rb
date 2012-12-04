require 'object_pub_sub'

describe ObjectPubSub do
  describe "instance methods added to including class" do
    it "forwards subscription requests to the object's subscriber list" do
      subscriber_lists.should_receive(:add_subscriber) \
        .with(subscriber, :event_a, :event_b, :event_c, :and_so_on)
      publisher.add_subscriber(subscriber, :event_a, :event_b, :event_c, :and_so_on)
    end

    it "publishes events to the object's subscriber list" do
      subscriber_lists.should_receive(:publish_event) \
        .with(:did_a_thing, :some_data)
      publisher.do_a_thing
    end

    let(:subscriber_lists) { stub('subscriber_lists') }
    let(:subscriber) { stub('subscriber') }

    let(:publisher) {
      klass = Class.new do
        include ObjectPubSub

        def do_a_thing
          publish_event(:did_a_thing, :some_data)
        end
      end

      klass.new.tap do |p|
        p.stub!(:object_pub_sub_subscriber_lists => subscriber_lists)
      end
    }
  end

  describe ObjectPubSub::SubscriberListManager do
    it "distributes published events to all subscribers" do
      subscriber_a = stub('subscriber_a')
      subscriber_b = stub('subscirber_b')

      subject.add_subscriber(subscriber_a, :event_a)
      subject.add_subscriber(subscriber_b, :event_a)

      subscriber_a.should_receive(:event_a)
      subscriber_b.should_receive(:event_a)
      subject.publish_event(:event_a)
    end

    it "does not distribute an event to subscribers that do not subscribe to that event" do
      subject.add_subscriber(subscriber, :event_b)

      subscriber.should_receive(:event_a).never
      subject.publish_event(:event_a)
    end

    it "only notifies a subscriber once even if it subscribes multiple times" do
      subject.add_subscriber(subscriber, :event_a)
      subject.add_subscriber(subscriber, :event_a)

      subscriber.should_receive(:event_a).once
      subject.publish_event(:event_a)
    end

    it "allows a subscriber to subscribe to multiple events" do
      subject.add_subscriber(subscriber, :event_a, :event_b)

      subscriber.should_receive(:event_a)
      subject.publish_event(:event_a)

      subscriber.should_receive(:event_b)
      subject.publish_event(:event_b)
    end

    it "can publish data along with an event" do
      subject.add_subscriber(subscriber, :event_a)

      subscriber.should_receive(:event_a).with(:some_data)
      subject.publish_event(:event_a, :some_data)
    end

    it "allows the subscriber to specify a custom callback method for some events" do
      subject.add_subscriber(subscriber, :event_b, :event_a => :handle_event_a)

      subscriber.should_receive(:handle_event_a)
      subject.publish_event(:event_a)

      subscriber.should_receive(:event_b)
      subject.publish_event(:event_b)
    end

    let(:subject) { ObjectPubSub::SubscriberListManager.new }

    let(:subscriber) { stub('subscriber') }
  end
end
