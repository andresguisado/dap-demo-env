/*
 */

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.cert.X509Certificate;
import java.security.NoSuchAlgorithmException;
import java.security.KeyManagementException;

import com.google.gson.Gson;

public class OnboardProject {

    public static Boolean DEBUG=false;

    public static void main(String[] args) {

	// set to true to enable debug output
	PASJava.DEBUG=false;
	DAPJava.DEBUG=false;
	JavaREST.DEBUG=false;

	// turn off all cert validation - FOR DEMO ONLY
	disableSSL(); 

	// Initialize connection to PAS
	PASJava.initConnection( System.getenv("PAS_IIS_SERVER_IP") );
	PASJava.logon(	System.getenv("PAS_ADMIN_NAME"), System.getenv("PAS_ADMIN_PASSWORD") );

	// Get safe parameters
	String pasSafeName = System.getenv("PAS_SAFE_NAME");
	String pasCPMName = System.getenv("PAS_CPM_NAME");
	String pasLOBName = System.getenv("PAS_LOB_NAME");

        System.out.println("Creating safe:\n"
			  + "  Safe name: " + pasSafeName + "\n"
			  + "  LOB member: " + pasLOBName);
	PASSafe newSafe = PASJava.addSafe(pasSafeName, pasCPMName);
	PASJava.addSafeMember(pasSafeName, pasLOBName);
	PASJava.addSafeMember(pasSafeName, "Administrator");	// Always add Administrator as safe member

	// Get account parameters
	String pasAccountName = System.getenv("PAS_ACCOUNT_NAME");
	String pasPlatformId = System.getenv("PAS_PLATFORM_ID");
	String pasAddress = System.getenv("PAS_ADDRESS");
	String pasUserName = System.getenv("PAS_USERNAME");
	String pasSecretType = System.getenv("PAS_SECRET_TYPE");
	String pasSecretValue = System.getenv("PAS_SECRET_VALUE");

        System.out.println("Creating account:\n"
			 + "  Account: " + pasAccountName + "\n"
			 + "  Platform ID: " + pasPlatformId);
	PASAccount pasAccount = PASJava.addAccount(pasSafeName,
						   pasAccountName,
						   pasPlatformId,
						   pasAddress,
						   pasUserName,
						   pasSecretType,
						   pasSecretValue);
	// Apply Vault/Conjur sync policies
	String pasVaultName = System.getenv("PAS_VAULT_NAME");
	preloadSyncPolicy(pasVaultName, pasLOBName, pasSafeName);

    } // main()

    // ==========================================
    // preloadSyncPolicy(vaultName,lobName,safeName)
    //
    public static void preloadSyncPolicy(String _vaultName, String _lobName, String _safeName) {

        System.out.println("Preloading sync policy:\n"
			 + "  Vault name: " + _vaultName + "\n"
			 + "  LOB name: " + _lobName + "\n"
			 + "  Safe name: " +_safeName);

        DAPJava.initConnection(
                                System.getenv("CONJUR_APPLIANCE_URL"),
                                System.getenv("CONJUR_ACCOUNT")
                                );
        String userApiKey = DAPJava.authnLogin(
                                System.getenv("CONJUR_USER"),
                                System.getenv("CONJUR_PASSWORD")
                                );
        DAPJava.authenticate(
                                System.getenv("CONJUR_USER"),
                                userApiKey
                                );

	// generate policy - REST method accepts text - no need to create a file
        String policyText = "---\n"
                            + "- !policy\n"
                            + "  id: " + _vaultName + "\n"
                            + "  body:\n"
                            + "  - !group " + _lobName + "-admins\n"
                            + "  - !policy\n"
                            + "    id: " + _lobName + "\n"
                            + "    owner: !group /" + _vaultName + "/" + _lobName + "-admins\n"
                            + "    body:\n"
                            + "    - !group " + _safeName + "-admins\n"
                            + "    - !policy\n"
                            + "      id: " + _safeName + "\n"
                            + "      body:\n"
                            + "      - !policy\n"
                            + "        id: delegation\n"
                            + "        owner: !group /" + _vaultName + "/" + _lobName + "/" + _safeName + "-admins\n"
                            + "        body:\n"
                            + "        - !group consumers\n";

        // load policy using default "append" method 
        DAPJava.loadPolicy("append", "root", policyText);

    } // preloadSyncPolicy()

/*********************************************************
 *********************************************************
 **                    PRIVATE MEMBERS			**
 *********************************************************
 *********************************************************/

    // ==========================================
    // void disableSSL()
    //   from: https://nakov.com/blog/2009/07/16/disable-certificate-validation-in-java-ssl-connections/
    //
    private static void disableSSL() {
        // Create a trust manager that does not validate certificate chains
        TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                    return null;
                }
                public void checkClientTrusted(X509Certificate[] certs, String authType) {
                }
                public void checkServerTrusted(X509Certificate[] certs, String authType) {
                }
            }
        };
 
        // Install the all-trusting trust manager
	try {
	        SSLContext sc = SSLContext.getInstance("SSL");
        	sc.init(null, trustAllCerts, new java.security.SecureRandom());
        	HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
	} catch(NoSuchAlgorithmException e) {
		e.printStackTrace();
	} catch(KeyManagementException e) {
		e.printStackTrace();
	}

        // Create all-trusting host name verifier
        HostnameVerifier allHostsValid = new HostnameVerifier() {
            public boolean verify(String hostname, SSLSession session) {
                return true;
            }
        };
 
        // Install the all-trusting host verifier
        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);

    } // disableSSL
 
} // AnnotateDAPVars
