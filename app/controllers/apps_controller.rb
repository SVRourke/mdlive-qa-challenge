class AppsController < ApplicationController
  def apps
    # Process the request parameters
    parameters = requestToQuery

    if parameters[:error]
      render json: parameters, status: 400
      return
    end

    records = App.simpleQ(parameters)
    render json: records, status: 200
  end

  private

  # Strong Params required to prevent unfiltered parameters error
  # If range is provided, this is used to access the content of the
  # request
  def strong_params
    params
      .require(:range)
      .permit(:by, :start, :end, :max, :order)
  end

  def requestToQuery
    # This function validates the provided params, adds default or
    # substitutes max values if/where needed. Returns an error
    # message if no by parameter is provided within range

    # Check if request body has a range key,
    # if not default query parameters will be passed along
    if params.key?("range")
      raw_params = strong_params

      # Check if the by parameter is present, if not the request
      # is invalid an an error message is returned
      if !raw_params.key?("by") || !["id", "name"].include?(raw_params["by"])
        return { error: "BY PARAMETER REQUIRED, 'id' or 'name'" }
      end

      # Check if max parameter was provided,
      # if it was and it is less than the max
      # of 50, the value is used, otherwise,
      # 50 is substituted
      max = !raw_params[:max] || raw_params[:max].to_i > 50 ? 50 : raw_params[:max].to_i

      # Provides an easy way to check if there is
      # an end parameter provided
      hasEnd = !!raw_params[:end]
      # REFACTOR: make nil or the value of end

      # if a start was provided and it is greater
      # than 0 subtract 1 from the number to account
      # for array 0 indexing
      amendedStart = !!raw_params[:start] && raw_params[:start].to_i > 0 ? raw_params[:start].to_i - 1 : raw_params[:start]

      # Calculate requested number of records to return
      startEndDiff = hasEnd ? raw_params[:end].to_i - amendedStart : nil

      # Check if number requested quantity is greater
      # than max return
      endExceedsMax = hasEnd && startEndDiff > max.to_i ? true : false

      # Build the query parameters to be used by the
      # app query in the action
      return {
               by: raw_params[:by],
               offset: amendedStart ? amendedStart : 0,
               limit: startEndDiff && startEndDiff <= 50 ? startEndDiff : max,
               order: ["asc", "desc"].include?(raw_params[:order]) ? raw_params[:order] : "asc",
             }

      # If no range parameter is provided, return a default set of query parameters
    else
      return { by: "id", offset: 0, limit: 50, order: "asc" }
    end
  end
end
