package com.vht.veracode;

import java.io.IOException;
import com.veracode.apiwrapper.wrappers.*;
import com.vht.veracode.*;
import org.w3c.dom.*;

public class VeracodeApi
{
  private UploadAPIWrapper uploadApi;
  private SandboxAPIWrapper sandboxApi;

  public VeracodeApi(String vid, String vkey)
  {
    this.uploadApi = new UploadAPIWrapper();
    this.uploadApi.setUpApiCredentials(vid, vkey);
    this.sandboxApi = new SandboxAPIWrapper();
    this.sandboxApi.setUpApiCredentials(vid, vkey);
  }

  public String getAppIdForName(String appName)
  {
    try {
      String listResponse = uploadApi.getAppList();
      ResponseParser parser = new ResponseParser();
      Element root = parser.parse(listResponse);
      NodeList appList = root.getElementsByTagName("app");
      for (int i = 0; i < appList.getLength(); i++) {
        Element app = (Element)appList.item(i);
        String name = app.getAttribute("app_name");
        if(name.equals(appName)) {
          return app.getAttribute("app_id");
        }
      }
      return null;
    }
    catch (java.io.IOException ioe)
    {
      System.out.println(ioe);
      System.exit(1);
      return null;
    }
  }

  public String getSandboxIdForName(String appId, String sandboxName)
  {
    try {
      String listResponse = this.sandboxApi.getSandboxList(appId);
      ResponseParser parser = new ResponseParser();
      Element root = parser.parse(listResponse);
      NodeList appList = root.getElementsByTagName("sandbox");
      for (int i = 0; i < appList.getLength(); i++) {
        Element app = (Element)appList.item(i);
        String name = app.getAttribute("sandbox_name");
        if(name.equals(sandboxName)) {
          return app.getAttribute("sandbox_id");
        }
      }
      return null;
    }
    catch (java.io.IOException ioe)
    {
      System.out.println(ioe);
      System.exit(1);
      return null;
    }
  }

  public String getSandboxBuildIdForName(String appId, String sandboxId, String buildName)
  {
    try {
      String listResponse = this.uploadApi.getBuildList(appId, sandboxId);
      ResponseParser parser = new ResponseParser();
      Element root = parser.parse(listResponse);
      NodeList appList = root.getElementsByTagName("build");
      for (int i = 0; i < appList.getLength(); i++) {
        Element app = (Element)appList.item(i);
        String name = app.getAttribute("version");
        if(name.equals(buildName)) {
          return app.getAttribute("build_id");
        }
      }
      return null;
    }
    catch (java.io.IOException ioe)
    {
      System.out.println(ioe);
      System.exit(1);
      return null;
    }
  }

  public String findOrCreateSandbox(String appId, String sandboxName) {
    String sandboxId = this.getSandboxIdForName(appId, sandboxName);
    String response = "<none>";

    if(sandboxId == null) {
      try
      {
        response = this.sandboxApi.createSandbox(appId, sandboxName);
        ResponseParser parser = new ResponseParser();
        Element root = parser.parse(response);
        NodeList list = root.getElementsByTagName("sandbox");
        if(list.getLength() > 0)
        {
          sandboxId = ((Element)list.item(0)).getAttribute("sandbox_id");
        }
      }
      catch (java.io.IOException ioe)
      {
        System.out.println(ioe);
        System.exit(1);
        return null;
      }
    }
    if(sandboxId == null)
    {
      System.out.println("Could not create sandbox named \"" + sandboxName + "\"");
      System.out.println(response);
      System.exit(1);
    }
    return sandboxId;
  }

  public String findOrCreateSandboxBuild(String appId, String sandboxId, String buildName)
  {
    String buildId = this.getSandboxBuildIdForName(appId, sandboxId, buildName);
    String response = "<none>";
    String platform = null;
    String platformId = null;
    String lifecycleStage = null;
    String lifecycleStageId = null;
    String launchDate = null;

    if(buildId == null)
    {
      try
      {
        response = this.uploadApi.createBuild(appId, buildName, platform, platformId, lifecycleStage, lifecycleStageId, launchDate, sandboxId);
        ResponseParser parser = new ResponseParser();
        Element root = parser.parse(response);
        NodeList list = root.getElementsByTagName("build");
        if(list.getLength() > 0)
        {
          buildId = ((Element)list.item(0)).getAttribute("build_id");
        }
      }
      catch (java.io.IOException ioe)
      {
        System.out.println(ioe);
        System.exit(1);
        return null;
      }
    }
    if(buildId == null)
    {
      System.out.println("Could not create sandbox build named \"" + buildName + "\"");
      System.out.println(response);
      System.exit(1);
    }
    return buildId;
  }

  public String beginPreScan(String appId, String sandboxId, String autoScan)
  {
    String response = "<none>";
    String buildId = null;

    try
    {
      response = this.uploadApi.beginPreScan(appId, sandboxId, autoScan);
      ResponseParser parser = new ResponseParser();
      Element root = parser.parse(response);
      NodeList list = root.getElementsByTagName("build");
      if(list.getLength() > 0)
      {
        buildId = ((Element)list.item(0)).getAttribute("build_id");
      }

      if(buildId == null)
      {
        System.out.println("Could not start PreScan");
        System.out.println(response);
        System.exit(1);
      }
      return buildId;
    }
    catch (java.io.IOException ioe)
    {
      System.out.println(ioe);
      System.exit(1);
      return null;
    }
  }
}