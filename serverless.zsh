alias sls="$SLS_PREFIX sls"
alias slsup="sls deploy"
alias slsrm="sls remove"
alias slsupf="sls deploy function -f"
function slsii {
    eval $SLS_PREFIX sls invoke --log --function $1
}
function slsll {
    if [[ "$1" == "" ]]; then
        echo "Specify a lambda function name"
        return
    fi
    SERVICE=$(cat .serverless/serverless-state.json| jq -r '.service.service')
    STAGE=$(cat .serverless/serverless-state.json| jq -r '.service.provider.stage')
    REGION=$(cat .serverless/serverless-state.json| jq -r '.service.provider.region')
    BEFORE="${2:-10m}"

    echo "$SLS_PREFIX cw --region $REGION tail /aws/lambda/$SERVICE-$STAGE-$1 -b$BEFORE | sed '/^[[:space:]]*$/d' | grep -v '^[ER]'"
    eval $SLS_PREFIX cw --region $REGION tail /aws/lambda/$SERVICE-$STAGE-$1 -b$BEFORE | sed '/^[[:space:]]*$/d' | grep -v '^[ER]'
}
_slsll() {
  local state
  _arguments '1: :->function_name'

  case $state in
    (function_name) _arguments '1:functions:($(cat .serverless/serverless-state.json| jq -r ".service.functions | to_entries[] | .key"))' ;;
  esac
}
compdef _slsll slsll
compdef _slsll slsii
compdef _slsll slsupf
