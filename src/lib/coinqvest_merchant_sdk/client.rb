require 'rest-client'
require 'json'
require 'time'
require 'coinqvest_merchant_sdk/config'
require 'uri'
require 'openssl'

 # Ruby implementation of a REST client for the COINQVEST Merchant API
 # see https://www.coinqvest.com/en/api-docs
module CoinqvestMerchantSDK

  class Client

    # Merchant API client constructor, initialize this with the API key and secret as given by https://www.coinqvest.com/en/api-settings
    # @param key; as given by https://www.coinqvest.com/en/api-settings
    # @param secret; as given by https://www.coinqvest.com/en/api-settings
    # @param log_file; optional log file path
    # @constructor
    def initialize(key, secret, log_file = nil)

      # @string The API Key as given by https://www.coinqvest.com/en/api-settings
      @key = key

      # @string The API Secret as given by https://www.coinqvest.com/en/api-settings
      @secret = secret

      # @string The API version to which we connect (leave it as is)
      @api_version = CoinqvestMerchantSDK::API_VERSION

      # @string Used in the HTTP user agent (leave it as is)
      @client_name = CoinqvestMerchantSDK::CLIENT_NAME

      # @string The current version of this SDK, used in the HTTP user agent (leave it as is)
      @client_version = CoinqvestMerchantSDK::CLIENT_VERSION

      # @string COINQVEST connect url
      @connect_url = CoinqvestMerchantSDK::CONNECT_URL

      # @string|nil Specifies the log file to which to write, if any.
      @log_file = log_file ? log_file : nil

    end

    # Use this method to communicate with GET endpoints
    # @param endpoint (string), e.g. GET /customer
    # @param params (hash), a list of GET parameters to be included in the request
    # @return RestClient::Response, https://github.com/rest-client/rest-client/blob/2c72a2e77e2e87d25ff38feba0cf048d51bd5eca/lib/restclient/response.rb
    def get(endpoint, params = {})

      path = build_connect_url(endpoint) + '?' +  URI.encode_www_form(params)
      headers = build_headers(endpoint, 'GET', params)

      log "GET " + path
      log headers.to_s

      begin
        response = RestClient::Request.execute(method: :get, url: path, headers: headers, timeout: 180)
      rescue RestClient::ExceptionWithResponse => e
        log e.http_code.to_s + " " + e.response.to_s
        return e.response
      end

      log response.code.to_s + " " + response.to_s

      response

    end

    # Use this method to communicate with POST endpoints
    # @param endpoint (string), e.g. POST /checkout/hosted
    # @param params (hash), a list of GET parameters to be included in the request
    # @return RestClient::Response, https://github.com/rest-client/rest-client/blob/2c72a2e77e2e87d25ff38feba0cf048d51bd5eca/lib/restclient/response.rb
    def post(endpoint, params = {})

      path = build_connect_url(endpoint)
      headers = build_headers(endpoint, 'POST', params)

      log "POST " + path + " " + params.to_s
      log headers.to_s

      begin
        response = RestClient::Request.execute(method: :post, url: path, payload: params.to_json, headers: headers, timeout: 180)
      rescue RestClient::ExceptionWithResponse => e
        log e.http_code.to_s + " " + e.response.to_s
        return e.response
      end

      log response.code.to_s + " " + response.to_s

      response

    end

    # Use this method to communicate with PUT endpoints
    # @param endpoint (string), e.g. PUT /customer
    # @param params (hash), a list of GET parameters to be included in the request
    # @return RestClient::Response, https://github.com/rest-client/rest-client/blob/2c72a2e77e2e87d25ff38feba0cf048d51bd5eca/lib/restclient/response.rb
    def put(endpoint, params = {})

      path = build_connect_url(endpoint)
      headers = build_headers(endpoint, 'PUT', params)

      log "PUT " + path + " " + params.to_s
      log headers.to_s

      begin
        response = RestClient::Request.execute(method: :put, url: path, payload: params.to_json, headers: headers, timeout: 180)
      rescue RestClient::ExceptionWithResponse => e
        log e.http_code.to_s + " " + e.response.to_s
        return e.response
      end

      log response.code.to_s + " " + response.to_s

      response

    end

    # Use this method to communicate with PUT endpoints
    # @param endpoint (string), e.g. PUT /customer
    # @param params (hash), a list of GET parameters to be included in the request
    # @return RestClient::Response, https://github.com/rest-client/rest-client/blob/2c72a2e77e2e87d25ff38feba0cf048d51bd5eca/lib/restclient/response.rb
    def delete(endpoint, params = {})

      path = build_connect_url(endpoint)
      headers = build_headers(endpoint, 'DELETE', params)

      log "DELETE " + path + " " + params.to_s
      log headers.to_s

      begin
        response = RestClient::Request.execute(method: :delete, url: path, payload: params.to_json, headers: headers, timeout: 180)
      rescue RestClient::ExceptionWithResponse => e
        log e.http_code.to_s + " " + e.response.to_s
        return e.response
      end

      log response.code.to_s + " " + response.to_s

      response

    end

    # private class to generate connect url on COINQVEST servers
    private
    def build_connect_url(endpoint)
      @connect_url + @api_version + endpoint
    end

    # private class to generate authentication headers
    private
    def build_headers(endpoint, method, params)

      timestamp = Time.now.to_i
      body = nil
      if method != 'GET'
        body = params.length > 0 ? params.to_json : nil
      end
      data = endpoint + timestamp.to_s + method + body.to_s

      {
          :"X-Digest-Key" => @key,
          :"X-Digest-Signature" => OpenSSL::HMAC.hexdigest('sha256', @secret, data),
          :"X-Digest-Timestamp" => timestamp,
          :"User-Agent" => @client_name + " " + @client_version
      }

    end


    private
    def log(text)

      if @log_file == nil
        return
      end

      File.open(@log_file, 'a') { |f| f.write(Time.now.utc.rfc822 + " [CoinqvestMerchantSDK] " + text + "\n") }
      # print Time.now.utc.rfc822 + " [CoinqvestMerchantSDK] " + text + "\n"

    end

  end

end
