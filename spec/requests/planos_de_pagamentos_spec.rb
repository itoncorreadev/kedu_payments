require "rails_helper"

RSpec.describe "Planos de Pagamento", type: :request do
  describe "GET /planos-de-pagamento/:id" do
    context "when found" do
      let(:r) { create(:responsavel_financeiro) }
      let(:cc) { create(:centro_de_custo) }
      let(:plano) { create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc) }
      before { get "/planos-de-pagamento/#{plano.id}" }
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)["id"]).to eq(plano.id) }
    end

    context "when not found" do
      before { get "/planos-de-pagamento/999999" }
      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe "GET /planos-de-pagamento/:id/total" do
    context "when not found" do
      before { get "/planos-de-pagamento/999999/total" }
      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe "GET /responsaveis/:id/planos_de_pagamento" do
    let(:responsavel_financeiro_one) { create(:responsavel_financeiro) }
    let(:responsavel_financeiro_two) { create(:responsavel_financeiro) }
    let(:centro_de_custo) { create(:centro_de_custo) }
    before do
      create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro_one, centro_de_custo: centro_de_custo)
      create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro_two, centro_de_custo: centro_de_custo)
      get "/responsaveis/#{responsavel_financeiro_one.id}/planos_de_pagamento"
    end
    it { expect(response).to have_http_status(:ok) }
    it { expect(JSON.parse(response.body).size).to eq(1) }
  end
  describe "POST /planos-de-pagamento" do
    context "when valid" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }
      let(:payload) do
        {
          responsavelId: responsavel_financeiro.id,
          centroDeCusto: centro_de_custo.id,
          cobrancas: [
            { valor: 500.00, dataVencimento: Date.current + 30, metodoPagamento: "boleto" },
            { valor: 500.00, dataVencimento: Date.current + 60, metodoPagamento: "pix" }
          ]
        }
      end

      it "returns 201 and total is 1000" do
        post "/planos-de-pagamento", params: payload
        expect(response).to have_http_status(:created)
        id = JSON.parse(response.body)["id"]
        get "/planos-de-pagamento/#{id}/total"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["total"]).to eq("1000.0")
      end
    end

    context "when invalid" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }

      it "returns 422 when a cobranca has zero value" do
        payload = {
          responsavelId: responsavel_financeiro.id,
          centroDeCusto: centro_de_custo.id,
          cobrancas: [
            { valor: 500.00, dataVencimento: Date.current + 30, metodoPagamento: "boleto" },
            { valor: 0, dataVencimento: Date.current + 60, metodoPagamento: "pix" }
          ]
        }
        post "/planos-de-pagamento", params: payload
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when a cobranca has no date" do
        payload = {
          responsavelId: responsavel_financeiro.id,
          centroDeCusto: centro_de_custo.id,
          cobrancas: [ { valor: 500.00, metodoPagamento: "boleto" } ]
        }
        post "/planos-de-pagamento", params: payload
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when responsavel is missing" do
        payload = {
          centroDeCusto: centro_de_custo.id,
          cobrancas: [ { valor: 500.00, dataVencimento: Date.current + 30, metodoPagamento: "boleto" } ]
        }
        post "/planos-de-pagamento", params: payload
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when centro_de_custo is missing" do
        payload = {
          responsavelId: responsavel_financeiro.id,
          cobrancas: [ { valor: 500.00, dataVencimento: Date.current + 30, metodoPagamento: "boleto" } ]
        }
        post "/planos-de-pagamento", params: payload
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
  describe "POST /planos-de-pagamento with nested payload" do
    let(:responsavel_financeiro) { create(:responsavel_financeiro) }
    let(:centro_de_custo) { create(:centro_de_custo) }
    let(:payload) do
      {
        plano_de_pagamento: {
          responsavel_financeiro_id: responsavel_financeiro.id,
          centro_de_custo_id: centro_de_custo.id,
          cobrancas_attributes: [
            { valor: "125.05", dataVencimento: Date.current + 15, metodoPagamento: "PIX" }
          ]
        }
      }
    end
    it "creates and normalizes attributes" do
      post "/planos-de-pagamento", params: payload
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      id = body["id"]
      get "/planos-de-pagamento/#{id}"
      # cobrancas = JSON.parse(response.body)["cobrancas"] rescue nil
      get "/planos-de-pagamento/#{id}/total"
      expect(JSON.parse(response.body)["total"]).to eq("125.05")
    end
  end
end
