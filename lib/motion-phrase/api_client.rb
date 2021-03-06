module MotionPhrase
  class ApiClient
    API_CLIENT_IDENTIFIER = "motion_phrase"
    API_BASE_URI = "https://phraseapp.com/api/v1/"

    def self.sharedClient
      Dispatch.once { @instance ||= new }
      @instance
    end

    def storeTranslation(keyName, content, fallbackContent, currentLocale)
      return unless auth_token_present?

      content ||= fallbackContent
      data = {
        locale: currentLocale,
        key: keyName,
        content: content,
        allow_update: false,
        skip_verification: true,
        api_client: API_CLIENT_IDENTIFIER,
      }
      client.post("translations/store", authenticated(data)) do |result|
        if result.success?
          log "Translation stored [#{data.inspect}]"
        elsif result.failure?
          log "Error while storing translation [#{data.inspect}]"
        end
      end
    end

  private
    def client
      @client ||= buildClient
    end

    def buildClient
      AFMotion::Client.build_shared(API_BASE_URI) do
        header "Accept", "application/json"
        request_serializer :json
        response_serializer :json
      end
    end

    def log(msg="")
      $stdout.puts "PHRASEAPP #{msg}"
    end

    def authenticated(params={})
      params.merge(auth_token: auth_token)
    end

    def auth_token
      if defined?(PHRASE_AUTH_TOKEN)
        PHRASE_AUTH_TOKEN
      else
        nil
      end
    end

    def auth_token_present?
      !auth_token.nil? && auth_token != ""
    end
  end
end
