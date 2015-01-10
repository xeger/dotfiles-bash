function api() {	
	case $1 in
	login)
		rightscale_api_endpoint=$2
		local refresh_token=$3
		if [ -n "$rightscale_api_endpoint" -a -n "$refresh_token" ]
		then
			local response=`curl -fsSL -H "X-Api-Version:1.5" -X POST $rightscale_api_endpoint/api/oauth2 -d "grant_type=refresh_token" -d "refresh_token=$refresh_token"`
			if [ $? == 0 ]
			then
				local expires_in=`echo $response | jq -r ".expires_in"`
				rightscale_api_access_token=`echo $response | jq -r ".access_token"`
				echo "api: login succeeded; access token expires in $expires_in seconds"
			else
				# curl should have printed an error already
				return 2
			fi
		else
			echo "api: missing required parameter(s)"
			echo "example: 'api login https://us-3.rightscale.com deadbeefbadf00d'"
			return 1
		fi
		;;
	logout)
		if [ -n "$rightscale_api_access_token" ]
		then
			unset rightscale_api_access_token
			echo "api: logout succeeded"
			return 0
		else
			echo "api: not logged in; nothing to do"
			return 1
		fi
		;;
	get|delete)
		local path="$2"
		local url="${rightscale_api_endpoint}${path}"
		if [ -n "$path" ]
		then
			local cmd="curl -fsSL -H X-Api-Version:1.5 -H Authorization:Bearer+$rightscale_api_access_token -X GET $url"
			echo $cmd
			local response=`$cmd`
			if [ $? == 0 ]
			then
				echo $response | jq "."
			else
				# curl should have printed an error already
				return 2
			fi
		else
			echo "api: missing required parameter(s)"
			echo "example: 'api get /api/servers/1'"
		fi
		;;
	patch|post|put)
		local path="$2"
		local variables="${@:3}"
		local url="$rightscale_api_endpoint/$path"
		echo "api: HTTP method $1 is not supported yet; sorry"
		return 2
		;;
	*)
		echo "api: unrecognized command $1"
		return 1
	esac
}
