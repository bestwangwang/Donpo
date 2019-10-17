require 'xcodeproj'

module Fastlane
  module Actions
    module SharedValues
      SET_BUILD_SETTING_CUSTOM_VALUE = :SET_BUILD_SETTING_CUSTOM_VALUE
    end

    class SetBuildSettingAction < Action
      def self.run(params)
        @project_path = params[:xcodeproj]
        UI.user_error!('Please pass the path to the project (.xcodeproj)') unless @project_path.to_s.end_with?('.xcodeproj')
        UI.user_error!('Could not find Xcode project') unless File.exist?(@project_path)

        @target_name = params[:target_name]
        @configs = params[:configs]
        @definitions = params[:definitions]
        @project_name = @project_path.split('/')[-1]
        @project = Xcodeproj::Project.open(@project_path)
        UI.user_error!('Not found any target in project') if @project.targets.empty?

        target = get_target!(@project, @target_name)

        target.build_configurations.each do |config|
          if @configs != nil
            @configs.each do |key, value|
              config.build_settings[key] = value
            end
          end

          if @definitions != nil
            result_definitions = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
            @definitions.each do |d_key, d_value|
              find_result = result_definitions.select {|e| e.include?d_key }
              find_result.each do |definition|
                result_definitions.delete(definition)
              end
            end

            @definitions.each do |d_key, d_value|
              result_definitions << d_value
            end
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = result_definitions.uniq
          end
        end

        @project.save
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
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project") if !File.exist?(value) && !Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :target_name,
                                       env_name: "XCODE_TARGET_NAME",
                                       description: "Project target name to use to build app",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :configs,
                                       env_name: "XCODE_TARGET_CONFIGS",
                                       type: Hash,
                                       is_string: false,
                                       description: "Project target configs to use to build app",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :definitions,
                                       env_name: "XCODE_TARGET_DEFINITIONS",
                                       type: Hash,
                                       is_string: false,
                                       description: "Project target definitions to use to build app",
                                       optional: true)
        ]
      end

      def self.output
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Cai"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
