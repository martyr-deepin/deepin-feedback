# Usage

    deepin-feedback-cli.sh [-d <sliceinfo>] [-o <filename>] [-m <maxsize>] [-h] [<category>]
    Options:
        -d, --dump, print system slice information, the type coulde be:
            aptlog
            apttermlog
            basic
            bluetooth
            bootmgr
            device
            disk
            driver
            env
            kernel
            network
            package
            service
            syslog
            video
        -o, --output, customize the output file
        -m, --maxsize, set single archive file's maximize size
        -h, --help, show this message
    
        If there is no other arguments, deepin-feedback-cli.sh will collect debug
        information for special category and save it to archive file in
        current directory, the category could be (default: all):
            all
            background
            bluetooth
            bootmgr
            desktop
            display
            dock
            launcher
            login
            network


# Examples

  collect all system information and save to archive file in current
  directory:

      sudo deepin-feedback-cli
      sudo deepin-feedback-cli all

  collect system information related with network module and save
  to archive file in current directory:

      sudo deepin-feedback-cli network

  print network information:

      sudo deepin-feedback-cli --dump network
