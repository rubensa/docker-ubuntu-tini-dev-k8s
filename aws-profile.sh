#!/usr/bin/env bash
# Based on : https://gist.github.com/benkehoe/0d2985e56059437e489314d021be3fbe#file-aws-profile-for-bashrc-sh

persist_aws_profile () {
  aws_current_profile_file=$(echo "${AWS_CURRENT_PROFILE_FILE:-~/.aws/current-profile}" | sed "s:~:$HOME:" );
  if [ -z $AWS_PROFILE ]; then
    if [ -f "$aws_current_profile_file" ]; then
      rm "$aws_current_profile_file"
    fi
  else
    if [ ! -f "$aws_current_profile_file" ]; then
      mkdir -p "$(dirname "$aws_current_profile_file")"
    fi
    echo $AWS_PROFILE > "$aws_current_profile_file"
  fi
}

restore_aws_profile () {
  aws_current_profile_file=$(echo "${AWS_CURRENT_PROFILE_FILE:-~/.aws/current-profile}" | sed "s:~:$HOME:" );

  if [ -f "$aws_current_profile_file" ]; then
    current_profile=$( < "$aws_current_profile_file" )
    AWS_DEFAULT_PROFILE=
    export AWS_PROFILE=$current_profile
    export -n AWS_DEFAULT_PROFILE
  fi
}

aws-profile () {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "USAGE:"
    echo "aws-profile              <- print out current value"
    echo "aws-profile PROFILE_NAME <- set PROFILE_NAME active"
    echo "aws-profile --unset      <- unset the env vars"
  elif [ -z "$1" ]; then
    restore_aws_profile
    if [ -z "$AWS_PROFILE$AWS_DEFAULT_PROFILE" ]; then
      echo "No profile is set"
      return 1
    else
      echo "$AWS_PROFILE$AWS_DEFAULT_PROFILE"
    fi
  elif [ "$1" = "--unset" ]; then
    AWS_PROFILE=
    AWS_DEFAULT_PROFILE=
    # removing the vars is needed because of https://github.com/aws/aws-cli/issues/5016
    export -n AWS_PROFILE AWS_DEFAULT_PROFILE
    persist_aws_profile
  else
    # this check needed because of https://github.com/aws/aws-cli/issues/5546
    # requires AWS CLI v2
    if ! aws configure list-profiles | grep --color=never -Fxq -- "$1"; then
      echo "$1 is not a valid profile"
      return 2
    else
      AWS_DEFAULT_PROFILE=
      export AWS_PROFILE=$1
      export -n AWS_DEFAULT_PROFILE
      persist_aws_profile
    fi;
  fi;
}

# completion is kinda slow, operating on the files directly would be faster but more work
# aws configure list-profiles is only available with the AWS CLI v2.
_aws-profile-completer () {
  COMPREPLY=(`aws configure list-profiles | grep --color=never ^${COMP_WORDS[COMP_CWORD]}`)
}
complete -F _aws-profile-completer aws-profile

restore_aws_profile

# Based on: https://luktom.net/en/e1466-work-comfortable-with-aws-cli-profiles-in-bash
aws_profile_prompt () {
  if [[ -n $AWS_PROFILE ]]; then
    echo -n "[$AWS_PROFILE] "
  else
    echo -n ""
  fi
}

PS1="\$(aws_profile_prompt)$PS1"