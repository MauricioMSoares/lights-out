defmodule LightsOut.Twitter do
  require HTTPoison

  def oauth_header(method, url, params, consumer_key, consumer_secret, token, token_secret) do
    oauth_params = Map.merge(params, %{
      "oauth_consumer_key" => consumer_key,
      "oauth_nonce" => :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower),
      "oauth_signature_method" => "HMAC-SHA1",
      "oauth_timestamp" => DateTime.to_unix(DateTime.utc_now()),
      "oauth_token" => token,
      "oauth_version" => "1.0"
    })

    base_string = oauth_base_string(method, url, oauth_params)
    signing_key = consumer_secret <> "&" <> token_secret
    signature = :crypto.hmac(:sha, signing_key, base_string) |> Base.encode64()

    oauth_params
    |> Map.put("oauth_signature", signature)
    |> Enum.map(fn {k, v} -> "#{k}=\"#{URI.encode_www_form(v)}\"" end)
    |> Enum.join(", ")
    |> (&("OAuth " <> &1)).()
  end

  defp oauth_base_string(method, url, params) do
    encoded_params = params
    |> Enum.sort()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")

    [method, url, encoded_params]
    |> Enum.map(&URI.encode_www_form/1)
    |> Enum.join("&")
  end

  def post_tweet(message) do
    url = "https://api.twitter.com/1.1/statuses/update.json"
    method = "POST"
    params = %{"status" => message}
    consumer_key = System.get_env("X_API_KEY")
    consumer_secret = System.get_env("X_API_SECRET")
    token = System.get_env("X_ACCESS_TOKEN")
    token_secret = System.get_env("X_ACCESS_TOKEN_SECRET")

    headers = [
      {"Authorization", oauth_header(method, url, params, consumer_key, consumer_secret, token, token_secret)},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]
    body = URI.encode_query(params)

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Unexpected status code: #{status_code}")
        IO.puts("Response body: #{body}")
        {:error, %{status_code: status_code, body: body}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("HTTPoison error: #{reason}")
        {:error, %{reason: reason}}
    end
  end
end
