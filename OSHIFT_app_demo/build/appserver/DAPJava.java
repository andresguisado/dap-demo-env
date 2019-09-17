import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Base64;
import java.io.UnsupportedEncodingException;

public class DAPJava {

  /******************************************************************
   * 			PUBLIC MEMBERS
   *
   * void initJavaKeyStore(file,password) - opens Java key store containing server cert
   * void initConnection(url,account) - sets private members for appliance URL and account 
   * void getHealth() - basic DAP health check
   * String authnLogin(uname,password) - Logs in human user with password, returns user's API key 
   * void authenticate(name,apikey) - authenticates with API key, sets private access token member
   * void setAccessToken(token) - sets private access token member, use with authn-k8s
   * String variableValue(varname) - gets variable value by name using private members
   *
   ******************************************************************/

	// ===============================================================
	// void initJavaKeyStore() - opens Java key store containing server cert
	//
	public static void initJavaKeyStore(String _jksFile, String _jksPassword) {
	  System.setProperty("javax.net.ssl.trustStore", _jksFile);
	  System.setProperty("javax.net.ssl.trustStorePassword", _jksPassword);
	  System.setProperty("javax.net.ssl.trustStoreType", "JKS");
	}

	// ===============================================================
	// void initConnection() - sets private appliance URL and account members
	//
	public static void initConnection(String _applianceUrl, String _account) {
	   dapApplianceUrl = _applianceUrl;
	   dapAccount = _account;
	}

	// ===============================================================
	// void getHealth() - basic health check
	//
	public static void getHealth() {
  	  System.out.println("Health output:" 
			+ httpGet(dapApplianceUrl + "/health", "") );
	}

	// ===============================================================
	// String authnLogin() - Logs in human user with password, returns user's API key 
	//
	public static String authnLogin(String _user, String _password) {
	  String authHeader = "Basic " + base64Encode(_user + ":" + _password);
	  String requestUrl = dapApplianceUrl
				+ "/authn/" + dapAccount + "/login";
	  String authnApiKey = httpGet(requestUrl, authHeader);
  	  // System.out.println("API key: " + authnApiKey);
	  return authnApiKey;
	}

	// ===============================================================
	// void authenticate() - authenticates with API key, sets private access token member
	//
	public static void authenticate(String _authnLogin, String _apiKey) {
	  String requestUrl = dapApplianceUrl;
	  try {
		requestUrl = requestUrl + "/authn/" + dapAccount + "/" 
				+ URLEncoder.encode(_authnLogin, "UTF-8")+ "/authenticate";
  	  	// System.out.println("Authenticate requestUrl: " + requestUrl);
	  } catch (UnsupportedEncodingException e) {
		e.printStackTrace();
	  }

	  String rawToken = httpPost(requestUrl, _apiKey);
  	  // System.out.println("Raw token: " + rawToken);
	  dapAccessToken = base64Encode(rawToken);
	  // System.out.println("Access token: " + dapAccessToken);
	}

	// ===============================================================
	// void setAccessToken() - sets private access token member, use with authn-k8s
	//
	public static void setAccessToken(String _rawToken) {
	  dapAccessToken = base64Encode(_rawToken);
	}

	// ===============================================================
	// String variableValue() - gets variable value by name using private members
	//
	public static String variableValue(String _varId) {
	  String authHeader = "Token token=\"" + dapAccessToken + "\"";
	  String requestUrl = dapApplianceUrl;
	  try {
		requestUrl = requestUrl + "/secrets/" + dapAccount 
				+ "/variable/" + URLEncoder.encode(_varId, "UTF-8");
  	  	// System.out.println("Variable requestUrl: " + requestUrl);
	  } catch (UnsupportedEncodingException e) {
		e.printStackTrace();
	  }
	  return httpGet(requestUrl, authHeader);
        }

  /******************************************************************
   * 			PRIVATE MEMBERS
   ******************************************************************/

	 static private String dapApplianceUrl;;
	 static private String dapAccount;
	 static private String dapAccessToken;

	// ===============================================================
	// String httpGet() -
	//
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


	// ===============================================================
	// String httpPost() -
	//
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

	// ===============================================================
	// String base64Encode() - base64 encodes argument and returns encoded string
	//
	private static String base64Encode(String input) {
	  String encodedString = "";
	  try {
	    encodedString = Base64.getEncoder().encodeToString(input.getBytes("utf-8"));
	  } catch (UnsupportedEncodingException e) {
		e.printStackTrace();
	  }
	  return encodedString;
	} // base64Encode

} // DAPJava
