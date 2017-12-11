require 'securerandom'

class Action < Sequel::Model(DB)
  class Update < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :set_timestamps
    step Contract::Persist()
    step :log_success
    failure  :log_failure

    contract do
      property :device_id
      property :title
      property :input
      property :id

      validation do
        required(:device_id).filled
        required(:title).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = Action.where(device_id: params[:device_id]).where(id: params[:id]).first
      options['model']
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.updated_at = timestamp
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Updated action with params #{params.to_json}. Action: #{Action::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to update action with params #{params.to_json}"
    end
  end
end