class Device
  class Delete < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :delete_triggers
    step :log_success
    failure  :log_failure

    contract do
      property :device_id, virtual: true

      validation do
        required(:device_id).filled
      end
    end

    def delete_triggers(options, params:, **)
      Action.where(device_id: params[:device_id]).delete
    end

    def log_success(options, params:, **)
      LOGGER.info "[#{self.class}] Deleted actions for device with params #{params.to_json}."
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to delete actions for device with params #{params.to_json}"
    end
  end
end