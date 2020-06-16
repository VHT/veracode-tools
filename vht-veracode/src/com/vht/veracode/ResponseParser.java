package com.vht.veracode;

import org.w3c.dom.*;
import org.xml.sax.*;
import javax.xml.parsers.*;
import java.io.*;

public class ResponseParser
{
  public Element parse(String xmlStr)
  {
    try
    {
      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      DocumentBuilder builder = factory.newDocumentBuilder();
      ByteArrayInputStream input = new ByteArrayInputStream(xmlStr.getBytes("UTF-8"));
      Document doc = builder.parse(input);
      return doc.getDocumentElement();
    }
    catch (ParserConfigurationException pce)
    {
      System.out.println(pce);
      System.exit(1);
      return null;
    }
    catch (SAXException se)
    {
      System.out.println(se);
      System.exit(1);
      return null;
    }
    catch (IOException ioe)
    {
      System.out.println(ioe);
      System.exit(1);
      return null;
    }
  }
}