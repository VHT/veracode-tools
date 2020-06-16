# Veracode Tools Docker Image

Docker image with all Veracode tools pre-installed. This is not an official Veracode project, Veracode support will not be able to provide assistance with issues.

    docker pull virtualhold/veracode-tools

For all the commands below you can bind mount your application source/build directory into `/workspace`, which is the working directory when running commands interactively.

    docker run -it -v /source-dir:/workspace ...

## Java API Wrapper

    docker run -it --rm -v /source-dir:/workspace \
    virtualhold/veracode-tools:latest java -jar /veracode/veracode-wrapper.jar

## Pipeline Scan CI Tool

    docker run -it --rm -v /source-dir:/workspace \
    virtualhold/veracode-tools:latest java -jar /veracode/pipeline-scan.jar

## Python/HTTPie

### Option 1: Bind mount API credentials

Set up a local `~/.veracode/credentials` file with API credentials:

    [default]
    veracode_api_key_id = <YOUR_API_KEY_ID>
    veracode_api_key_secret = <YOUR_API_KEY_SECRET>

then bind mount into the container:

    docker run -it --rm -v /source-dir:/workspace \
    -v ~/.veracode/credentials:/root/.veracode/credentials \
    virtualhold/veracode-tools:latest http -A veracode_hmac https://api.veracode.com/appsec/v1/applications

### Option 2: Provide environment variables

    docker run -it --rm -v /source-dir:/workspace \
    --env VERACODE_API_KEY_ID=shf389f3j... --env VERACODE_API_KEY_SECRET=sijfsnfsn... \
    virtualhold/veracode-tools:latest http -A veracode_hmac https://api.veracode.com/appsec/v1/applications

## SourceClear

You may need to install an appropriate build system for SourceClear. Maven should work without doing any additional installs.

### Option 1: Bind mount an `agent.yml` file

    docker run -it --rm -v /source-dir:/workspace \
    -v ~/.srcclr/agent.yml:/root/.srcclr/agent.yml \
    virtualhold/veracode-tools:latest srcclr scan

### Option 2: Provide an environment variable

    docker run -it --rm -v /source-dir:/workspace \
    --env SRCCLR_API_TOKEN=eyJhbGciOi... \
    virtualhold/veracode-tools:latest srcclr scan

## tar-globs

Since the static scans require uploading a zip file containing source, you can use the [@vht/tar-globs](https://github.com/VHT/tar-globs) utility to create the archive.

    docker run -it --rm -v /source-dir:/workspace \
    virtualhold/veracode-tools:latest tar-globs -i ./veracode_whitelist.dat -o veracode.tar.gz

# VHT Veracode Wrapper

In the `vht-veracode/` directory of this repo is a Java project that includes and wrappers the veracode-wrappers.jar library sot hatw e can add features and commands that are not included y Veracode.

## CreateSandbox

Finds a Veracode Sandbox with the given name under the Application. If it does not exist, then it is created.

    docker run -it --rm -v /source-dir:/workspace \
    virtualhold/veracode-tools:latest java -cp /veracode/vht-veracode.jar CreateSandbox \
    -vid "..." \
    -vkey "..." \
    -app "Application Name" \
    -sandbox "Sandbox Name"

## CreateBuild

Finds a Veracode Build with the given name under the Application and Sandbox. If the Sandbox or Build does not exist, then it is created.

    docker run -it --rm -v /source-dir:/workspace \
    virtualhold/veracode-tools:latest java -cp /veracode/vht-veracode.jar CreateBuild \
    -vid "..." \
    -vkey "..." \
    -app "Application Name" \
    -sandbox "Sandbox Name" \
    -build "Build Name"

## BeginPreScan

Begins the PreScan for a Sandbox Build

    docker run -it --rm -v /source-dir:/workspace \
    virtualhold/veracode-tools:latest java -cp /veracode/vht-veracode.jar BeginPreScan \
    -vid "..." \
    -vkey "..." \
    -app "Application Name" \
    -sandbox "Sandbox Name"

To automatically start a Scan after the PreScan completes, include the `-autoscan` flag.
