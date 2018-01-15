class SystemAction
  class List < Trailblazer::Operation
    step :list_by_type
    failure  :log_failure

    def list_by_type(options, params:, **)
      options['models'] = Action.where(type: Action::Types['system']).all
      options['models']
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found system actions for device #{params.to_json}. Actions: #{Action::Representer.for_collection.new(result['models']).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find system actions with params #{params.to_json}"
    end
  end
end