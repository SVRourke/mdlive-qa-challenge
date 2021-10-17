# MDLIVE QA Challenge

### my process

##### 1. Extracted Requirements (guessed about order)

The first thing I did when completing the challenge was to extract the requirements from the provided document. Nearly every aspect of the challenge had clearly defined expectations except for the order parameter. To complete the challenge I had to make some assumptions about the desired behavior of the order parameter and I decided on the following: 1. the order defaults to ascending if omitted, 2. the order accepts only ascending or descending, 3. the order defaults to ascending if an invalid value provided.

##### 2. Created Model and Controller

With my requirements clearly defined I quickly created a model and controller for the application. To meet the requirements I only needed a single model with an Id and Name and a controller with a single action for the endpoint "/apps". This was easy to do with rails generators.

##### 3. Wrote Tests

Using rspec I converted my extracted requirements into robust tests using rspec request specs. This allowed me to have a clearly defined path through the functionality and to receive visual feedback as to my progress.

##### 4. Made the Tests Pass

This was the fun part, working through the tests I utilized visual studio code's integral debugger system. Using the launch configuration generator I was able create multiple debugging configurations allowing my to debug the app as well as the tests.

##### 5. Add JSON Serializer

As a final cherry on top I added an ActiveModel::Serializer to return the data in the shape specified by the requirements.

##### 6. Switch to API

In my haste I neglected to add the -api flag when generation the rails application. To remedy this I made a new branch and replaced the existing app with a new rails app generated with the ideal configuration. I then merged files I wanted to keep from the old app into the new app.

##### 8. deployment

With all of my tests green I pushed the app to heroku which is a nice and simple process.

### My Solution

I decided this challenge could be distilled into two basic problems to solve, validating the request data and converting a valid request in the required format into one that would work for an ActiveModel Query.

##### Validating the Request

Upon receiving a request, the first thing that is done is to check if the request body contains a "range" parameter. If it does not a basic default set of values is used for the query.

```
 if params.key?("range")
    # Doing stuff
 else
    return { by: "id", offset: 0, limit: 50, order: "asc" }
 end
```

Next if a range is provided the "by" attribute is checked, if it is missing or invalid, an error message is returned.

```
 raw_params = strong_params

 if !raw_params.key?("by") || !["id", "name"].include?(raw_params["by"])
    return { error: "BY PARAMETER REQUIRED, 'id' or 'name'" }
 end
```

If a valid by attribute is present max is checked. Max is not required and is
50 by default, it may not exceed 50 and if it does so it will be replaced with 50.

```
 max = !raw_params[:max] || raw_params[:max].to_i > 50 ? 50 : raw_params[:max].to_i
```

Next the start and end parameters are examined, neither is required and they cannot be used to circumvent the max record value. If the start value is greater than zero, one is subtracted from the value to account for array indexing.

```
 hasEnd = !!raw_params[:end]
 amendedStart = !!raw_params[:start] && raw_params[:start].to_i > 0 ? raw_params[:start].to_i - 1 : raw_params[:start]
```

With the start and and solidified we calculate the requested number of records and replace with 50 if over the limit

```
 startEndDiff = hasEnd ? raw_params[:end].to_i - amendedStart : nil
 endExceedsMax = hasEnd && startEndDiff > max.to_i ? true : false
```

Finally we can return the validated data in a shape that makes sense for the ActiveModel query syntax of order, offset, by and limit, substituting default values where needed

```
 return {
     by: raw_params[:by],
     offset: amendedStart ? amendedStart : 0,
     limit: startEndDiff && startEndDiff <= 50 ? startEndDiff : max,
     order: ["asc", "desc"].include?(raw_params[:order]) ? raw_params[:order] : "asc",
 }
```

With the processed query parameters we can call #simpleQ a static method on the App model that accepts the query parameter object and returns an array of the queried records.

```
 def self.simpleQ(params)
     by, offset, limit, order = params.values_at(:by, :offset, :limit, :order)
     return App.order("#{by} #{order}").limit(limit).offset(offset)
 end
```

The results are then rendered like so:

```
 records = App.simpleQ(parameters)
 render json: records, status: 200
```

# The Live API

https://fathomless-spire-05096.herokuapp.com/app
