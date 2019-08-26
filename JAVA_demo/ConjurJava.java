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

	// set global variables from environment variables
	public static String java_key_store_file = System.getenv("JAVA_KEY_STORE_FILE");
	public static String java_key_store_password = System.getenv("JAVA_KEY_STORE_PASSWORD");
	public static String conjur_appliance_url = System.getenv("CONJUR_APPLIANCE_URL");
	public static String conjur_account = System.getenv("CONJUR_ACCOUNT");
	public static String conjur_user = System.getenv("CONJUR_USER");
	public static String conjur_password = System.getenv("CONJUR_PASSWORD");
	public static String conjur_authn_login = System.getenv("CONJUR_AUTHN_LOGIN");
	public static String conjur_authn_api_key = System.getenv("CONJUR_AUTHN_API_KEY");
	public static String conjur_var_id = System.getenv("CONJUR_VAR_ID");

	/***********************
	 * main() - takes no arguments
	 ***********************/
	public static void main(String[] args) {

	  String authHeader, requestURL = "";

	  // open key store containing Conjur cert
	  System.setProperty("javax.net.ssl.trustStore", java_key_store_file);
	  System.setProperty("javax.net.ssl.trustStorePassword", java_key_store_password);
	  System.setProperty("javax.net.ssl.trustStoreType", "JKS");

	  // basic health check
	  /*
	  String health = httpGet(conjur_appliance_url + "/health", "");
  	  System.out.println("Health output:" + health);
	  */

	  // Login human user with password to get user's API key 
	  // Note: This is should be skipped when using a host login w/ api-key
	  /*
	  authHeader = "Basic " + base64Encode(conjur_user + ":" + conjur_password);
	  requestURL = conjur_appliance_url + "/authn/" + conjur_account + "/login";
	  conjur_authn_api_key = httpGet(requestURL, authHeader);
  	  System.out.println("API key: " + conjur_authn_api_key);
	  conjur_authn_login = conjur_user;
	  */

	  // Authenticate with API key to get raw access token, base64 encode the token
	  requestURL = conjur_appliance_url + "/authn/" + conjur_account + "/" + conjur_authn_login + "/authenticate";
	  String rawToken = httpPost(requestURL, conjur_authn_api_key);
  	  // System.out.println("Raw token: " + rawToken);
	  String accessToken = base64Encode(rawToken);
	  // System.out.println("Access token: " + accessToken);

	  // Get variable using encoded access token
	  authHeader = "Token token=\"" + accessToken + "\""; 
	  requestURL = conjur_appliance_url + "/secrets/" + conjur_account + "/variable/" + conjur_var_id;
	  String secretValue = httpGet(requestURL, authHeader);
  	  System.out.println("Secret value: " + secretValue);

	} // main()

	/***********************
	 * String httpGet()
	 ***********************/
        public static String httpGet(String url_string, String auth_header) {
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

	} // httpGet()


	/***********************
	 * httpPost()
	 ***********************/
        public static String httpPost(String url_string, String bodyContent) {
	  String output = "";
	  try {
	  	URL url = new URL(url_string);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestMethod("POST");
		conn.setRequestProperty("Content-Type", "application/json");

		OutputStream os = conn.getOutputStream();
		os.write(bodyContent.getBytes());
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

	} // httpPost()

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
