require "rails_helper"

RSpec.describe "Planos de Pagamento", type: :request do
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
end
