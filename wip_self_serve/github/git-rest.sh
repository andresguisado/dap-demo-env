#!/bin/bash
export APIVERSION="application/vnd.github.v3+json"
export usageMsg="Usage: $0 [ submit | approve | merge ] <project-name> <filename>"
export _owner=jodybot
export _repo=policy-ops

export loginname=jodybot
export botToken=$(cat git-token-jodybot)
export prReviewerName="jodyhuntatx"
export prReviewerToken=$(cat git-token-jodyhuntatx)

main() {
  if [[ $# < 3 ]]; then echo $usageMsg; exit -1; fi
  gitCmd=$1
  case $gitCmd in
    submit | approve | merge)
	;;
    *)
	echo ${usageMsg}
	exit -1
  esac

  baseBranch=master
  mergeBranch=$2
  commitPath="$(date +%Y)/$(date +%m)/$(date +%d)/${mergeBranch}"
  commitFile=$3
  export LOGFILE=./${mergeBranch}.log
  touch $LOGFILE

  case $gitCmd in
    submit)
  	createBranch 	  ${_owner} ${_repo} ${baseBranch} ${mergeBranch}
	commitFile 	  ${_owner} ${_repo}               ${mergeBranch} ${commitPath} ${commitFile}
	createPullRequest ${_owner} ${_repo}               ${mergeBranch} ${commitPath} ${commitFile} 
	;;

    approve)
	createPRReview    ${_owner} ${_repo}               ${mergeBranch} ${commitPath} ${commitFile} 
	;;

    merge)
	mergePullRequest  ${_owner} ${_repo} ${baseBranch} ${mergeBranch} ${commitPath} ${commitFile} 
	;;

    *)
	echo ${usageMsg}
	exit -1
  esac

#  getCommitMessages ${_owner} ${_repo}               ${mergeBranch} ${commitPath} ${commitFile} 
#  getCommitMessages ${_owner} ${_repo} ${baseBranch}                ${commitPath} ${commitFile} 
}

