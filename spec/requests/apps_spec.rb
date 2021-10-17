require "rails_helper"

RSpec.describe "The Endpoint", type: :request do
  before(:all) do
    60.times do |i|
      App.create(name: "app-#{i}")
    end
  end

  it "return a JSON array of 'apps'" do
    post "/apps", params: { range: { by: "id", start: 34, end: 40, max: 50 } }
    expect(response.content_type).to eq("application/json; charset=utf-8")
  end

  describe "Parameters" do
    describe "range omitted" do
      it "should respond with an array according to default parameters" do
        post "/apps"
        json = JSON.parse(response.body)
        # expect(json["error"]).to eq("BY PARAMETER REQUIRED, 'id' or 'name'")
        expect(response).to have_http_status(200)
      end
    end

    describe "by parameter" do
      it "is required" do
        post "/apps", params: { range: { start: 34, end: 40, max: 50 } }
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("BY PARAMETER REQUIRED, 'id' or 'name'")
        expect(response).to have_http_status(400)
      end

      it "only accepts id or name as values" do
        post "/apps", params: { range: { by: "weight", start: 34, end: 40, max: 50 } }
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("BY PARAMETER REQUIRED, 'id' or 'name'")
        expect(response).to have_http_status(400)
      end

      it "accepts id" do
        post "/apps", params: { range: { by: "id", start: 34, end: 40, max: 50 } }
        expect(response).to have_http_status(200)
      end

      it "accepts name" do
        post "/apps", params: { range: { by: "name", start: 34, end: 40, max: 50 } }
        expect(response).to have_http_status(200)
      end
    end

    describe "start parameter" do
      it "is not required" do
        post "/apps", params: { range: { by: "name" } }
        expect(response).to have_http_status(200)
      end

      it "defaults to the first record if omitted" do
        post "/apps", params: { range: { by: "id" } }
        json = JSON.parse(response.body)
        expect(json[0]["name"]).to eq("app-0")
        expect(response).to have_http_status(200)
      end

      it "decides which record to start from" do
        post "/apps", params: { range: { by: "id", start: 1 } }
        json = JSON.parse(response.body)
        expect(json[0]["name"]).to eq("app-0")
        expect(response).to have_http_status(200)
      end
    end

    describe "end parameter" do
      it "is not required" do
        post "/apps", params: { range: { by: "id" } }
        expect(response).to have_http_status(200)
      end

      it "is not required even if start is used" do
        post "/apps", params: { range: { by: "id", start: 1 } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(50)
        expect(response).to have_http_status(200)
      end

      it "defaults to max if omitted" do
        post "/apps", params: { range: { by: "id", start: 1, max: 40 } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(40)
        expect(response).to have_http_status(200)
      end

      it "is ignored if greater than max" do
        post "/apps", params: { range: { by: "id", start: 1, end: 150 } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(50)
        expect(response).to have_http_status(200)
      end

      it "decides which record to stop on" do
        post "/apps", params: { range: { by: "id", start: 1, end: 15 } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(15)
        expect(response).to have_http_status(200)
      end
    end

    describe "max parameter" do
      it "is not required" do
        post "/apps", params: { range: { by: "id" } }
        expect(response).to have_http_status(200)
      end

      it "defaults to 50 if omitted" do
        post "/apps", params: { range: { by: "id" } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(50)
        expect(response).to have_http_status(200)
      end

      it "max value is 50" do
        post "/apps", params: { range: { by: "id", max: 60 } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(50)
        expect(response).to have_http_status(200)
      end

      it "limits the number of returned records" do
        post "/apps", params: { range: { by: "id", max: 3 } }
        json = JSON.parse(response.body)
        expect(json.count).to eq(3)
        expect(response).to have_http_status(200)
      end
    end

    describe "order parameter" do
      it "is not required" do
        post "/apps", params: { range: { by: "id" } }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
      end

      it "defaults to asc if omitted" do
        post "/apps", params: { range: { by: "id" } }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(json[0]["id"]).to be < json[1]["id"]
      end

      it "accepts asc or desc as inputs" do
        post "/apps", params: { range: { by: "id", order: "desc" } }
        expect(response).to have_http_status(200)

        post "/apps", params: { range: { by: "id", order: "asc" } }
        expect(response).to have_http_status(200)
      end

      it "determines the order of returned records" do
        post "/apps", params: { range: { by: "id", order: "desc" } }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(json[0]["id"]).to be > json[1]["id"]

        post "/apps", params: { range: { by: "id", order: "asc" } }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(json[0]["id"]).to be < json[1]["id"]
      end
    end
  end

  after(:all) do
    App.destroy_all
  end
end

# App.queryByParams(by, start, end, max, order)
