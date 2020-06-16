#!/bin/bash

#
# Command line options:
#    -h,--help			prints the help information
#    -d,--debug			prints debugging information
#    --app 				"<your appname>"
#     						The name of the Veracode Platform application profile you want to scan in
#    --file				"<filename to upload>"
#           				The filename of the file you want to scan (for this script its best to upload a single file as a zip or war etc).
#           				Note: if there are spaces it will need to be surrounded by "s
#    --filepath			"<full path to filename to upload>"
#    	    				The complete filepath to the file to be uploaded 
#    						Note: escape the final \ with an extra \ (i.e. c:\mystuff\example\\) and if there are spaces it will need to be surrounded by "s
#    --crit				"<businsess criticality of the app>"
#           				Valid values are Case-sensitive enum values and are: Very High, High, Medium, Low, and Very Low
#							Note: the value should be surrounded by "s
#    --vid				<your Veracode ID>
#    --vkey         	<your Veracode Key>
#           				Your API credentials VERACODE_ID and VERACODE_KEY which you can generate (and revoke) from the UI
#    --usecreds, -uc	use the Veracode ID and Key credentials stored in ~/.veracode/credentials
#    --sandbox    "<sandbox name>"
#                 The name of the Veracode sandbox to put the upload in.
#
# Example innvocation using stored credentials separated on to two lines for readability but it should be one line
#
#	./veracodeuploadandscan.sh --app=verademoscript --file="my.war" --filepath="C:\\Users\\myuser\\DemoStuff\\shell script\\" 
#	--crit="Very High" --usecreds
#
# Example innvocation using provided credentials separated on to two lines for readability but it should be one line
#
#	./veracodeuploadandscan.sh --app=verademoscript --file="my.war" --filepath="C:\\Users\\myuser\\DemoStuff\\shell script\\" 
#	--crit="Very High" --vid=a251a1d**************** --vkey=312054************

usage()
{

    printf "\n%s is a sample script to upload and scan an application with Veracode using curl and hmac headers\n\n" "$0"
    printf "\t-h,--help\t\tprints this message\n"
    printf "\t-d,--debug\t\tprints debugging information\n"
    printf "\t--app\t\t=\t\"<your appname>\"\n"
    printf "\t--sandbox\t=\t\"<your sandbox name>\"\n"
    printf "\t--file\t\t=\t\"<filename to upload>\"\n"
    printf "\t--filepath\t=\t\"<full path to filename to upload>\"\n"
    printf "\t\t\t\tNote: escape the final \\ with an extra \\ (i.e. c:\mystuff\\\example\\\\\\)\n"
    printf "\t--crit\t\t=\t\"<businsess criticality of the app>\"\n"
    printf "\t--vid\t\t=\t\"<your Veracode ID>\"\n"
    printf "\t--vkey\t\t=\t\"<your Veracode Key>\"\n"
}

if [ "$DEBUG" == "on" ]; then
   printf "\nDebug on\n"
fi

#set default business criticality
BUSINESSCRITICALITY="Very High"
USECREDS="off"

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
	    --debug | -d)
		    DEBUG="on"
			;;
        --app)
		    APP=$VALUE
            ;;
        --sandbox)
		    SANDBOX=$VALUE
            ;;
        --file)
		    FILE=$VALUE
            ;;
		--filepath)
		    FILEPATH=$VALUE
            ;;
        --crit)
		    BUSINESSCRITICALITY=$VALUE
            ;;
		--vid)
           VERACODE_ID=$VALUE
            ;;
		--vkey)
            VERACODE_KEY=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ $APP == "" ]] | [[ $FILE == "" ]] | [[ $SANDBOX == "" ]] ; then
    printf "\n At a minimum you need to specify the app name, sandbox name, file name, file path, and your veracode ID and Key. Here is an example innvocation:\n"
    printf '\t./veracodeupload.sh --app=verademoscript --sandbox="test" --file="my.war" --crit="Very High" --vid=a251a1d**************** --vkey=312054************'
    usage
    exit 0
fi

