import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Base64;
import java.io.UnsupportedEncodingException;

public class ConjurJava {

	public static String conjur_appliance_url = System.getenv("CONJUR_APPLIANCE_URL");
	public static String conjur_account = System.getenv("CONJUR_ACCOUNT");
	public static String conjur_user = System.getenv("CONJUR_USER");
	public static String conjur_password = System.getenv("CONJUR_PASSWORD");
	public static String conjur_authn_login = System.getenv("CONJUR_AUTHN_LOGIN");
	public static String conjur_authn_api_key = System.getenv("CONJUR_AUTHN_API_KEY");
	public static String conjur_var_id = System.getenv("CONJUR_VAR_ID");

	/***********************
	 * main()
	 ***********************/
	public static void main(String[] args) {

	  String authHeader, requestURL = "";

	  // open key store containing Conjur cert
	  System.setProperty("javax.net.ssl.trustStore", "./conjur.jks");
	  System.setProperty("javax.net.ssl.trustStorePassword", "changeit");
	  System.setProperty("javax.net.ssl.trustStoreType", "JKS");

	  // basic health check
	  /*
	  String health = conjurGet(conjur_appliance_url + "/health", "");
  	  System.out.println("Health output:" + health);
	  */

	  // Login human user with password to get user's API key 
	  // Note: This is skipped when using a host login w/ api-key
	  /*
	  authHeader = "Basic " + base64Encode(conjur_user + ":" + conjur_password);
	  requestURL = conjur_appliance_url + "/authn/" + conjur_account + "/login";
	  conjur_authn_api_key = conjurGet(requestURL, authHeader);
  	  System.out.println("API key: " + conjur_authn_api_key);
	  conjur_authn_login = conjur_user;
	  */

	  // Authenticate with API key to get access token
	  requestURL = conjur_appliance_url + "/authn/" + conjur_account + "/" + conjur_authn_login + "/authenticate";
	  String rawToken = conjurPost(requestURL, conjur_authn_api_key);
  	  // System.out.println("Raw token: " + rawToken);
	  String accessToken = base64Encode(rawToken);
	  // System.out.println("Access token: " + accessToken);

	  // Get variable using access token
	  authHeader = "Token token=\"" + accessToken + "\""; 
	  requestURL = conjur_appliance_url + "/secrets/" + conjur_account + "/variable/" + conjur_var_id;
	  String secretValue = conjurGet(requestURL, authHeader);
  	  System.out.println("Secret value: " + secretValue);

	} // main()

	/***********************
	 * String conjurGet()
	 ***********************/
        public static String conjurGet(String url_string, String auth_header) {
	  String output = "";
	  try {
		URL url = new URL(url_string);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("GET");
		conn.setRequestProperty("Accept", "application/json");
		conn.setRequestProperty("Authorization", auth_header);

		if (conn.getResponseCode() != 200) {
			throw new RuntimeException("Failed : HTTP error code : "
					+ conn.getResponseCode());
		}

		BufferedReader br = new BufferedReader(new InputStreamReader(
			(conn.getInputStream())));

		String tmp;
		while ((tmp = br.readLine()) != null) {
			output = output + tmp;
		}

		conn.disconnect();

	  } catch (MalformedURLException e) {
		e.printStackTrace();
	  } catch (IOException e) {
		e.printStackTrace();
	  }

	  return output;

	} // conjurGet()


	/***********************
	 * conjurPost()
	 ***********************/
        public static String conjurPost(String url_string, String input) {
	  String output = "";
	  try {
	  	URL url = new URL(url_string);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestMethod("POST");
		conn.setRequestProperty("Content-Type", "application/json");

		OutputStream os = conn.getOutputStream();
		os.write(input.getBytes());
		os.flush();

		if (conn.getResponseCode() != 200) {
			throw new RuntimeException("Failed : HTTP error code : "
					+ conn.getResponseCode());
		}

		BufferedReader br = new BufferedReader(new InputStreamReader(
				(conn.getInputStream())));

		String tmp;
		while ((tmp = br.readLine()) != null) {
			output = output + tmp;
		}

		conn.disconnect();

	  } catch (MalformedURLException e) {
		e.printStackTrace();
	  } catch (IOException e) {
		e.printStackTrace();
	 }

	 return output;

	} // conjurPost()

	/***********************
	 * base64Encode()
	 ***********************/
	static String base64Encode(String input) {
	  String encodedString = "";
	  try {
	    encodedString = Base64.getEncoder().encodeToString(input.getBytes("utf-8"));
	  } catch (UnsupportedEncodingException e) {
		e.printStackTrace();
	  }
	  return encodedString;
	} // base64Encode

} // ConjurJava