#####################
createBranch() {
  local ownerName=$1; shift
  local repoName=$1; shift
  local baseBranch=$1; shift
  local mergeBranch=$1; shift

  echo "createBranch($baseBranch,$mergeBranch)"

  # get hash of head of base branch
  branch_sha=$(curl -s -X GET \
	-H "Accept: $APIVERSION" \
	https://api.github.com/repos/${ownerName}/${repoName}/git/refs/heads/${baseBranch} | jq -r .object.sha)

  if [[ "$branch_sha" == "" ]]; then
    echo "Base branch $baseBranch not found."
    exit -1
  fi

  # create new branch from head of base branch
  createBranchMsg=$(curl -s -X POST \
	-H "Accept: $APIVERSION" \
	-H "Authorization: token ${botToken}" \
	-d "{ \
		\"ref\": \"refs/heads/${mergeBranch}\", \
		\"sha\": \"${branch_sha}\" \
	    }" \
	https://api.github.com/repos/${ownerName}/${repoName}/git/refs
  )
  echo >> $LOGFILE
  echo "createBranch($baseBranch,$mergeBranch) =============" >> $LOGFILE
  echo $createBranchMsg | jq . >> $LOGFILE
}

#####################
commitFile() {
  local ownerName=$1; shift
  local repoName=$1; shift
  local branchName=$1; shift
  local filePath=$1; shift
  local fileName=$1; shift

  fqFilePath=${filePath}/${fileName}

  echo "commitFile($branchName,$fqFilePath)"

  # get sha of file in branch - if it exists
  file_sha=$(curl -s \
	-H "Accept: $APIVERSION" \
	https://api.github.com/repos/${ownerName}/${repoName}/contents/${fqFilePath}?ref=${branchName} \
	| jq -r .sha)

  commit_message="$branchName, $fileName, $(date +%Y-%m-%d/%H:%M:%S)"

  if [[ "${file_sha}" == "" ]]; then
    # create new file
    commitFileMsg=$(curl -s -X PUT \
	-H "Accept: $APIVERSION" \
	-H "Authorization: token ${botToken}" \
	-d "{ \
		\"message\": \"${commit_message}\", \
		\"content\": \"$(cat ${fileName} | base64)\", \
		\"branch\": \"${branchName}\" \
	    }" \
	https://api.github.com/repos/${ownerName}/${repoName}/contents/${fqFilePath}
    )
  else
    # update existing file
    commitFileMsg=$(curl -s -X PUT \
	-H "Accept: ${APIVERSION}" \
	-H "Authorization: token ${botToken}" \
	-d "{ \
		\"message\": \"${commit_message}\", \
		\"content\": \"$(cat ${fileName} | base64)\", \
		\"sha\": \"${file_sha}\", \
		\"branch\": \"${branchName}\" \
	    }" \
	https://api.github.com/repos/${ownerName}/${repoName}/contents/${fqFilePath}
    )
  fi
  echo >> $LOGFILE
  echo "commitFile($branchName,$fqFilePath) =============" >> $LOGFILE
  echo $commitFileMsg | jq . >> $LOGFILE
}

#####################
getCommitMessages() {
  local ownerName=$1; shift
  local repoName=$1; shift
  local branchName=$1; shift
  local filePath=$1; shift
  local fileName=$1; shift

  curl -s -X GET \
	-H "Accept: $APIVERSION" \
	https://api.github.com/repos/${ownerName}/${repoName}/commits?sha=${branchName} \
	| jq .[].commit.message | grep ${branchName}
}

#####################
createPullRequest() {
  local ownerName=$1; shift
  local repoName=$1; shift
  local branchName=$1; shift
  local filePath=$1; shift
  local fileName=$1; shift

  echo "createPullRequest($branchName,$fileName)"

  pullRequestMsg=$(curl -s -X POST \
	-H "Accept: ${APIVERSION}" \
	-H "Authorization: token ${botToken}" \
	-d "{ \
		\"title\": \"${branchName} project onboarding.\", \
		\"body\": \"${fileName}\", \
		\"head\": \"${ownerName}:${branchName}\", \
		\"base\": \"master\" \
	    }" \
	https://api.github.com/repos/${ownerName}/${repoName}/pulls
    )
  echo >> $LOGFILE
  echo "createPullRequest($branchName,$fileName) =============" >> $LOGFILE
  echo $pullRequestMsg | jq . >> $LOGFILE
}

#####################
createPRReview() {
  local ownerName=$1; shift
  local repoName=$1; shift
  local branchName=$1; shift
  local filePath=$1; shift
  local fileName=$1; shift


  echo "createPullRequestReview(${branchName},${fileName})"

  pullNumber=$(curl -s -X GET 		   \
	-H "Accept: ${APIVERSION}" 	   \
	-H "Authorization: token ${prReviewerToken}" \
	https://api.github.com/repos/${ownerName}/${repoName}/pulls \
	| jq .[].number
  )
  pullRequestReviewMsg=$(curl -s -X POST   		\
	-H "Accept: ${APIVERSION}" 	   		\
	-H "Authorization: token ${prReviewerToken}" 	\
	-d "{ 				   		\
		\"body\": \"${prReviewerName}\",	\
		\"event\": \"APPROVE\"			\
	    }" 				   		\
	https://api.github.com/repos/${ownerName}/${repoName}/pulls/${pullNumber}/reviews
    )
  echo >> $LOGFILE
  echo "createPullRequestReview(${branchName},${fileName}) =============" >> $LOGFILE
  echo ${pullRequestReviewMsg} | jq . >> $LOGFILE
}

#####################
mergePullRequest() {
  local ownerName=$1; shift
  local repoName=$1; shift
  local baseBranch=$1; shift
  local mergeBranch=$1; shift
  local filePath=$1; shift
  local fileName=$1; shift

  echo "mergePullRequest(${baseBranch},${mergeBranch},${fileName})"

  echo >> $LOGFILE
  echo "mergePullRequest(${baseBranch},${mergeBranch},${fileName}) =============" >> $LOGFILE
  http_code=$(curl -s -X POST       		\
	-o /dev/null				\
	-w "%{http_code}\n"			\
 	-H "Accept: ${APIVERSION}"		\
	-H "Authorization: token ${botToken}"	\
	-d "{					\
	      \"base\": \"${baseBranch}\",	\
	      \"head\": \"${mergeBranch}\",	\
	      \"commit_message\": \"${baseBranch}, ${filePath}, ${fileName}\"   \
	    }"					\
	https://api.github.com/repos/${ownerName}/${repoName}/merges
  )

  case ${http_code} in
    201 | 204)
	echo "Merge successful."
	echo "Merge successful." >> $LOGFILE
	;;

    404)
	echo "Merge branch or base does not exist."
	echo "Merge branch or base does not exist." >> $LOGFILE
	;;

    409)
	echo "Merge conflict, please resolve."
	echo "Merge conflict, please resolve." >> $LOGFILE
	;;
  esac
}

#####################
authn() {
  local username=$1; shift
  local token=$1; shift

  # authenticate user
  curl -s -H "Accept: $APIVERSION" \
	-u $username:${token} \
	https://api.github.com/users/$username
}

main "$@"
