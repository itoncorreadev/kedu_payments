class GraphqlController < ApplicationController
  def execute
    variables = params[:variables]
    variables = JSON.parse(variables) if variables.is_a?(String)
    query = params[:query]
    operation_name = params[:operationName]
    result = AppSchema.execute(query, variables: variables || {}, context: {}, operation_name: operation_name)
    render json: result
  end
end
