# frozen_string_literal: true

require "harvest_notifier/templates/base"

module HarvestNotifier
  module Templates
    class DailyReport < Base
      REMINDER_TEXT = "*Vergeet niet je uren te boeken.*"
      USERS_LIST_TEXT = "Hier is een herinnering voor de mensen die nog geen uren geboekt hebben voor *%<current_date>s*:"
      REPORT_NOTICE_TEXT = "_Als je je uren geboekt heb, reageer dan met de :heavy_check_mark: in dit bericht._"
      SLACK_ID_ITEM = "• <@%<slack_id>s>"
      FULL_NAME_ITEM = "• %<full_name>s"

      def generate # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Jbuilder.encode do |json| # rubocop:disable Metrics/BlockLength
          json.channel channel
          json.blocks do # rubocop:disable Metrics/BlockLength
            # Reminder text
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text REMINDER_TEXT
              end
            end

            # Pretext list of users
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text format(USERS_LIST_TEXT, current_date: formatted_date)
              end
            end

            # List of users
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text users_list
              end
            end

            # Report notice
            json.child! do
              json.type "section"
              json.text do
                json.type "mrkdwn"
                json.text REPORT_NOTICE_TEXT
              end
            end

            # Buttons
            json.child! do
              json.type "actions"
              json.elements do
                json.child! do
                  json.type "button"
                  json.url url
                  json.style "primary"
                  json.text do
                    json.type "plain_text"
                    json.text "Uren boeken"
                  end
                end

                json.child! do
                  json.type "button"
                  json.text do
                    json.type "plain_text"
                    json.text ":repeat: Bijwerken!"
                  end
                  json.value refresh_value
                end
              end
            end
          end
        end
      end

      private

      def formatted_date
        assigns[:date].strftime("%B%eth")
      end

      def refresh_value
        "daily:#{assigns[:date]}"
      end

      def users_list
        assigns[:users]
          .map { |u| u[:slack_id].present? ? format(SLACK_ID_ITEM, u) : format(FULL_NAME_ITEM, u) }
          .join("\n")
      end
    end
  end
end
