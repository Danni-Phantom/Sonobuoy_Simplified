#!/bin/bash

# Functions:
  # install_sono
  # install_jq
  # run_sono
  # get_results
  # pretty_results
  # status
  # delete
  # more_info
  # helpMsg
  # usage
  # ss_menu
  # ss_menu_run
  # run_ss

# Dependencies:
  # jq
  # wget

install_sono() {
  printf "SS - Sonobuoy Installation \n"

  # Default values for sonobuoy installation
  VERSION="0.17.1"
  OS="linux"

  printf "VERSION [Default: %s]: " "$VERSION"
  read -r rVERSION
  if [[ $rVERSION != '' ]];
  then
    VERSION=rVERSION;
  fi

  printf "OS [Default: %s ]: " "$OS"
  read -r rOS
  if [[ $rOS != '' ]];
  then
    OS=rOS;
  fi
  printf "\n"

  printf "Downloading Sonobuoy from Offical Github Repository \n"
  wget "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${VERSION}/sonobuoy_${VERSION}_${OS}_amd64.tar.gz"
  sono_install_zip="sonobuoy_"
  sono_install_zip+=$VERSION
  sono_install_zip+="_"
  sono_install_zip+=$OS
  sono_install_zip+="_amd64.tar.gz"
  printf "Decompressing sonobuoy files and installing \n"
  tar -xf "$sono_install_zip"
  chmod +x sonobuoy
  sudo mv "sonobuoy" /usr/bin/
  rm $sono_install_zip "LICENSE"
  printf "Sonobuoy has been installed! \n"

}

install_jq() {
    printf "SS - Downloading jq from stedolan.github.io/jq/ \n"
    printf "This will install jq version 1.6 - if a newer version exists, \n"
    printf "Please modify the script to fit your needs \n"
    wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" -O "jq"
    chmod +x "jq"
    sudo mv "jq" /usr/bin/
    printf "jQuery has been installed! \n"
}

run_sono() {
  printf "SS - Sonobuoy Options to Run \n"
  printf "Which Sonobuoy Test would you like to run? \n"
  printf "1. Non-Disruptive-Conformance \n"
  printf "2. Quick \n"
  printf "3. CertifiedConformance \n"
  printf "4. Information about each test"
  printf "5. Go To Main Menu \n"
  printf "Press 0 to exit Sonobuoy Simplified \n"


  read -r -n 1 ans
  printf "\n"

  if [[ "$ans" == '' ]]; then
    ans=2
  fi
  printf "\n"

  case "$ans" in
    1 )
      printf "SS - Running Non-Disruptive-Conformance Test! \n"
      sonobuoy run --wait  &
    ;;
    2 )
      printf "SS - Running Quick Test! \n"
      sonobuoy run --wait --mode quick &
    ;;
    3 )
      printf "SS - Running Certified-Conformance Test! \n"
      sonobuoy run --wait --mode certified-conformance &
    ;;
    4 )
      printf "Non-Disruptive-Conformance \n"
      printf "This is the default mode and will run all the tests in the e2e plugin which are marked Conformance which are known to not be disruptive to other workloads in your cluster. This mode is ideal for checking that an existing cluster continues to behave is conformant manner. \n"

      printf "Quick \n"
      printf "This mode will run a single test from the e2e test suite which is known to be simple and fast. Use this mode as a quick check that the cluster is responding and reachable. \n"

      printf "Certified-Conformance \n"
      printf "This mode runs all of the Conformance tests and is the mode used when applying for the Certified Kubernetes Conformance Program. Some of these tests may be disruptive to other workloads so it is not recommended that you run this mode on production clusters. In those situations, use the default \"non-disruptive-conformance\" mode. \n"

    ;;
    5 )
      ss_menu_run
    ;;
    0 | q )
      printf "Exiting... \n"
      exit
    ;;
    * )
      printf "Invalid input %s \n" "$ans"
      run_sono
    ;;
  esac
  printf "\n"

}

get_results() {
  printf "SS - Retrieving Sonobuoy Results \n"
  printf "Name of new directory:"
  read -r dir_s
  printf "\n"
  if [[ "$dir_s" == '' ]]; then
   dir_s="sonobuoy_results_$(date +%F)_$(date +%H)_$(date +%M)"
  fi
  output=$(sonobuoy retrieve)
  mkdir ./"$dir_s"
  tar xzf "$output" -C ./"$dir_s"
}

pretty_results() {
  printf "SS - Generating Sonobuoy Report \n"
  results=$(sonobuoy retrieve)
  printf "Save results to file? (y/n) "
  read -r -n 1 YoN
  printf "\n"
  if [[ $YoN == 'Y'  || $YoN == 'y' ]]; then {
    printf "File Name: "
    read -r fileName
    printf "\n"
    if [[ "$fileName" == '' ]]; then
        fileName="sonobuoy_report_$(date +%F)_$(date +%H)_$(date +%M)"
    fi
    sonobuoy results "$results" >> "$fileName".txt
    sonobuoy results "$results"
  }
  else
    sonobuoy results "$results"
  fi

}

