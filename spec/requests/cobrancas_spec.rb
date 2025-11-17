require "rails_helper"

RSpec.describe "Cobranças do Responsável", type: :request do
  describe "GET /responsaveis/:id/cobrancas" do
    context "when vencida=true" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }
      let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }
      before do
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.yesterday, metodo_pagamento: :boleto, status: :emitida)
        plano_de_pagamento.cobrancas.create!(valor_cents: 150_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
        get "/responsaveis/#{responsavel_financeiro.id}/cobrancas", params: { vencida: "true" }
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body).size).to eq(1) }
    end
  end

  describe "GET /responsaveis/:id/cobrancas/quantidade" do
    context "when counting all" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }
      let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }
      before do
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.yesterday, metodo_pagamento: :boleto, status: :emitida)
        plano_de_pagamento.cobrancas.create!(valor_cents: 150_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
        get "/responsaveis/#{responsavel_financeiro.id}/cobrancas/quantidade"
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)["quantidade"]).to eq(2) }
    end
  end
end
