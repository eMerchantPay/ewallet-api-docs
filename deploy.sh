#!/usr/bin/env bash
set -o errexit #abort if any command fails
me=$(basename "$0")

help_message="\
Usage: $me -v VERSION -e ENV [<options>]
Deploy generated files to a git branch.

Options:

  -h, --help               Show this help information.
  -v, --version MESSAGE    Specify the deployment version.
  -e, --env ENV            Environment where to deploy - 'prod' or 'staging'.
  -r, --ghe-release        Create a release in origin master.
  -b, --build-only         Only build the project, but don't deploy.
  -d, --deploy-only        Only deploy the project, but don't build.
  -vv, --verbose           Increase verbosity. Useful for debugging.
"

build() {
  echo "Building eZeeWallet API docs ..."

  if should_release; then
    create_ghe_release
  fi

  if [[ "$env" = 'prod' && "$build_only" = false ]] && ! (git checkout "release-${version}") then
    if ! (git fetch origin "refs/tags/${version}:refs/tags/release-${version}") && ! (git checkout "release-${version}") then
      echo "Can't find release tag release-${version}. You can deploy only release tags. Expected workflow is to user -r to create a release"
      return 1
    fi
  fi

  bundle exec middleman build --clean
}

should_release() {
  [[ "$env" = 'prod' && "$ghe_release" = true && "$build_only" = false ]]
}

parse_args() {
  build_only=false
  deploy_only=false
  ghe_release=false

  # Set args from a local environment file.
  if [ -e ".env" ]; then
    source .env
  fi

  # Parse arg flags
  # If something is exposed as an environment variable, set/overwrite it
  # here. Otherwise, set/overwrite the internal variable instead.
  while : ; do
    if [[ $1 = "-h" || $1 = "--help" ]]; then
      echo "$help_message"
      return 0
    elif [[ $1 = "-vv" || $1 = "--verbose" ]]; then
      verbose=true
      shift
    elif [[ $1 = "-b" || $1 = "--build-only" ]]; then
      build_only=true
      shift
    elif [[ $1 = "-d" || $1 = "--deploy-only" ]]; then
      deploy_only=true
      shift
    elif [[ $1 = "-r" || $1 = "--ghe-release" ]]; then
      ghe_release=true
      shift
    elif [[ ( $1 = "-e" || $1 = "--env" ) && -n $2 ]]; then
      env=$2
      shift 2
    elif [[ ( $1 = "-v" || $1 = "--version" ) && -n $2 ]]; then
      version=$2
      shift 2
    else
      break
    fi
  done

  if [[ -z $version && "$build_only" = false ]]; then
    echo "Version is required. Specify version using -v or --version." >&2
    return 1
  fi

  if [[ "$env" != 'staging' && "$env" != 'prod' && "$build_only" = false ]]; then
    echo "Environment is required. Allowed values for --env parameter are 'prod' or 'staging'" >&2
    return 1
  fi

  if [[ "$env" = 'prod' && "$deploy_only" = true ]]; then
    echo "Deploy only flag is not allowed for prod environment" >&2
    return 1
  fi
}

deploy() {
  echo "Deploying to $env..."

  check_repo_state
  deploy_to_env

  if [[ "$env" = 'prod' ]]; then
    git push $repo_prod master:master
    git push $repo_prod gh-pages-${version}:${version}
  fi
}

prepare_remotes() {
  if ! (git remote -v | grep -q "$repo_prod") then
    git remote add github.com git@github.com:eMerchantPay/ewallet-api-docs.git

    git fetch github.com master:master || true
  fi
  if ! (git remote -v | grep -q "$repo_staging") then
    git remote add ghe git@emp-sof-github01.emp.internal.com:eMerchantPay/github_pages_ewallet_slate_api_docs.git

    git fetch ghe gh-pages:gh-pages || true
  fi
}

prepare_repo() {
  repo_prod=github.com
  repo_staging=ghe
  previous_branch=`git rev-parse --abbrev-ref HEAD`
  deploy_directory=build
  commit_hash=` git log -n 1 --format="%H" HEAD`

  case "$env" in
    'prod')
      repo="$repo_staging"
      deploy_branch=master
      deploy_branch_local=master
    ;;
    'staging')
      repo="$repo_staging"
      deploy_branch=gh-pages
      deploy_branch_local=gh-pages
    ;;
    *)
      echo 'Invalid environment' >&2
      return 1
  esac

  prepare_remotes
}

check_repo_state() {
  if ! git diff --exit-code --quiet --cached; then
    echo Aborting due to uncommitted changes in the index >&2
    return 1
  fi

  if [ ! -d "$deploy_directory" ]; then
    echo "Deploy directory '$deploy_directory' does not exist. Aborting." >&2
    return 1
  fi

  # must use short form of flag in ls for compatibility with OS X and BSD
  if [[ -z `ls -A "$deploy_directory" 2> /dev/null` ]]; then
    echo "Deploy directory '$deploy_directory' is empty. Aborting." >&2
    return 1
  fi
}

deploy_to_env() {
  if git show-ref --verify --quiet "refs/heads/$deploy_branch_local"
  then incremental_deploy
  else initial_deploy
  fi
}

create_ghe_release() {
  echo "Releasing to GHE master"

  git fetch origin develop:develop
  git fetch origin master:master

  git checkout develop
  git pull origin develop

  git checkout master
  git pull origin master
  git merge --squash develop
  git commit -am "$version"
  git tag release-${version} -m "$version"

  git push origin master
  git push origin release-${version}:$version

  git checkout develop
  git merge master
  git push origin develop
}

initial_deploy() {
  git --work-tree "$deploy_directory" checkout --orphan $deploy_branch_local
  git --work-tree "$deploy_directory" add --all
  commit+push
}

incremental_deploy() {
  #make deploy_branch_local the current branch
  git symbolic-ref HEAD refs/heads/$deploy_branch_local
  #put the previously committed contents of deploy_branch_local into the index
  git --work-tree "$deploy_directory" reset --mixed --quiet
  git --work-tree "$deploy_directory" add --all

  set +o errexit
  diff=$(git --work-tree "$deploy_directory" diff --exit-code --quiet HEAD --)$?
  set -o errexit
  case $diff in
    0) echo No changes to files in $deploy_directory. Skipping commit.;;
    1) commit+push;;
    *)
      echo git diff exited with code $diff. Aborting. Staying on branch $deploy_branch_local so you can debug. To switch back to master, use: git symbolic-ref HEAD refs/heads/master && git reset --mixed >&2
      return $diff
      ;;
  esac
}

commit+push() {
  if [[ "$env" = 'prod' ]]; then
    git --work-tree "$deploy_directory" commit -m "$version"
    git tag gh-pages-${version} -m "$version"
  else
    git --work-tree "$deploy_directory" commit -m "$previous_branch" -m "$version"
  fi


  disable_expanded_output
  #--quiet is important here to avoid outputting the repo URL, which may contain a secret token
  git push --quiet $repo $deploy_branch_local:$deploy_branch -f

  if [[ "$env" = 'prod' ]]; then
    git push --quiet $repo gh-pages-${version}:${version}
  fi
  enable_expanded_output
}

#echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
  if [ $verbose ]; then
    set -o xtrace
    set +o verbose
  fi
}

#this is used to avoid outputting the repo URL, which may contain a secret token
disable_expanded_output() {
  if [ $verbose ]; then
    set +o xtrace
    set -o verbose
  fi
}

parse_args "$@"
prepare_repo
enable_expanded_output

if (! $deploy_only) then
  build
fi
if (! $build_only) then
  deploy
fi
