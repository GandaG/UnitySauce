#! /bin/sh

if [ "$packagename" == "" ]; then
    project="${TRAVIS_REPO_SLUG##*/}"
else
    project="$packagename"
fi
if [ "$include_version" == "True" ]; then
    package="$project"_"$TRAVIS_TAG".unitypackage
else
    package=$project.unitypackage
fi

if [ "$project" == "unitypackage-ci" ]; then
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Preparing directories; -------------------------------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  mkdir ./Temp
  mkdir ./Deploy
  
  #grab everything inside CI/ except the files created during the build. Also grab the readme and license.
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Moving relevant files to Temp/ directory; ------------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  mv ./CI ./Temp/CI
  rm ./Temp/CI/*.pkg
  if [ "$verbose" == "True" ];
  then
    rm ./Temp/CI/*.log
  fi
  mv README.rst ./Temp/README.rst
  mv LICENSE ./Temp/LICENSE
  mv config.ini ./Temp/config.ini
  
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Writing new yml file; --------------------------------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo 'language: objective-c

install:
  - sh ./CI/py_set_up.sh

script:
  - python ./CI/main_parser.py

env:
    global:
      - secure: Github_encrypted_token_here' >./Temp/.travis.yml
  if [ "$verbose" == "True" ];
  then
    cat ./Temp/.travis.yml
  fi

  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Writing new config file; --------------------------------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo $'[Misc]
#if set to true, all logs from commands will be shown. Default is false.
verbose=false

#if set to true, Travis will always try to build the package/asset, even when there isn\'t a tag. Default is true. 
always_run=true

#if set to true, tag will be included after the package name (e.g. unitypackage-ci_v0.1.1). Default is true.
include_version=true

#if you want to name the deploy zip file something other than your repo name:
packagename=

[Github]
#if set to true, tags with "alpha" or "beta" in their name will be set to prerelease. Default is true.
conditional_prerelease=true

#if set to true, tags with "alpha" or "beta" in their name will be deployed as draft. Default is true.
conditional_draft=true

#if set to true, releases will always be set to prerelease. 
#Overrides conditional_prerelease if true. Default is false.
prerelease=false

#if set to true, releases will always be deployed as a draft. 
#Overrides conditional_draft if true. Default is false.
draft=false

#if you want to add something (don\'t forget this should be in github markdown) 
#to the release description, uncomment and fill in: 
description=

#if you want to deploy only from a specific branch:
branch=

[AssetStore]
#not supported YET

[Docs]
#not suppported YET' >./Temp/config.ini
  if [ "$verbose" == "True" ];
  then
    cat ./Temp/config.ini
  fi
  
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Compressing relevant files to Deploy/ directory; -----------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  cd Temp/ || exit 1
  zip -r -X "$project".zip .
  cd ..
  mv ./Temp/"$project".zip ./Deploy/"$project".zip
  
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Checking compression was successful; -----------------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  
  file=./Deploy/$project.zip
  
  if [ -e "$file" ];
  then
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	echo "Package compressed successfully: $file"
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	exit 0
  else
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	echo "Package not compressed. Aborting.---------------------------------------------------------------------------------------"
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	exit 1
  fi
else
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Compressing package to Deploy/ directory; ----------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  mkdir ./Deploy
  
  zip -r -X ./Deploy/"$project".zip ./Project/"$package" \;
   
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  echo "Checking compression was successful; -----------------------------------------------------------------------------------"
  printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
  
  file=./Deploy/$project.zip
   
  if [ -e "$file" ];
  then
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	echo "Package compressed successfully: $file"
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	exit 0
  else
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	echo "Package not compressed. Aborting. --------------------------------------------------------------------------------------"
    printf '%s\n' ------------------------------------------------------------------------------------------------------------------------
	exit 1
  fi
fi
