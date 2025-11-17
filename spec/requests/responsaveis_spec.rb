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

  describe "GET /responsaveis/:id" do
    context "when found" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro, nome: "Beltrano") }
      before { get "/responsaveis/#{responsavel_financeiro.id}" }
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)["nome"]).to eq("Beltrano") }
    end

    context "when not found" do
      before { get "/responsaveis/999999" }
      it { expect(response).to have_http_status(:not_found) }
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

    context "when valid with top-level nome" do
      before { post "/responsaveis", params: { responsavel_financeiro: { nome: "Ciclano" } } }
      it { expect(response).to have_http_status(:created) }
      it { expect(JSON.parse(response.body)["nome"]).to eq("Ciclano") }
    end
  end
end
