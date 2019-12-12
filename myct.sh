#!/bin/bash

#give first argument a name and remove it from arg list
cmd=$1
shift

function init() {
  # clean args
  path=$1
  arch=${2:-amd64}
  release=${3:-bionic}
  # I would have used debian stable, but the packages are broken atm (missing libs)
  #repository=${4-'http://deb.debian.org/debian/'}
  # so use ubuntu
  repository=${4-'http://ftp.stw-bonn.de/ubuntu/'}

  # enforce first parameter
  if [[ -z $path ]]; then
    echo 'No path provided'
    exit 3
  fi

  # check if debootstrap is available
  if [[ -z $(command -v debootstrap) ]]; then
    echo 'Please install debootstrap'
    exit 2
  fi

  # create the path for chroot
  mkdir -p "$path"

  # run debootstrap to provide file system
  debootstrap --variant=buildd --arch "$arch" "$release" "$path" "$repository"

  # create required mountpoints
  mount proc "$path"/proc -t proc
  mount sysfs "$path"/sys -t sysfs
  # prepare special device files
  mknod "$path"/dev/null c 1 3
  mknod "$path"/dev/random c 1 8
  mknod "$path"/dev/tty c 5 0
  mknod "$path"/dev/urandom c 1 9
  mknod "$path"/dev/zero c 1 5
  chmod 666 "$path"/dev/{null,random,tty,urandom,zero}
  # copy some important files
  cp /etc/hosts "$path"/etc/hosts
  cp /proc/mounts "$path"/etc/mtab
  cp -L /etc/resolv.conf "$path"/etc/resolv.conf
}

function map() {

  if [ "$#" -ne 3 ]; then
    echo 'Please specify <container-path> <host-path> <target-path>'
    exit 4
  fi

  path=$1
  host=$2
  target=$3
  mount -o bind,ro "$host" "$path"/"$target"
  # just to be sure (e.g. old kernels)
  mount -o bind,remount,ro "$path"/"$target"
}

function run() {

  # defaults
  namepace=
  cgroup_cmd=

  # check if cgcreate is available
  if [[ -z $(command -v cgcreate) ]]; then
    echo 'Please install cgcreate e.g. from libcgroup or cgroup-tools'
    exit 5
  fi
  # check if cgset is available
  if [[ -z $(command -v cgset) ]]; then
    echo 'Please install cgset e.g. from libcgroup or cgroup-tools'
    exit 6
  fi

  #extract path
  path=$1
  shift
  # enforce first parameter
  if [[ -z $path ]]; then
    echo 'No path provided'
    exit 3
  fi

  # parse arguments
  limits=()
  while [[ -n "$*" ]]; do
    case $1 in
      '--limit')
        limits+=("$2")
        shift 2
        ;;
      '--namespace')
        namespace="$2"
        shift 2
        ;;
      *)
        cmd="$*"
        break
        ;;
    esac
  done

  # cgroups do not work on my system
  if [[ -n "$namespace" ]]; then
    # create a new namespace with
    echo cgcreate -g cpu,memory:"$namepace"
    # then include below before the chroot cgexec -g cpu,memory:"$namespace"
    # mind the extra space at the end
    #cgroup_cmd="cgexec -g cpu,memory:$namespace "

    # setup new limits
    for i in "${limits[@]}"; do
      echo cgset -r $i $namespace
      # cgset -r $i $namespace
    done
  fi

  # further options --cgroup --user --map-root-user --net, but they do not work on my system
  # unshare does not like extra spaces in the cmd part, so be careful
  unshare --fork --pid --mount-proc --mount --ipc --uts --propagation slave "$cgroup_cmd"chroot "$path" $cmd &
}

function main() {
  case $cmd in
    init)
      init "$@"
      ;;
    map)
      map "$@"
      ;;
    run)
      run "$@"
      ;;
    *)
      echo 'unknow command' "$cmd"
      exit 1
      ;;
  esac
}

# Check if we are running as root
if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

# execute the main loop
main "$@"