status() {
  printf "SS - Status of Sonobuoy Testing \n"
  #jfile="jq_$(date +%F)_$(date +%H)_$(date +%M)".json
  printf "Sonobuoy is: "
  sonobuoy status --json | jq -r '.status'
  printf "\n"
  printf "1. More info, 2. Refresh, 3. Main Menu, 4.Exit \n"
  read -r -n 1 YoNs
  case "$YoNs" in
    1 )
      sonobuoy status --json | jq .
    ;;
    2 )
      status
    ;;
    3 )
      ss_menu_run
    ;;
    4 | 0 | q)
      exit
    ;;
    * )
      printf "Invalid input %s \n" "$ans"
      status
    ;;
  esac
}

delete() {
  printf "SS - Deleting Sonobuoy namespace \n"
  sonobuoy delete
  printf "\n Deletion Complete! \n"
}

more_info() {
  printf "SS - Information on Sonobuoy \n"
  sonobuoy -h
}

helpMsg() {
  printf "Sonobuoy Simplified \n"
  printf "The purpose of this script is to be able to run the kubernetes conformance tool sonobuoy without having to become familiar with the intracacies of the options and tools that it provides. It can be run via commandline or via an option menu \n"
  printf "More information on Sonobuoy can be found at https://sonobuoy.io/ \n\n"
  usage
  printf "Options: \n"
  printf "\t -r \t --run \t\t displays options and runs sonobuoy tool \n"
  printf "\t -i \t --install \t install the sonobuoy tool \n"
  printf "\t -j \t --install-jquery \t installs jQuery for additinal functionality in getting status of sonobuoy run \n"
  printf "\t -g \t --get-results \t this gets the full dump results generated by sonobuoy after the tool is run \n"
  printf "\t -p \t --pretty \t this gets the condensed results generated by the sonobuoy tool \n"
  printf "\t -s \t --status \t this displays the current status of the sonobuoy test being run. A full run can take several hours* \n"
  printf "\t -d \t --delete \t this deletes the current sonobuoy namespace so that a new test can be run. Try running this option if you encounter namespace errors \n"
  printf "\t -m \t --more-info \t this prints the help page for the main sonobuoy executable \n"
  printf "\t -h \t --help \t help \t displays this help message \n"
  printf "\n *jq package needs to be installed for some functionalities* \n"
}

usage() {
    printf "Usage: %s { -r | -i | -j | -g | -p | -s | -d | -m | -h } \n" "$0"
}

ss_menu() {
  printf "SS - Sonobuoy Simplified \n"
  printf "1. Run Sonobuoy \n"
  printf "2. Install Sonobuoy \n"
  printf "3. Install jQuery for Additional Functionality \n"
  printf "4. Get Sonobuoy Full Results \n"
  printf "5. Get Sonobuoy Report \n"
  printf "6. Get Stutus of Running Sonobuoy Test \n"
  printf "7. Delete existing Sonobuoy namespace \n"
  printf "8. Get More Information on Sonobuoy \n"
  printf "9. Sonobuoy Simplified Help \n"
  printf "press 0 to exit Sonobuoy Simplified \n"
}

ss_menu_run() {
  cont=true
  while $cont; do {
    ss_menu
    read -r -n 1 choice
    printf "\n"
  if [ "$choice" -eq 1 ]; then {
      run_sono
    }
  elif [ "$choice" -eq 2 ]; then {
      install_sono
    }
  elif [ "$choice" -eq 3 ]; then {
      install_jq
    }
  elif [ "$choice" -eq 4 ]; then {
      get_results
    }
  elif [ "$choice" -eq 5 ]; then {
      pretty_results
    }
  elif [ "$choice" -eq 6 ]; then {
      status
    }
  elif [ "$choice" -eq 7 ]; then {
      delete
    }
  elif [ "$choice" -eq 8 ]; then {
      more_info
    }
  elif [ "$choice" -eq 9 ]; then {
      helpMsg
    }
  elif [ "$choice" -eq 0 ]; then {
      cont=false
    }
    else
      printf "Invalid choice \n"
    fi
    printf "\n"
  } done
exit
}

run_ss() {
  printf "Welcome to the Sonobuoy Simplified Tool \n"

  while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
    -h | --help )
      helpMsg
      exit
    ;;
    -r | --run )
      shift; run_sono
    ;;
    -i | --install )
      shift; install_sono
    ;;
    -g | --get-results )
      shift; get_results
    ;;
    -p | --pretty )
      shift; pretty_results
    ;;
    -s | --status )
      shift; status
    ;;
    -d | --delete )
      shift; delete
    ;;
    -m | --more-info )
      shift; more_info
    ;;
    -j | --install-jquery )
      shift; install_jq
    ;;
    * )
      usage
    ;;
  esac; shift; done
  if [[ "$1" == '--' ]]; then shift; fi
  printf "\n"
  wait

  exit
}

# "Main"
if [[ $1 == '' ]];
then
  ss_menu_run
else
  run_ss "$@"
fi
