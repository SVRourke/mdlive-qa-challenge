class AppsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def apps
        goodParams = process_params
        
        # render error if present
        
        if !goodParams[:error]
            records = App.order("#{goodParams[:by]} #{goodParams[:order]}").limit(goodParams[:limit]).offset(goodParams[:offset]) 
            render json: records, status: 200
        else
            render json: goodParams, status: 400
        end     
        # order
        # trim
        # render
    end

    private

    def range_params
        # Does basic checking for range parameter
        # adds defaults for most optional parameters
        params
            .require(:range)
            .permit(:by, :start, :end, :max, :order)
            .with_defaults(max: 50, start: 0, end: nil, order: "asc")
    end

    def process_params
        # Does more invloved processing of parameters
        raw = range_params.to_h

        # checks if "by" parameter was given and valid
        # returns "error" if not
        return {error: "BY PARAMETER REQUIRED, 'id' or 'name'"} unless !!raw[:by] && ["id", "name"].include?(raw[:by])

        hasEnd = !!raw[:end]
        startEndDiff = hasEnd ? raw[:end].to_i - raw[:start].to_i : nil
        endExceedsMax = hasEnd && startEndDiff > raw[:max].to_i ? true : false

        processedParams = {
            by: raw[:by],
            offset: raw[:start].to_i - 1,
            limit: !hasEnd || endExceedsMax ? raw[:max] : startEndDiff + 1,
            order: ["asc", "desc"].include?(raw[:order]) ? raw[:order] : 'asc'
        }

        return processedParams

    end

end
