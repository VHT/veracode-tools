import java.io.IOException;
import com.veracode.apiwrapper.wrappers.*;
import com.vht.veracode.*;
import org.w3c.dom.*;
import org.apache.commons.cli.*;

public class CreateSandbox
{
  public static void main(String args[])
  {
    Options options = new Options();
    options.addOption("vid", true, "Veracode API ID");
    options.addOption("vkey", true, "Veracode API Key");
    options.addOption("app", true, "Application Name");
    options.addOption("sandbox", true, "Sandbox Name");
    CommandLineParser parser = new DefaultParser();
    HelpFormatter formatter = new HelpFormatter();

    try
    {
      CommandLine cmd = parser.parse(options, args);

      System.out.println("Create Sandbox");
      VeracodeApi api = new VeracodeApi(cmd.getOptionValue("vid"), cmd.getOptionValue("vkey"));
      String appId = api.getAppIdForName(cmd.getOptionValue("app"));
      String sandboxId = api.findOrCreateSandbox(appId, cmd.getOptionValue("sandbox"));
      System.out.println("Application: \"" + cmd.getOptionValue("app") + "\" ID: " + appId);
      System.out.println("Sandbox: \"" + cmd.getOptionValue("sandbox") + "\" ID: " + sandboxId);
      System.exit(0);
    }
    catch(ParseException pe)
    {
      System.out.println(pe);
      formatter.printHelp("CreateSandbox", options);
      System.exit(1);
    }
    catch(IllegalArgumentException iae)
    {
      formatter.printHelp("CreateSandbox", options);
      System.exit(1);
    }
  }
}