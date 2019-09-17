/*
 * K8s app test driver for DAPJava class
 */
import java.io.File;
import java.util.Scanner;

public class JavaDemo {
    public static void main(String[] args) {

	if(args.length != 1)
	{
		System.out.println("Name of variable required as argument.");
		System.exit(0);
	}

	DAPJava.initJavaKeyStore(
				System.getenv("JAVA_KEY_STORE_FILE"),
				System.getenv("JAVA_KEY_STORE_PASSWORD")
				);

	DAPJava.initConnection(
				System.getenv("CONJUR_APPLIANCE_URL"),
				System.getenv("CONJUR_ACCOUNT")
				);

	// Read access token from file in shared volume
	File file = new File( System.getenv("CONJUR_AUTHN_TOKEN_FILE") );
	Scanner sc = new Scanner(file); 
	String accessToken = sc.next();
	System.out.println("Access token: " + accessToken);

	DAPJava.setAccessToken(accessToken);

  	System.out.println("Secret value: " + DAPJava.variableValue(args[0]) );

    } // main()
} // JavaDemo