if [ "$DEBUG" == "on" ]; then
   printf "\n\tRunning %s with the following values\n\n" "$0"
   printf "\t--app\t\t=\t%s\n" "$APP"
   printf "\t--file\t\t=\t%s\n" "$FILE"
  #  printf "\t--filepath\t\t=\t%s\n" "$FILEPATH"
   printf "\t--sandbox\t=\t%s\n" "$SANDBOX"
   printf "\t--crit\t\t=\t%s\n" "$BUSINESSCRITICALITY"
   printf "\t--vid\t\t=\t%s\n" "$VERACODE_ID"
   printf "\t--vkey\t\t=\t%s\n\n" "${VERACODE_KEY:0:5}**********"
fi

if [ "$DEBUG" == "on" ]; then
   printf "\tCheck if the %s profile exists, create it if it does not exist, and get the app id\n" "$APP"
fi

java -jar /veracode/veracode-wrapper.jar -action getapplist -vid "$VERACODE_ID" -vkey "$VERACODE_KEY" > applist.xml || { echo "Get Applications Failed"; cat applist.xml ; exit 1; }

# check the applist to see if the application profile to be used exists
while read -r line
do
    app_name=$(echo $line | grep -Po 'app_name="\K.*?(?=")')
    app_id=$(echo $line | grep -Po 'app_id="\K.*?(?=")')
    if [ "$app_name" = "$APP" ]; then 
	   break
	fi
done < <(grep "$APP" applist.xml)
rm applist.xml

if [ "$app_name" = "$APP" ]; then 
  if [ "$DEBUG" == "on" ]; then
    printf "\n\tThe %s profile with app_id %s exists, not creating\n" "$APP" "$app_id"
  fi
else
  # create the app
  if [ "$DEBUG" == "on" ]; then
    printf "\t%s profile not found create it\n" "$APP"
  fi
  java -jar /veracode/veracode-wrapper.jar -action createapp -vid "$VERACODE_ID" -vkey "$VERACODE_KEY" -appname "$APP" -businesscriticality "$BUSINESSCRITICALITY" > createapp.xml || { echo "Create Application Failed"; cat createapp.xml ; exit 1; }
  app_id=$(cat createapp.xml | grep -Po 'app_id="\K.*?(?=")')
  rm createapp.xml
fi

# get the sandboxlist from the platform
java -jar /veracode/veracode-wrapper.jar -action getsandboxlist -vid "$VERACODE_ID" -vkey "$VERACODE_KEY" -appid "$app_id" > sandboxlist.xml || { echo "Get Sandboxes Failed"; cat sandboxlist.xml ; exit 1; }

# check the sandboxlist to see if the sandbox to be used exists
while read -r line
do
    sandbox_name=$(echo $line | grep -Po 'sandbox_name="\K.*?(?=")')
    sandbox_id=$(echo $line | grep -Po 'sandbox_id="\K.*?(?=")')
    if [ "$sandbox_name" = "$SANDBOX" ]; then 
	   break
	fi
done < <(grep $SANDBOX sandboxlist.xml)
rm sandboxlist.xml

if [ "$sandbox_name" = "$SANDBOX" ]; then 
   if [ "$DEBUG" == "on" ]; then
      printf "\n\tThe %s sandbox with sandbox_id %s exists, not creating\n" "$SANDBOX" "$sandbox_id"
   fi
else
   # create the sandbox
   if [ "$DEBUG" == "on" ]; then
      printf "\t%s sandbox not found create it\n" "$SANDBOX"
   fi
  java -jar /veracode/veracode-wrapper.jar -action createsandbox -vid "$VERACODE_ID" -vkey "$VERACODE_KEY" -appid "$app_id" -sandboxname "$SANDBOX" > createsandbox.xml || { echo "Create Sandbox Failed"; cat createsandbox.xml ; exit 1; }
   sandbox_id=$(cat createsandbox.xml | grep -Po 'sandbox_id="\K.*?(?=")')
   rm createsandbox.xml
fi

# upload the file
printf "\n\tUploading the file %s to %s > %s\n" "$UPLOAD" "$APP" "$SANDBOX"
java -jar /veracode/veracode-wrapper.jar -action uploadfile -vid "$VERACODE_ID" -vkey "$VERACODE_KEY" -appid "$app_id" -sandboxid "$sandbox_id" -filepath "$FILE"  > upload.xml || { echo "Upload Failed"; cat upload.xml ; exit 1; }
echo "Result:"
cat upload.xml
rm upload.xml
