## Parse the ~/.aws/credentials file and export appropriate variables
## TODO: parse the profile name.  In this case default is used
CREDENTIALS_FILE=${HOME}/.aws/credentials
AWS_ACCESS_KEY_ID="aws_access_key_id"
AWS_SECRET_ACCESS_KEY="aws_secret_access_key"
AWS_SESSION_TOKEN="aws_session_token"
AWS_DEFAULT_PROFILE="default"




setEnvVariable() {
    key=$1
    text=$2
    local variableName=`printf '%s\n' $key | awk '{ print toupper($0) }'`
    local value=`echo "$text" | awk -F" = " '{print $2}'`
    echo "export $variableName=$value"
    export $variableName="$value"
    
}

parseAWSCreds() {
    echo "Reading file: $CREDENTIALS_FILE"
    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo $line | grep -q $AWS_ACCESS_KEY_ID && setEnvVariable "$AWS_ACCESS_KEY_ID" "$line" && continue
        echo $line | grep -q $AWS_SECRET_ACCESS_KEY &&  setEnvVariable "$AWS_SECRET_ACCESS_KEY" "$line" && continue
        echo $line | grep -q $AWS_SESSION_TOKEN &&  setEnvVariable "$AWS_SESSION_TOKEN" "$line" && continue

    done < "$CREDENTIALS_FILE"

    echo "export AWS_DEFAULT_PROFILE=$AWS_DEFAULT_PROFILE"
    export AWS_DEFAULT_PROFILE="$AWS_DEFAULT_PROFILE"
}

echo "ARGS: $0"
echo $0 | grep -q aws_creds.sh && echo "Please source this script (. ./aws_creds.sh)" && exit 1 
parseAWSCreds
