require 'xcodeproj'

module Fastlane
  module Actions
    module SharedValues
      XCODE_PROJECT_PATH = :XCODE_PROJECT_PATH
      XCODE_PROJECT_NAME = :XCODE_PROJECT_NAME
      XCODE_APP_IDENTIFIER = :XCODE_APP_IDENTIFIER
    end

    class GetPreprocessorDefinitionsAction < Action
      def self.run(params)
        @project_path = params[:xcodeproj]
        UI.user_error!('Please pass the path to the project (.xcodeproj)') unless @project_path.to_s.end_with?('.xcodeproj')
        UI.user_error!('Could not find Xcode project') unless File.exist?(@project_path)

        @target_name = params[:target_name]

        @search_key = params[:search_key]

        @project_name = @project_path.split('/')[-1]
        @project = Xcodeproj::Project.open(@project_path)
        UI.user_error!('Not found any target in project') if @project.targets.empty?

        target = get_target!(@project, @target_name)
        definitions = target.resolved_build_setting("GCC_PREPROCESSOR_DEFINITIONS")
        # puts "#{@target_name} definitions is: #{definitions}"
        # puts "definitions.values.compact.uniq[-1] : #{definitions.values.compact.uniq[-1]}"
        definitions.values.compact.uniq[-1].each do |definition|
          if definition.include?@search_key
            search_result = definition.split("=").last.strip
            # puts "#{@target_name} result is: #{search_result}"
            UI.message "get #{@search_key} in #{@target_name} result is #{search_result}."
            return search_result
          end
        end
      end

      def self.get_target!(project, target_name)
        targets = project.targets

        # Prompt targets if no name
        unless target_name

          # Gets non-test targets
          non_test_targets = targets.reject do |t|
            # Not all targets respond to `test_target_type?`
            t.respond_to?(:test_target_type?) && t.test_target_type?
          end

          # Returns if only one non-test target
          if non_test_targets.count == 1
            return targets.first
          end

          options = targets.map(&:name)
          target_name = UI.select("What target would you like to use?", options)
        end

        # Find target
        target = targets.find do |t|
          t.name == target_name
        end
        UI.user_error!("Cannot find target named '#{target_name}'") unless target

        target
      end
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_PROJECT_PROVISIONING_PROJECT_PATH",
                                       description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                                       optional: true,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project") if !File.exist?(value) && !Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :target_name,
                                       env_name: "XCODE_TARGET_NAME",
                                       description: "Project target name to use to build app",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: ''), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :search_key,
                                       env_name: "XCODE_TARGET_SEARCH_KEY",
                                       description: "Project target search_key to use to build app",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: 'per_mdb_id')
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        # [
        #   ['UPDATE_PREPROCESSOR_DEFINITIONS_CUSTOM_VALUE', 'A description of what this value contains']
        # ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Cai"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 
        platform == :ios
      end
    end
  end
end
