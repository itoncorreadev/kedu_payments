require "rails_helper"

RSpec.describe "Responsáveis", type: :request do
  describe "GET /responsaveis" do
    context "when there are records" do
      before { create_list(:responsavel_financeiro, 3) }
      before { get "/responsaveis" }
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body).size).to eq(3) }
    end
  end

  describe "POST /responsaveis" do
    context "when valid" do
      before { post "/responsaveis", params: { responsavel_financeiro: { nome: "Fulano" } } }
      it { expect(response).to have_http_status(:created) }
      it { expect(JSON.parse(response.body)["nome"]).to eq("Fulano") }
    end

    context "when invalid" do
      before { post "/responsaveis", params: { responsavel_financeiro: { nome: "" } } }
      it { expect(response).to have_http_status(:unprocessable_content) }
    end
  end
end
