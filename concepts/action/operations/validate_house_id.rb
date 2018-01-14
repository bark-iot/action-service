require 'securerandom'

# Validates trigger belongs to house with house_id
class Action < Sequel::Model(DB)
  class ValidateHouseId < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :get_device
    step :validate_action
    step :log_success
    failure  :log_failure

    contract do
      property :house_id, virtual: true
      property :authorization_header, virtual: true
      property :id, virtual: true

      validation do
        required(:house_id).filled
        required(:authorization_header).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = Action.where(id: params[:id]).first
      options['model']
    end

    def get_device(options, params:, **)
      result = Device::Get.(id: options['model'].device_id, house_id: params[:house_id], authorization_header: params[:authorization_header])
      options['device'] = result['model']
      result.success?
    end

    def validate_action(options, params:, **)
      options['device']['house_id'] == params[:house_id].to_i
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Validated action with params #{params.to_json}. Action: #{Action::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to validate action with params #{params.to_json}"
    end
  end
end