MXMLT_BINARY="/sdk/bin/mxmlc.exe"
FLEX_RESOURCES="flex-content/"
OUTPUT="mxmlc-output/"

ERROR_LOG="error.log"
SUCCESS_LOG="success.log"

if [ ! -f $MXMLT_BINARY ]; then
    echo "Error: $MXMLT_BINARY does not exist!"
    echo 
    echo "Make sure to download the SDK from adobe: http://download.macromedia.com/pub/flex/sdk/flex_sdk_4.6.zip"
    echo "You've already got it? Extract it within the folder of this script and edit the path on the first line."
    echo 
    exit
fi

function WriteError {
    echo `date +"[%m/%d/%Y %H:%M:%S] $1"` >> $ERROR_LOG
}

function WriteSuccess {
    echo `date +"[%m/%d/%Y %H:%M:%S] $1"` >> $SUCCESS_LOG
}

# iterate through every directory in $FLEX_RESOURCES
for DIRECTORY in $FLEX_RESOURCES* ; do
    srcFolder="$DIRECTORY/src/"

    if [ ! -d "$srcFolder" ]; then
        WriteError "$srcFolder does not exist!"
        continue
    else
        tmp="${DIRECTORY%.swf*}"
        basename=`basename "$tmp"`
        asFile="$srcFolder$basename.as"
        swfFile="$OUTPUT$basename.swf"
        if [ ! -f "$asFile" ]; then
            WriteError "$asFile does not exist in '$srcFolder'"
            continue
        else
            if [ -f "$swfFile" ]; then
                echo "Skipping '$swfFile'..."
                continue
            fi
            # everything seems to be okay - start converting
            $MXMLT_BINARY $asFile -output $swfFile -static-link-runtime-shared-libraries=true -compiler.strict &> /dev/null
            if [ ! -f "$swfFile" ]; then
                WriteError "Couldn't compile $asFile!"
                continue
            else
                echo "Compilation of $swfFile was successful!"
                WriteSuccess $swfFile
            fi
        fi
    fi
done

echo "We are done here! You can close me now."
