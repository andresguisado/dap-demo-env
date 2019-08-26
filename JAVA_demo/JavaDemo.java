public class JavaDemo {

	public static void main(String[] args) {

	  
	  ConjurJava.initJavaKeyStore(System.getenv("JAVA_KEY_STORE_FILE"),
			   System.getenv("JAVA_KEY_STORE_PASSWORD") );

	  ConjurJava.initConnection( System.getenv("CONJUR_APPLIANCE_URL"),
			  System.getenv("CONJUR_ACCOUNT") );
	/*
	  ConjurJava.getHealth();
	  String apiKey = ConjurJava.authnLogin(   System.getenv("CONJUR_USER"),
					System.getenv("CONJUR_PASSWORD") );
	  ConjurJava.authenticate(System.getenv("CONJUR_USER"), apiKey);
	 */

	  ConjurJava.authenticate( System.getenv("CONJUR_AUTHN_LOGIN"),
			System.getenv("CONJUR_AUTHN_API_KEY") );

  	  System.out.println("Secret value: " 
			+ ConjurJava.variableValue(System.getenv("CONJUR_VAR_ID")) );

	} // main()

} // JavaDemo
