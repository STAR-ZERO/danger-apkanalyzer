module Danger
  # Run [apkanalyzer](https://developer.android.com/studio/command-line/apkanalyzer.html) and print
  # file size, permissions and number of method references.
  #
  # @example Set APK file path. Required
  #
  #          apkanalyzer.apk_file = "path_to/app.apk"
  #
  # @example Print file size of APK file
  #
  #          apkanalyzer.file_size
  #
  # @example Print permissions used by application
  #
  #          apkanalyzer.permissions
  #
  # @example Print number of method references
  #
  #          apkanalyzer.method_references
  #
  # @see  STAR-ZERO/danger-apkanalyzer
  # @tags android
  #
  class DangerApkanalyzer < Plugin
    require "open3"

    # apkanalyzer command file path.
    # Default to "apkanalyzer"
    # @return   [String]
    attr_accessor :command_apkanalyzer

    # APK file path. Required.
    # @return   [String]
    attr_accessor :apk_file

    DEFAULT_COMMAND = "apkanalyzer".freeze

    # Print file size of APK file.
    # @return   [String]
    def file_size
      if apk_file.nil?
        fail("You must set apk file path to 'apkanalyzer.apk_file'")
      end

      cmd = command_apkanalyzer || DEFAULT_COMMAND

      o, e, s = Open3.capture3("#{cmd} -h apk file-size #{apk_file};")
      if s.success?
        message = "#### APK file size\n\n"
        message << "| size |\n"
        message << "| --- |\n"
        message << "| #{o.chomp} |\n"
        message << "\n"
        markdown(message)
      else
        fail(e)
      end
    end

    # Print permissions used by application.
    # @return   [String]
    def permissions
      if apk_file.nil?
        fail("You must set apk file path to 'apkanalyzer.apk_file'")
      end

      cmd = command_apkanalyzer || DEFAULT_COMMAND
      o, e, s = Open3.capture3("#{cmd} -h manifest permissions #{apk_file};")
      return if o.empty?
      if s.success?
        message = "#### Permissions\n\n"
        message << "| Permissions |\n"
        message << "| --- |\n"
        o.each_line do |line|
          message << "| #{line.chomp} |\n"
        end
        message << "\n"
        markdown(message)
      else
        fail(e)
      end
    end

    # Print number of method references.
    # @return   [String]
    def method_references
      if apk_file.nil?
        fail("You must set apk file path to 'apkanalyzer.apk_file'")
      end

      cmd = command_apkanalyzer || DEFAULT_COMMAND
      o, e, s = Open3.capture3("#{cmd} -h dex references #{apk_file};")
      if s.success?
        message = "#### Number of method references\n\n"
        message << "| Dex file | count |\n"
        message << "| --- | --- |\n"
        o.each_line do |line|
          v = line.chomp.split(" ")
          message << "| #{v[0]} | #{v[1]} |\n"
        end
        message << "\n"
        markdown(message)
      else
        fail(e)
      end
    end
  end
end
