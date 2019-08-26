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

	// main() - takes no arguments
	public static void main(String[] args) {

	  initJavaKeyStore(System.getenv("JAVA_KEY_STORE_FILE"),
			   System.getenv("JAVA_KEY_STORE_PASSWORD") );

	  initConnection( System.getenv("CONJUR_APPLIANCE_URL"),
			  System.getenv("CONJUR_ACCOUNT") );
	/*
	  getHealth();
	  String apiKey = authnLogin(   System.getenv("CONJUR_USER"),
					System.getenv("CONJUR_PASSWORD") );
	  authenticate(System.getenv("CONJUR_USER"), apiKey);
	 */

	  authenticate( System.getenv("CONJUR_AUTHN_LOGIN"),
			System.getenv("CONJUR_AUTHN_API_KEY") );

  	  System.out.println("Secret value: " 
			+ variableValue(System.getenv("CONJUR_VAR_ID")) );

	} // main()


	/******************************************************************
	 * PUBLIC MEMBERS
	 ******************************************************************/

	// =====================
	// void initJavaKeyStore - initializes Java key store containing server cert
	public static void initJavaKeyStore(String JKSfile, String JKSpassword) {
	  System.setProperty("javax.net.ssl.trustStore", JKSfile);
	  System.setProperty("javax.net.ssl.trustStorePassword", JKSpassword);
	  System.setProperty("javax.net.ssl.trustStoreType", "JKS");
	}

	// =====================
	// void initConnection() - sets private appliance URL and account members
	public static void initConnection(String _applianceUrl, String _account) {
	   conjurApplianceUrl = _applianceUrl;
	   conjurAccount = _account;
	}

	// =====================
	// void setAccessToken() - sets private access token member
	public static void setAccessToken(String _rawToken) {
	  conjurAccessToken = base64Encode(_rawToken);
	}

	// =====================
	// void getHealth() - basic health check
	public static void getHealth() {
  	  System.out.println("Health output:" 
			+ httpGet(conjurApplianceUrl + "/health", "") );
	}

	// =====================
	// String authnLogin() - Logs in human user with password, returns user's API key 
	public static String authnLogin(String _user, String _password) {
	  String authHeader = "Basic " + base64Encode(_user + ":" + _password);
	  String requestUrl = conjurApplianceUrl
			+ "/authn/" + conjurAccount + "/login";
	  String authnApiKey = httpGet(requestUrl, authHeader);
  	  // System.out.println("API key: " + authnApiKey);
	  return authnApiKey;
	}

	// =====================
	// void authenticate() - authenticates with API key, sets private access token member
	public static void authenticate(String _authnLogin, String _apiKey) {
	  String requestUrl = conjurApplianceUrl
			+ "/authn/" + conjurAccount + "/" 
			+ _authnLogin + "/authenticate";
	  String rawToken = httpPost(requestUrl, _apiKey);
  	  // System.out.println("Raw token: " + rawToken);
	  conjurAccessToken = base64Encode(rawToken);
	  // System.out.println("Access token: " + conjurAccessToken);
	}

	// =====================
	// String variableValue() - gets variable using private access token
	public static String variableValue(String _varId) {
	  String authHeader = "Token token=\"" + conjurAccessToken + "\""; 
	  String requestUrl = conjurApplianceUrl
		+ "/secrets/" + conjurAccount + "/variable/" + _varId;
	  return httpGet(requestUrl, authHeader);
        }

	/******************************************************************
	 * PRIVATE MEMBERS
	 ******************************************************************/

	 static private String conjurApplianceUrl;;
	 static private String conjurAccount;
	 static private String conjurAccessToken;

	// =====================
        private static String httpGet(String url_string, String auth_header) {
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


	// =====================
	// String httpPost() 
        private static String httpPost(String url_string, String bodyContent) {
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

	// =====================
	// String base64Encode() - base64 encodes argument and returns encoded string
	private static String base64Encode(String input) {
	  String encodedString = "";
	  try {
	    encodedString = Base64.getEncoder().encodeToString(input.getBytes("utf-8"));
	  } catch (UnsupportedEncodingException e) {
		e.printStackTrace();
	  }
	  return encodedString;
	} // base64Encode

} // ConjurJava
