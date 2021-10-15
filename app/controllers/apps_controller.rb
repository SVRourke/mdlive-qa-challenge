class AppsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def apps
        goodParams = process_params

        # TODO: SERIALIZE APPS
        
        # Range and By provided
        if !goodParams[:error]
            records = App.order("#{goodParams[:by]} #{goodParams[:order]}").limit(goodParams[:limit]).offset(goodParams[:offset]) 
            render json: records, status: 200
        
        # Range provided By omitted
        elsif goodParams[:error]
            render json: goodParams, status: 400
        
        # Range omitted
        else
            records = App.order("id asc").limit(50)
            render json: goodParams, status: 200
        end     
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
        

    def process_params
        # does request have range?
        if params.key?("range")
            raw_params = strong_params
            
            #  missing by?
            if !raw_params.key?("by") || !["id", "name"].include?(raw_params["by"])
                return {error: "BY PARAMETER REQUIRED, 'id' or 'name'"}
            end
            
            # make sure max value is capped at 50
            max = !raw_params[:max] || raw_params[:max].to_i > 50 ? 50 : raw_params[:max].to_i

            # Check if end was provided
            hasEnd = !!raw_params[:end]
            
            # Calculate propsed number of records to return if end was provided
            # check if difference is greater than max return
            amendedStart = !!raw_params[:start].to_i && raw_params[:start].to_i > 0 ? raw_params[:start].to_i - 1 : raw_params[:start]
            startEndDiff = hasEnd ? raw_params[:end].to_i - amendedStart : nil
            
            # Check if start-end-diff exceeds max records
            endExceedsMax = hasEnd && startEndDiff > max.to_i ? true : false
            
            processedParams = {
                by: raw_params[:by],
                offset: amendedStart ? amendedStart : 0,
                limit: startEndDiff && startEndDiff <= 50 ? startEndDiff : max,
                order: ["asc", "desc"].include?(raw_params[:order]) ? raw_params[:order] : 'asc'
            }

            return processedParams

        else
            return { by: "id", offset: 0, limit: 50, order: "asc"}
        end                
    end
end