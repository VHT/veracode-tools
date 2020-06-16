import java.io.IOException;
import com.veracode.apiwrapper.wrappers.*;
import com.vht.veracode.*;
import org.w3c.dom.*;
import org.apache.commons.cli.*;

public class BeginPreScan
{
  public static void main(String args[])
  {
    Options options = new Options();
    options.addOption("vid", true, "Veracode API ID");
    options.addOption("vkey", true, "Veracode API Key");
    options.addOption("app", true, "Application Name");
    options.addOption("sandbox", true, "Sandbox Name");
    options.addOption("autoscan", "Auto Start Scan After PreScan");
    CommandLineParser parser = new DefaultParser();
    HelpFormatter formatter = new HelpFormatter();

    try
    {
      CommandLine cmd = parser.parse(options, args);

      System.out.println("Begin Pre Scan");
      VeracodeApi api = new VeracodeApi(cmd.getOptionValue("vid"), cmd.getOptionValue("vkey"));
      String appId = api.getAppIdForName(cmd.getOptionValue("app"));
      String sandboxId = api.findOrCreateSandbox(appId, cmd.getOptionValue("sandbox"));
      String autoScan = cmd.getOptionValue("autoscan") == null ? "false" : "true";
      System.out.println("Application: \"" + cmd.getOptionValue("app") + "\" ID: " + appId);
      System.out.println("Sandbox: \"" + cmd.getOptionValue("sandbox") + "\" ID: " + sandboxId);
      String buildId = api.beginPreScan(appId, sandboxId, autoScan);
      System.out.println("Build ID: " + buildId);
      System.exit(0);
    }
    catch(ParseException pe)
    {
      System.out.println(pe);
      formatter.printHelp("BeginPreScan", options);
      System.exit(1);
    }
    catch(IllegalArgumentException iae)
    {
      formatter.printHelp("BeginPreScan", options);
      System.exit(1);
    }
  }
}