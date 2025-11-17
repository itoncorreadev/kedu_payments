require "rails_helper"

RSpec.describe "Centros de Custo", type: :request do
  describe "GET /centros-de-custo" do
    context "when there are records" do
      before { create_list(:centro_de_custo, 2) }
      before { get "/centros-de-custo" }
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body).size).to eq(2) }
    end
  end

  describe "POST /centros-de-custo" do
    context "when valid" do
      before { post "/centros-de-custo", params: { centro_de_custo: { nome: "MATRICULA" } } }
      it { expect(response).to have_http_status(:created) }
      it { expect(JSON.parse(response.body)["nome"]).to eq("MATRICULA") }
    end

    context "when invalid" do
      before { post "/centros-de-custo", params: { centro_de_custo: { nome: "" } } }
      it { expect(response).to have_http_status(:unprocessable_content) }
    end
  end
end
