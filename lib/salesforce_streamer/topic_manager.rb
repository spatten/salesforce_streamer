# frozen_string_literal: true

module SalesforceStreamer
  class TopicManager
    attr_reader :push_topics

    def initialize(push_topics:, config:)
      @push_topics = push_topics
      @config = config
      @logger = config.logger
      @client = ::SalesforceStreamer.salesforce_client
    end

    def run
      @logger.info 'Running Topic Manager'
      @push_topics.each do |push_topic|
        @logger.debug push_topic.to_s
        if diff?(push_topic)
          upsert(push_topic)
        end
      end
    end

    private

    def diff?(push_topic)
      hashie = @client.push_topic_by_name(push_topic.name)
      unless hashie
        @logger.info "New PushTopic #{push_topic.name}"
        return true
      end
      @logger.debug "Remote PushTopic found with hash=#{hashie.to_h}"
      push_topic.id = hashie.Id
      return true unless push_topic.query.eql?(hashie.Query)
      return true unless push_topic.name.eql?(hashie.Name)
      return true unless push_topic.notify_for_fields.eql?(hashie.NotifyForFields)
      return true unless push_topic.api_version.eql?(hashie.ApiVersion)
      @logger.debug 'No differences detected'
      false
    end

    def upsert(push_topic)
      @logger.info "Upsert PushTopic #{push_topic.name}"
      if @config.manage_topics?
        @client.upsert_push_topic(push_topic)
      else
        @logger.info 'Skipping upsert because manage topics is off'
      end
    end
  end
end
