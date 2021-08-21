# The description is in the name :) 
function download_app_based_on_search_term --description 'Download application package based on search term'
  # Fail if no arguments provided
  if not count `$argv > /dev/null
    echo "No arguments provided -- example download_binaries -d <device> -s 'MovieApp'"
    return 1
  end

  argparse --name=download_binaries -i -s 'd/device=!validate_device' 's/search=' -- $argv
  or return

  # Exit if Search Term not provided
  if test -z $_flag_search
    echo "Must provide search flag"
    return 1
  end

  # Find Package name based on flag search
  if count $_flag_device > /dev/null
    set packages_found (eval "adb -s $_flag_device shell pm list packages | grep $_flag_search")
  else 
    if found_more_than_one_device
      echo "More than one device connected.  Please set a device using the -d option."
      return 1
    end
    set packages_found (eval "adb shell pm list packages | grep $_flag_search")
  end

  # Exit if Package name not discovered
  if test -z "$packages_found"
    echo "Package name not found"
    return 1
  end

  # Split all packages found and loop through to get list of all
  set i 0
  for package in (string split --no-empty "package:" $packages_found)
    echo "[$i] $package"
    set i (math $i + 1)
  end

  echo "-=-=-=-=-=-=-=-=-=-=-=-=-"
  echo -e "[#] to download a specific package.\n[a] or [all] to download all packages listed.\n[c] or leave blank to exit."
  set user_choice (read)
  
  switch "$user_choice"
  case "a" "all"
    echo "All packages chosen!"
    for package in (string split --no-empty "package:" $packages_found)
      download_binaries "$package" "$_flag_device"
    end

  case "" "c"
    echo "Cancelling"
    return 1

  case '*'
    set i 0
    
    for package in (string split --no-empty "package:" $packages_found)
      if test $i = $user_choice
        set package_selected $package
        echo "Package Selected: $package_selected"
        download_binaries "$package" "$_flag_device"
      end
      set i (math $i + 1)
    end

    if test -z $package_selected
      echo "Wrong selection. Try again."
      return 1
    end
  end
end


# Function that performs the following:
#   - Check that a folder does not exist with that package name in local environment
#     - Creates the folder if it doesn't exist
#     - Asks user if they want to override the contents of the folder if it does exist
#   - Gets location of binaries on device
#   - Downloads all binaries located on device into package folder
#     - For multiple, will loop through until all packages are downloaded
function download_binaries --argument-names package device --description 'Find and Download app based on package'
  if not test -z $device
    set device " -s $device"
  end

  set path_command " shell pm path $package"
  set binary_path (eval "adb$device$path_command")
  check_directory $package
  
  set x 0
  for binary in (string split --no-empty "package:" $binary_path)
    echo -e "[$x] Downloading binary located at path: $binary"
    eval "adb$device pull $binary"
    set x (math $x + 1)
  end
  # Exit the directory we're in :)
  cd ..
end


# Check that package directory exists on local file system before we download binaries from device to it
function check_directory --argument-names package --description 'Check if directory for package name exists'
  if test -d $package
    echo -e "This directory exists.  Can we overwrite contents? \n [y]Yes, [n] No"
    set overwrite_directory (read)

    switch $overwrite_directory
  
    case 'y' 'Y' 'Yes' 'yes'
      rm -rf $package
      and mkdir "$package"
      and cd "$package"
      and echo "Downloading the following files to $package Directory"

    case 'n' 'N' 'No' 'no'
      set new_append "_new"
      mkdir "$package$new_append"
      and cd "$package$new"
      and echo "Downloading the following files to $package$new Directory"

    case "*"
      echo "Invalid input"
      return 1
    end

  # Directory doesn't exist. Let's create it :) 
  else 
    mkdir "$package"
    and cd "$package"
    and echo "Downloading the following files to $package Directory"
  end
end

# If a device is provided, this will check to make sure it exists
function validate_device --description 'Validate device provided actually exists' --no-scope-shadowing
  echo "Looking for device $_flag_value"

  set devices (eval "adb devices")

  if string match -e $_flag_value $devices 
    echo -e "Device Found!\n"
    return 0
  else
    echo -e "Device Not Found!"
    return 1
  end
end

# Will return whether or not more than one device was discovered
function found_more_than_one_device --description "Runs a quick adb command to see if we discovered more than one device"
  set devices_found (adb shell pm list packages)
  if string match -q "adb: more than one device/emulator" $devices_found
    return 0
  end

  return 1
end
